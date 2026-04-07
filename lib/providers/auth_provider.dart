import 'dart:async';
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
  StreamSubscription<AppUser?>? _userSubscription;

  User? get user => _user;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;

  AppAuthProvider() {
    _authService.authStateChanges.listen((User? authUser) async {
      _user = authUser;
      _userSubscription?.cancel();

      if (authUser != null) {
        _appUser = await _firestoreService.getUser(authUser.uid);
        if (_appUser == null) {
          await _firestoreService.createUserIfNotExist(authUser.uid);
        }
        
        _userSubscription = _firestoreService.getUserStream(authUser.uid).listen((AppUser? streamUser) {
          _appUser = streamUser;
          notifyListeners();
        });
      } else {
        _appUser = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  Future<void> signInAnonymously() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signInAnonymously();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> registerWithEmail(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.registerWithEmail(email, password, name);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithEmail(email, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
