import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email & password login
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _getOrCreateUserDoc(credential.user!, isGuest: false);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Email & password register
  Future<UserModel?> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(displayName);
      return await _getOrCreateUserDoc(
        credential.user!,
        isGuest: false,
        displayName: displayName,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Guest / anonymous login
  Future<UserModel?> signInAsGuest() async {
    try {
      final credential = await _auth.signInAnonymously();
      return await _getOrCreateUserDoc(
        credential.user!,
        isGuest: true,
        displayName: 'Guest_${credential.user!.uid.substring(0, 5)}',
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Creates user doc in Firestore on first login, fetches on subsequent logins
  Future<UserModel?> _getOrCreateUserDoc(
    User user, {
    required bool isGuest,
    String? displayName,
  }) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      final newUser = UserModel(
        uid: user.uid,
        displayName: displayName ?? user.displayName ?? 'Player',
        isGuest: isGuest,
      );
      await docRef.set(newUser.toMap());
      return newUser;
    }

    return UserModel.fromMap(doc.data()!);
  }

  // Update stats after a game ends
  Future<void> updateStats({
    required String uid,
    required bool didWin,
    required int totalAnswers,
    required int correctAnswers,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final currentWins = (data['wins'] ?? 0) as int;
    final currentMatches = (data['totalMatches'] ?? 0) as int;
    final currentAccuracy = (data['accuracy'] ?? 0.0) as double;

    final newMatches = currentMatches + 1;
    final newWins = didWin ? currentWins + 1 : currentWins;

    double newAccuracy = currentAccuracy;
    if (totalAnswers > 0) {
      final matchAccuracy = correctAnswers / totalAnswers;
      newAccuracy =
          ((currentAccuracy * currentMatches) + matchAccuracy) / newMatches;
    }

    await docRef.update({
      'wins': newWins,
      'totalMatches': newMatches,
      'accuracy': newAccuracy,
    });
  }

  // Refresh local user data from Firestore
  Future<UserModel?> refreshUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
