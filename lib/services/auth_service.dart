import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;
      if (user != null) {
        await _firestoreService.createUserIfNotExist(user.uid);
        return user;
      }
    } catch (e) {
      print('Auth error: $e');
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
