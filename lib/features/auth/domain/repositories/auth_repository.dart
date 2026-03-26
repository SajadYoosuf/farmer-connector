import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserEntity {
  final String uid;
  final String email;
  final String role;
  final String status; // 'pending', 'approved', 'declined'
  final String? fullName;
  final Map<String, dynamic>? extraData;

  UserEntity({
    required this.uid, 
    required this.email, 
    required this.role, 
    required this.status,
    this.fullName,
    this.extraData,
  });
}

abstract class AuthRepository {
  Future<UserEntity?> signIn(String email, String password);
  Future<UserEntity?> signUp(String email, String password, String role, {Map<String, dynamic>? extraData});
  Future<void> signOut();
  Future<String?> getUserRole(String uid);
  Future<UserEntity?> getUserDetails(String uid);
  Stream<firebase_auth.User?> get authStateChanges;
}
