class RoomPlayer {
  final String uid;
  final String username;
  final bool isReady;
  final int hp;
  final bool hasAnsweredCurrent;

  RoomPlayer({
    required this.uid,
    required this.username,
    this.isReady = false,
    this.hp = 100,
    this.hasAnsweredCurrent = false,
  });

  factory RoomPlayer.fromMap(Map<dynamic, dynamic> map, String uid) {
    return RoomPlayer(
      uid: uid,
      username: map['username'] ?? 'Unknown',
      isReady: map['isReady'] ?? false,
      hp: map['hp'] ?? 100,
      hasAnsweredCurrent: map['hasAnsweredCurrent'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'isReady': isReady,
      'hp': hp,
      'hasAnsweredCurrent': hasAnsweredCurrent,
    };
  }
}
