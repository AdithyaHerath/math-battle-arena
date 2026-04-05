class AppUser {
  final String uid;
  final String username;
  final int wins;
  final int matchesPlayed;

  AppUser({
    required this.uid,
    required this.username,
    this.wins = 0,
    this.matchesPlayed = 0,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String documentId) {
    return AppUser(
      uid: documentId,
      username: data['username'] ?? 'Unknown',
      wins: data['wins'] ?? 0,
      matchesPlayed: data['matchesPlayed'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'wins': wins,
      'matchesPlayed': matchesPlayed,
      'createdAt': DateTime.now(), // Firestore will convert this
    };
  }
}
