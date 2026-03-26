import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:customer_app/core/services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  UserEntity? _currentUser;
  bool _isLoading = true;
  StreamSubscription? _userDocSubscription;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  String _selectedRole = 'user';
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

  AuthProvider(this._authRepository) {
    _init();
  }

  void _init() {
    _authRepository.authStateChanges.listen((User? firebaseUser) async {
      _isLoading = true;
      notifyListeners();

      _userDocSubscription?.cancel();

      if (firebaseUser != null) {
        // Start listening to the specific user document for real-time status updates
        _userDocSubscription = FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .snapshots()
            .listen((snapshot) {
              if (snapshot.exists) {
                final data = snapshot.data()!;
                _currentUser = UserEntity(
                    uid: firebaseUser.uid,
                    email: data['email'] ?? '',
                    role: data['role'] ?? 'user',
                    status: data['status'] ?? 'approved',
                    fullName: data['fullName'],
                    extraData: data,
                );
              }
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
      final user = await _authRepository.signIn(email, password);
      
      if (user != null) {
        if (expectedRole != null && user.role != expectedRole) {
            await _authRepository.signOut();
            _isLoading = false;
            notifyListeners();
            return false;
        }
        // Listener in _init will handle _currentUser assignment via snapshots
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

  Future<String?> signUp(String email, String password, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authRepository.signUp(email, password, role, extraData: _signupExtraData);
      if (user != null) {
        // Log signup activity
        final name = _signupExtraData['fullName'] ?? email.split('@').first;
        await FirestoreService().logSignupActivity(user.uid, name, role);
      }
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
    await _authRepository.signOut();
  }

  @override
  void dispose() {
    _userDocSubscription?.cancel();
    super.dispose();
  }
}
