import 'package:firebase_database/firebase_database.dart';
import '../models/room_model.dart';

class RoomService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  String _generateRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    int seed = DateTime.now().millisecondsSinceEpoch;
    String id = '';
    for (int i = 0; i < 6; i++) {
      id += chars[seed % chars.length];
      seed = (seed * 1664525 + 1013904223) & 0xFFFFFFFF;
    }
    return id;
  }

  Future<RoomModel> createRoom(String player1Id, String player1Name) async {
    final roomId = _generateRoomId();
    final room = RoomModel(
      roomId: roomId,
      player1Id: player1Id,
      player1Name: player1Name,
      createdAt: DateTime.now(),
    );
    await _db.ref('rooms/$roomId').set(room.toMap());
    return room;
  }

  Future<RoomModel?> joinRoom(
    String roomId,
    String player2Id,
    String player2Name,
  ) async {
    final ref = _db.ref('rooms/$roomId');
    final snapshot = await ref.get();

    if (!snapshot.exists) return null;

    final room = RoomModel.fromMap(roomId, snapshot.value as Map);
    if (room.player2Id != null) return null;

    await ref.update({'player2Id': player2Id, 'player2Name': player2Name});

    return room;
  }

  Future<void> setPlayer2Ready(String roomId) async {
    await _db.ref('rooms/$roomId').update({'player2Ready': true});
  }

  Future<void> startGame(String roomId, String difficulty) async {
    await _db.ref('rooms/$roomId').update({
      'status': RoomStatus.playing.name,
      'difficulty': difficulty,
    });
  }

  Stream<RoomModel?> watchRoom(String roomId) {
    return _db.ref('rooms/$roomId').onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return RoomModel.fromMap(roomId, event.snapshot.value as Map);
    });
  }

  Future<void> deleteRoom(String roomId) async {
    await _db.ref('rooms/$roomId').remove();
  }
}
