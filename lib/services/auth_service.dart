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

  Future<User?> registerWithEmail(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await _firestoreService.createUserIfNotExist(user.uid, name);
        return user;
      }
    } catch (e) {
      print('Auth error: $e');
      rethrow;
    }
    return null;
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Auth error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
