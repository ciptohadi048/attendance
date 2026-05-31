import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/app_user.dart';

/// Data-layer representation of [AppUser]. Adds Firestore (de)serialization.
///
/// Extending the domain entity means the rest of the app can treat a model as
/// an [AppUser] without caring how it was loaded — the mapping concern stays
/// confined to this file.
class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    required super.nik,
    required super.name,
    required super.email,
    super.role,
    super.department,
    super.position,
    super.photoUrl,
    super.phoneNumber,
  });

  /// Build from a Firestore document (`users/{uid}`).
  factory AppUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    return AppUserModel(
      uid: doc.id,
      nik: data['nik'] as String? ?? '',
      name: data['name'] as String? ?? 'Karyawan',
      email: data['email'] as String? ?? '',
      role: UserRole.fromString(data['role'] as String?),
      department: data['department'] as String?,
      position: data['position'] as String?,
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
    );
  }

  /// Fallback when a Firebase Auth user exists but has no Firestore profile yet.
  factory AppUserModel.fromFirebaseUser(fb.User user) {
    return AppUserModel(
      uid: user.uid,
      nik: '',
      name: user.displayName ?? 'Karyawan',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nik': nik,
      'name': name,
      'email': email,
      'role': role.name,
      'department': department,
      'position': position,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
