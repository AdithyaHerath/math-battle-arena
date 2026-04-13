import 'package:flutter/material.dart';
import 'dart:async';
import '../services/room_service.dart';
import '../models/room_model.dart';

enum LobbyStatus { idle, creating, waiting, joining, ready, error }

class LobbyViewModel extends ChangeNotifier {
  final RoomService _roomService = RoomService();

  LobbyStatus _status = LobbyStatus.idle;
  RoomModel? _currentRoom;
  String _errorMessage = '';
  StreamSubscription? _roomSubscription;
  String _selectedDifficulty = 'easy';

  LobbyStatus get status => _status;
  RoomModel? get currentRoom => _currentRoom;
  String get errorMessage => _errorMessage;
  String get roomId => _currentRoom?.roomId ?? '';
  String get selectedDifficulty => _selectedDifficulty;
  bool get player2Joined => _currentRoom?.player2Id != null;
  bool get player2Ready => _currentRoom?.player2Ready ?? false;
  bool get gameStarted => _currentRoom?.status == RoomStatus.playing;

  void setDifficulty(String difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }

  Future<void> createRoom(String playerId, String playerName) async {
    _status = LobbyStatus.creating;
    notifyListeners();
    try {
      _currentRoom = await _roomService.createRoom(playerId, playerName);
      _status = LobbyStatus.waiting;
      notifyListeners();
      _watchRoom(_currentRoom!.roomId);
    } catch (e) {
      print('Error creating room: $e');
      _status = LobbyStatus.error;
      _errorMessage = 'Failed to create room: $e';
      notifyListeners();
    }
  }

  Future<bool> joinRoom(
    String roomId,
    String playerId,
    String playerName,
  ) async {
    _status = LobbyStatus.joining;
    notifyListeners();
    try {
      final room = await _roomService.joinRoom(roomId, playerId, playerName);
      if (room == null) {
        _status = LobbyStatus.error;
        _errorMessage = 'Room not found or already full.';
        notifyListeners();
        return false;
      }
      _currentRoom = room.copyWith(
        player2Id: playerId,
        player2Name: playerName,
      );
      _status = LobbyStatus.waiting;
      notifyListeners();
      _watchRoom(roomId);
      return true;
    } catch (e) {
      _status = LobbyStatus.error;
      _errorMessage = 'Failed to join room.';
      notifyListeners();
      return false;
    }
  }

  Future<void> setReady() async {
    if (_currentRoom == null) return;
    await _roomService.setPlayer2Ready(_currentRoom!.roomId);
  }

  Future<void> startGame() async {
    if (_currentRoom == null) return;
    await _roomService.startGame(_currentRoom!.roomId, _selectedDifficulty);
  }

  void _watchRoom(String roomId) {
    _roomSubscription?.cancel();
    _roomSubscription = _roomService.watchRoom(roomId).listen((room) {
      if (room == null) return;
      _currentRoom = room;
      if (room.status == RoomStatus.playing) {
        _status = LobbyStatus.ready;
      }
      notifyListeners();
    });
  }

  Future<void> leaveRoom() async {
    _roomSubscription?.cancel();
    if (_currentRoom != null) {
      await _roomService.deleteRoom(_currentRoom!.roomId);
    }
    _currentRoom = null;
    _status = LobbyStatus.idle;
    _errorMessage = '';
    _selectedDifficulty = 'easy';
    notifyListeners();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }
}
