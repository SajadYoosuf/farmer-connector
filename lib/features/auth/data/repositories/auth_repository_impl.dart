import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:customer_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
      return null;
    } catch (e) {
      print("Error fetching user role: $e");
      return null;
    }
  }

  @override
  Future<UserEntity?> getUserDetails(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return UserEntity(
          uid: uid,
          email: data['email'] ?? '',
          role: data['role'] ?? 'user',
          status: data['status'] ?? 'approved', // Defaulting for backward compatibility
          fullName: data['fullName'],
          extraData: data,
        );
      }
      return null;
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  @override
  Future<UserEntity?> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        return await getUserDetails(user.uid);
      }
      return null;
    } catch (e) {
      print("Sign in failed: $e");
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserEntity?> signUp(String email, String password, String role, {Map<String, dynamic>? extraData}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        // Farmers require admin approval, normal users/customers and admins are approved by default
        final status = (role == 'farmer') ? 'pending' : 'approved';
        
        final userData = {
          'email': user.email,
          'uid': user.uid,
          'role': role,
          'status': status,
          'createdAt': FieldValue.serverTimestamp(),
        };
        if (extraData != null) {
          userData.addAll(extraData);
        }
        await _firestore.collection('users').doc(user.uid).set(userData);
        return await getUserDetails(user.uid);
      }
      return null;
    } catch (e) {
      print("Sign up failed: $e");
      rethrow;
    }
  }
}
