import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:customer_app/models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserModel?> signIn(String email, String password) async {
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

  Future<UserModel?> signUp(String email, String password, String role, {Map<String, dynamic>? extraData}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        final status = (role == 'farmer') ? 'onboarding' : 'approved';
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

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Reset password failed: $e");
      rethrow;
    }
  }

  Future<UserModel?> getUserDetails(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  Stream<UserModel?> userStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            return UserModel.fromMap(snapshot.data()!, uid);
          }
          return null;
        });
  }
}
