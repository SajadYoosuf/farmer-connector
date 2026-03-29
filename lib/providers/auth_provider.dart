import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:customer_app/models/user_model.dart';
import 'package:customer_app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = true;
  StreamSubscription? _userDocSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  String _selectedRole = 'customer';
  String get selectedRole => _selectedRole;

  String _signupEmail = '';
  String get signupEmail => _signupEmail;

  Map<String, dynamic> _signupExtraData = {};
  Map<String, dynamic> get signupExtraData => _signupExtraData;

  void setRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void setSignupEmail(String email) {
    _signupEmail = email;
    notifyListeners();
  }

  void setSignupExtraData(Map<String, dynamic> data) {
    _signupExtraData = data;
    notifyListeners();
  }

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      _isLoading = true;
      notifyListeners();

      _userDocSubscription?.cancel();

      if (firebaseUser != null) {
        _userDocSubscription = _authService.userStream(firebaseUser.uid).listen((user) {
          _currentUser = user;
          _isLoading = false;
          notifyListeners();
        });
      } else {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<bool> signIn(String email, String password, {String? expectedRole}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final user = await _authService.signIn(email, password);
      
      if (user != null) {
        if (expectedRole != null && user.role != expectedRole) {
            await _authService.signOut();
            _isLoading = false;
            notifyListeners();
            return false;
        }
      }

      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> signUp(String email, String password, String role, {Map<String, dynamic>? extraData}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final dataToUse = extraData ?? _signupExtraData;
      final user = await _authService.signUp(email, password, role, extraData: dataToUse);
      _isLoading = false;
      notifyListeners();
      return user != null ? null : "Unknown Error";
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _userDocSubscription?.cancel();
    await _authService.signOut();
  }

  Future<String?> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  @override
  void dispose() {
    _userDocSubscription?.cancel();
    super.dispose();
  }
}
