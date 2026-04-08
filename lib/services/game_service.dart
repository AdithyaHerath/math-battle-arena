import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

import '../models/app_user.dart';

class GameService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  String _generateRoomId() {
    final rng = Random();
    return (rng.nextInt(900000) + 100000).toString(); // 6-digit code
  }

  Stream<DatabaseEvent> streamRoom(String roomId) {
    return _db.child('rooms').child(roomId).onValue;
  }

  Future<String> createRoom(AppUser user) async {
    final roomId = _generateRoomId();
    final roomData = {
      'hostId': user.uid,
      'status': 'waiting',
      'level': 'Beginner',
      'currentQuestionIndex': 0,
      'winnerId': null,
      'players': {
        user.uid: {
          'username': user.username,
          'isReady': false,
          'hp': 100,
          'hasAnsweredCurrent': false,
        }
      }
    };

    await _db.child('rooms').child(roomId).set(roomData);
    return roomId;
  }

  Future<String?> joinRoom(String roomId, AppUser user) async {
    final snapshot = await _db.child('rooms').child(roomId).get();
    
    if (!snapshot.exists) {
      return "Room does not exist.";
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    if (data['status'] != 'waiting') {
      return "Game already started or finished.";
    }

    final playersMap = data['players'] as Map<dynamic, dynamic>? ?? {};
    if (playersMap.length >= 2 && !playersMap.containsKey(user.uid)) {
      return "Room is full.";
    }

    // Add player
    await _db.child('rooms').child(roomId).child('players').child(user.uid).set({
      'username': user.username,
      'isReady': false,
      'hp': 100,
      'hasAnsweredCurrent': false,
    });

    return null; // Success
  }

  Future<void> setReadyState(String roomId, String uid, bool isReady) async {
    await _db.child('rooms').child(roomId).child('players').child(uid).update({
      'isReady': isReady,
    });
  }

  Future<void> setRoomLevel(String roomId, String level) async {
    await _db.child('rooms').child(roomId).update({
      'level': level,
    });
  }

  Future<void> leaveRoom(String roomId, String uid) async {
    // Determine if user is host and only player
    final snap = await _db.child('rooms').child(roomId).get();
    if (!snap.exists) return;

    final data = snap.value as Map<dynamic, dynamic>? ?? {};
    final players = data['players'] as Map<dynamic, dynamic>? ?? {};

    if (players.length <= 1) {
      // Last player leaving, delete room
      await _db.child('rooms').child(roomId).remove();
    } else {
      // Remove player
      await _db.child('rooms').child(roomId).child('players').child(uid).remove();
      // If host left, assign new host
      if (data['hostId'] == uid) {
        // Safe to use firstWhere because length > 1
        String newHostId = players.keys.firstWhere((k) => k != uid);
        await _db.child('rooms').child(roomId).update({'hostId': newHostId});
      }
    }
  }

  Future<void> startGame(String roomId) async {
    await _db.child('rooms').child(roomId).update({
      'status': 'playing',
    });
  }

  Future<void> submitAnswer(String roomId, String uid, String opponentId, int opponentHp, bool isCorrect) async {
    final Map<String, Object> updates = {};
    updates['players/$uid/hasAnsweredCurrent'] = true;
    if (isCorrect) {
      updates['players/$opponentId/hp'] = opponentHp > 10 ? opponentHp - 10 : 0;
    }
    await _db.child('rooms').child(roomId).update(updates);
  }

  Future<void> endGame(String roomId, String? winnerId) async {
    await _db.child('rooms').child(roomId).update({
      'status': 'finished',
      'winnerId': winnerId,
    });
  }
}
