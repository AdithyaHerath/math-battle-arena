import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserIfNotExist(String uid) async {
    final docRef = _db.collection('users').doc(uid);
    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      final username = 'Guest_${uid.substring(0, 4)}';
      final newUser = AppUser(uid: uid, username: username);
      await docRef.set(newUser.toMap());
    }
  }

  Future<AppUser?> getUser(String uid) async {
    final docSnap = await _db.collection('users').doc(uid).get();
    if (docSnap.exists && docSnap.data() != null) {
      return AppUser.fromMap(docSnap.data()!, uid);
    }
    return null;
  }

  Future<void> addMatchResult(String uid, bool isWinner) async {
    await _db.collection('users').doc(uid).update({
      'matchesPlayed': FieldValue.increment(1),
      'wins': FieldValue.increment(isWinner ? 1 : 0),
    });
  }

  Future<List<AppUser>> getLeaderboard() async {
    final querySnap = await _db.collection('users')
        .orderBy('wins', descending: true)
        .limit(20)
        .get();
        
    return querySnap.docs.map((doc) => AppUser.fromMap(doc.data(), doc.id)).toList();
  }
}
