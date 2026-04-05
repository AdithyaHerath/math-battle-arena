import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _user;
  AppUser? _appUser;
  bool _isLoading = false;

  User? get user => _user;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;

  AppAuthProvider() {
    _authService.authStateChanges.listen((User? authUser) async {
      _user = authUser;
      if (authUser != null) {
        _appUser = await _firestoreService.getUser(authUser.uid);
        if (_appUser == null) {
          await _firestoreService.createUserIfNotExist(authUser.uid);
          _appUser = await _firestoreService.getUser(authUser.uid);
        }
      } else {
        _appUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> signInAnonymously() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signInAnonymously();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
