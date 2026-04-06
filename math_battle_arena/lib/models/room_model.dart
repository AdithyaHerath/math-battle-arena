enum RoomStatus { waiting, ready, playing, finished }

class RoomModel {
  final String roomId;
  final String player1Id;
  final String? player2Id;
  final String player1Name;
  final String player2Name;
  final RoomStatus status;
  final int player1Hp;
  final int player2Hp;
  final String currentQuestionId;
  final bool player2Ready;
  final DateTime createdAt;

  RoomModel({
    required this.roomId,
    required this.player1Id,
    this.player2Id,
    this.player1Name = '',
    this.player2Name = '',
    this.status = RoomStatus.waiting,
    this.player1Hp = 100,
    this.player2Hp = 100,
    this.currentQuestionId = '',
    this.player2Ready = false,
    required this.createdAt,
  });

  factory RoomModel.fromMap(String roomId, Map<dynamic, dynamic> map) {
    return RoomModel(
      roomId: roomId,
      player1Id: map['player1Id'] ?? '',
      player2Id: map['player2Id'],
      player1Name: map['player1Name'] ?? 'Player 1',
      player2Name: map['player2Name'] ?? 'Player 2',
      status: RoomStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'waiting'),
        orElse: () => RoomStatus.waiting,
      ),
      player1Hp: map['player1Hp'] ?? 100,
      player2Hp: map['player2Hp'] ?? 100,
      currentQuestionId: map['currentQuestionId'] ?? '',
      player2Ready: map['player2Ready'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'player1Id': player1Id,
      'player2Id': player2Id,
      'player1Name': player1Name,
      'player2Name': player2Name,
      'status': status.name,
      'player1Hp': player1Hp,
      'player2Hp': player2Hp,
      'currentQuestionId': currentQuestionId,
      'player2Ready': player2Ready,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  RoomModel copyWith({
    String? player2Id,
    String? player1Name,
    String? player2Name,
    RoomStatus? status,
    bool? player2Ready,
  }) {
    return RoomModel(
      roomId: roomId,
      player1Id: player1Id,
      player2Id: player2Id ?? this.player2Id,
      player1Name: player1Name ?? this.player1Name,
      player2Name: player2Name ?? this.player2Name,
      status: status ?? this.status,
      player1Hp: player1Hp,
      player2Hp: player2Hp,
      currentQuestionId: currentQuestionId,
      player2Ready: player2Ready ?? this.player2Ready,
      createdAt: createdAt,
    );
  }
}
