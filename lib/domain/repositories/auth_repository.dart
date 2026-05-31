import '../entities/app_user.dart';

/// Abstract contract for authentication, defined in the domain layer.
///
/// The presentation layer depends only on this interface (via Riverpod), never
/// on Firebase directly. The concrete [AuthRepositoryImpl] in the data layer
/// provides the implementation. This inversion is the heart of Clean
/// Architecture: high-level policy doesn't depend on low-level detail.
abstract interface class AuthRepository {
  /// Emits the current [AppUser] (with role from Firestore) whenever the auth
  /// state changes, or `null` when signed out.
  Stream<AppUser?> authStateChanges();

  /// Reads the currently signed-in user once, or `null` if none.
  Future<AppUser?> currentUser();

  /// Signs in with an [identifier] that is either an email or a NIK, resolving
  /// the NIK to an email via Firestore when needed.
  Future<AppUser> signIn({
    required String identifier,
    required String password,
  });

  Future<void> signOut();

  /// Sends a password-reset email (Forgot Password flow).
  Future<void> sendPasswordReset(String email);
}
