import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_constants.dart';
import '../models/app_user_model.dart';

/// Talks directly to Firebase (Auth + Firestore). This is the only place that
/// knows about the Firebase SDK for authentication, so swapping or mocking the
/// backend later touches just this file.
class AuthRemoteDataSource {
  AuthRemoteDataSource({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(AppConstants.usersCollection);

  /// Streams the auth user and joins it with its Firestore profile so the role
  /// is always available downstream.
  Stream<AppUserModel?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _profileFor(user);
    });
  }

  Future<AppUserModel?> currentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _profileFor(user);
  }

  Future<AppUserModel> _profileFor(User user) async {
    try {
      // 8-second timeout so a slow/offline Firestore never blocks sign-in.
      final doc = await _users.doc(user.uid).get().timeout(
        const Duration(seconds: 8),
      );
      if (doc.exists) return AppUserModel.fromFirestore(doc);
    } catch (_) {
      // Timeout or permission error — fall back to Auth-only profile.
      // The user is authenticated; role defaults to employee.
    }
    return AppUserModel.fromFirebaseUser(user);
  }

  /// Resolves a NIK to its email when the identifier isn't already an email,
  /// then signs in. Returns the joined profile.
  Future<AppUserModel> signIn({
    required String identifier,
    required String password,
  }) async {
    final email = await _resolveEmail(identifier.trim());
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _profileFor(cred.user!);
  }

  Future<String> _resolveEmail(String identifier) async {
    if (identifier.contains('@')) return identifier;
    // NIK login: query users collection (requires `allow list: if true` rule).
    final snap = await _users
        .where('nik', isEqualTo: identifier)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'NIK tidak ditemukan. Periksa kembali NIK Anda.',
      );
    }
    final email = snap.docs.first.data()['email'] as String?;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Akun tidak memiliki email terdaftar.',
      );
    }
    return email;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());
}
