import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserIfNotExist(String uid, [String? username]) async {
    final docRef = _db.collection('users').doc(uid);
    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      final finalUsername = username ?? 'Guest_${uid.substring(0, 4)}';
      final newUser = AppUser(uid: uid, username: finalUsername);
      await docRef.set(newUser.toMap());
    } else if (username != null) {
      await docRef.update({'username': username});
    }
  }

  Future<AppUser?> getUser(String uid) async {
    final docSnap = await _db.collection('users').doc(uid).get();
    if (docSnap.exists && docSnap.data() != null) {
      return AppUser.fromMap(docSnap.data()!, uid);
    }
    return null;
  }

  Stream<AppUser?> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((docSnap) {
      if (docSnap.exists && docSnap.data() != null) {
        return AppUser.fromMap(docSnap.data()!, uid);
      }
      return null;
    });
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
