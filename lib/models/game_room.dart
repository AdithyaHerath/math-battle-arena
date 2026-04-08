import 'room_player.dart';

class GameRoom {
  final String roomId;
  final String hostId;
  final String status; // "waiting", "playing", "finished"
  final int currentQuestionIndex;
  final String? winnerId;
  final String level;
  final Map<String, RoomPlayer> players;

  GameRoom({
    required this.roomId,
    required this.hostId,
    required this.status,
    required this.currentQuestionIndex,
    this.winnerId,
    required this.level,
    required this.players,
  });

  factory GameRoom.fromMap(Map<dynamic, dynamic> map, String roomId) {
    Map<String, RoomPlayer> parsedPlayers = {};
    if (map['players'] != null) {
      final playersMap = map['players'] as Map<dynamic, dynamic>;
      playersMap.forEach((key, value) {
        parsedPlayers[key] = RoomPlayer.fromMap(value, key);
      });
    }

    return GameRoom(
      roomId: roomId,
      hostId: map['hostId'] ?? '',
      status: map['status'] ?? 'waiting',
      currentQuestionIndex: map['currentQuestionIndex'] ?? 0,
      winnerId: map['winnerId'],
      level: map['level'] ?? 'Beginner',
      players: parsedPlayers,
    );
  }

  bool get isFull => players.length >= 2;
  bool get allPlayersReady {
    if (players.length < 2) return false;
    return players.values.every((p) => p.isReady);
  }
}
