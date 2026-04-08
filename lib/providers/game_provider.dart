import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/app_user.dart';
import '../models/game_room.dart';
import '../models/math_question.dart';
import '../services/game_service.dart';
import '../services/firestore_service.dart';

class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();
  final FirestoreService _firestoreService = FirestoreService();
  
  GameRoom? _currentRoom;
  GameRoom? get currentRoom => _currentRoom;
  String? get roomId => _currentRoom?.roomId;

  AppUser? _me;
  
  StreamSubscription<DatabaseEvent>? _roomSubscription;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Game Logic
  int _timeLeft = 10;
  int get timeLeft => _timeLeft;
  Timer? _localTimer;
  bool _resultSaved = false;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> createAndJoinRoom(AppUser user) async {
    _isLoading = true;
    _errorMessage = null;
    _me = user;
    _resultSaved = false;
    _currentRoom = null;
    notifyListeners();

    try {
      final newRoomId = await _gameService.createRoom(user);
      _listenToRoom(newRoomId);
      
      int retries = 0;
      while (_currentRoom?.roomId != newRoomId && retries < 60) {
        await Future.delayed(const Duration(milliseconds: 50));
        retries++;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Failed to create room: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinRoom(String roomIdToJoin, AppUser user) async {
    _isLoading = true;
    _errorMessage = null;
    _me = user;
    _resultSaved = false;
    _currentRoom = null;
    notifyListeners();

    try {
      final rId = roomIdToJoin.trim();
      final error = await _gameService.joinRoom(rId, user);
      if (error != null) {
        _errorMessage = error;
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _listenToRoom(rId);

      int retries = 0;
      while (_currentRoom?.roomId != rId && retries < 60) {
        await Future.delayed(const Duration(milliseconds: 50));
        retries++;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Failed to join room: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _listenToRoom(String rId) {
    _roomSubscription?.cancel();
    _roomSubscription = _gameService.streamRoom(rId).listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final newRoom = GameRoom.fromMap(data, rId);
        
        _processRoomStateDifferences(_currentRoom, newRoom);
        
        _currentRoom = newRoom;
      } else {
        _currentRoom = null;
        _localTimer?.cancel();
        _roomSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  void _processRoomStateDifferences(GameRoom? oldRoom, GameRoom newRoom) {
     if (newRoom.status == 'playing') {
         if (oldRoom?.status != 'playing' || oldRoom?.currentQuestionIndex != newRoom.currentQuestionIndex) {
            _startLocalTimer(newRoom);
         }
         
         // Host manages advancing questions or ending
         if (_me != null && newRoom.hostId == _me!.uid) {
             bool bothAnswered = newRoom.players.values.every((p) => p.hasAnsweredCurrent);
             bool anyoneDead = newRoom.players.values.any((p) => p.hp <= 0);

             if (anyoneDead) {
                 _endGame(newRoom);
             } else if (bothAnswered) {
                 _moveToNextQuestion(newRoom);
             }
         }
     } else if (newRoom.status == 'finished') {
         _localTimer?.cancel();
         if (!_resultSaved && _me != null) {
             _resultSaved = true;
             bool won = newRoom.winnerId == _me!.uid;
             _firestoreService.addMatchResult(_me!.uid, won);
         }
     }
  }

  void _startLocalTimer(GameRoom room) {
      _localTimer?.cancel();
      _timeLeft = room.level == 'Beginner' ? 10 : 30;
      notifyListeners();
      
      _localTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_timeLeft > 0) {
              _timeLeft--;
              notifyListeners();
          } else {
              timer.cancel();
              // Host handles timeout advancing
              if (_me != null && room.hostId == _me!.uid) {
                  _moveToNextQuestion(room);
              }
          }
      });
  }

  Future<void> _moveToNextQuestion(GameRoom room) async {
       _localTimer?.cancel();
       int poolLength = MathQuestion.levelPools[room.level]?.length ?? 5;
       if (room.currentQuestionIndex >= poolLength - 1) {
             await _endGame(room);
       } else {
             final Map<String, Object> updates = {
                 'currentQuestionIndex': room.currentQuestionIndex + 1,
             };
             room.players.keys.forEach((uid) => updates['players/$uid/hasAnsweredCurrent'] = false);
             await FirebaseDatabase.instance.ref('rooms/${room.roomId}').update(updates);
       }
  }

  Future<void> _endGame(GameRoom room) async {
       int bestHp = -1;
       String? winnerId;
       
       room.players.forEach((uid, p) {
           if (p.hp > bestHp) {
               bestHp = p.hp;
               winnerId = uid;
           } else if (p.hp == bestHp) {
               winnerId = null; 
           }
       });

       await _gameService.endGame(room.roomId, winnerId);
  }

  Future<void> submitAnswer(int selectedAnswer) async {
      if (_currentRoom == null || _me == null) return;
      
      final myPlayer = _currentRoom!.players[_me!.uid];
      // Prevent double answering per question 
      if (myPlayer == null || myPlayer.hasAnsweredCurrent) return;

      final pool = MathQuestion.levelPools[_currentRoom!.level] ?? MathQuestion.levelPools['Beginner']!;
      final currentQ = pool[_currentRoom!.currentQuestionIndex];
      bool isCorrect = selectedAnswer == currentQ.correctAnswer;

      // Find opponent
      String opponentId = _currentRoom!.players.keys.firstWhere((k) => k != _me!.uid, orElse: () => '');
      int opponentHp = opponentId.isNotEmpty ? (_currentRoom!.players[opponentId]?.hp ?? 100) : 100;

      await _gameService.submitAnswer(_currentRoom!.roomId, _me!.uid, opponentId, opponentHp, isCorrect);
  }

  Future<void> setRoomLevel(String level) async {
    if (_currentRoom != null && _me != null && _currentRoom!.hostId == _me!.uid) {
      await _gameService.setRoomLevel(_currentRoom!.roomId, level);
    }
  }

  Future<void> toggleReady(String uid) async {
    if (_currentRoom == null) return;
    final player = _currentRoom!.players[uid];
    if (player != null) {
      await FirebaseDatabase.instance.ref('rooms/${_currentRoom!.roomId}/players/$uid').update({'isReady': !player.isReady});
    }
  }

  Future<void> leaveRoom(String uid) async {
    if (_currentRoom != null) {
      final rId = _currentRoom!.roomId;
      _localTimer?.cancel();
      _roomSubscription?.cancel();
      _currentRoom = null;
      notifyListeners();
      await _gameService.leaveRoom(rId, uid);
    }
  }

  Future<void> startGame() async {
    if (_currentRoom != null && _currentRoom!.allPlayersReady) {
      await _gameService.startGame(_currentRoom!.roomId);
    }
  }

  @override
  void dispose() {
    _localTimer?.cancel();
    _roomSubscription?.cancel();
    super.dispose();
  }
}
