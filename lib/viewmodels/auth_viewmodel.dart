import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.idle;
  UserModel? _currentUser;
  String _errorMessage = '';

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  // Expose current user email from Firebase Auth directly
  String get currentUserEmail => _authService.currentUser?.email ?? '';

  Future<void> signIn(String email, String password) async {
    _setLoading();
    try {
      _currentUser = await _authService.signInWithEmail(email, password);
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> register(
    String email,
    String password,
    String displayName,
  ) async {
    _setLoading();
    try {
      _currentUser = await _authService.registerWithEmail(
        email,
        password,
        displayName,
      );
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordReset(email);
    } catch (e) {
      // Silently fail — snackbar handles feedback
    }
  }

  Future<void> signInAsGuest() async {
    _setLoading();
    try {
      _currentUser = await _authService.signInAsGuest();
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String displayName,
    required int avatarIndex,
  }) async {
    if (_currentUser == null) return false;
    try {
      await _authService.updateProfile(
        uid: _currentUser!.uid,
        displayName: displayName,
        avatarIndex: avatarIndex,
      );
      // Refresh local user so all screens update instantly
      final updated = await _authService.refreshUser(_currentUser!.uid);
      if (updated != null) {
        _currentUser = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateStatsAfterGame({
    required bool? didWin,
    required int totalAnswers,
    required int correctAnswers,
  }) async {
    if (_currentUser == null) return;
    try {
      await _authService.updateStats(
        uid: _currentUser!.uid,
        didWin: didWin,
        totalAnswers: totalAnswers,
        correctAnswers: correctAnswers,
      );
      final doc = await _authService.refreshUser(_currentUser!.uid);
      if (doc != null) {
        _currentUser = doc;
        notifyListeners();
      }
    } catch (e) {
      // Silently fail — stats are not critical
    }
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();
  }

  void _setSuccess() {
    _status = AuthStatus.success;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    _status = AuthStatus.idle;
    notifyListeners();
  }
}
