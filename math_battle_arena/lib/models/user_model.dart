class UserModel {
  final String uid;
  final String displayName;
  final bool isGuest;
  final int wins;
  final int totalMatches;
  final double accuracy;
  final int avatarIndex;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.isGuest,
    this.wins = 0,
    this.totalMatches = 0,
    this.accuracy = 0.0,
    this.avatarIndex = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? 'Player',
      isGuest: map['isGuest'] ?? false,
      wins: map['wins'] ?? 0,
      totalMatches: map['totalMatches'] ?? 0,
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
      avatarIndex: map['avatarIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'isGuest': isGuest,
      'wins': wins,
      'totalMatches': totalMatches,
      'accuracy': accuracy,
      'avatarIndex': avatarIndex,
    };
  }

  UserModel copyWith({String? displayName, int? avatarIndex}) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      isGuest: isGuest,
      wins: wins,
      totalMatches: totalMatches,
      accuracy: accuracy,
      avatarIndex: avatarIndex ?? this.avatarIndex,
    );
  }
}
