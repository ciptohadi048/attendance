import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/auth_failure.dart';
import '../../core/services/shared_prefs_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

// -----------------------------------------------------------------------------
// Infrastructure providers (Firebase singletons) — the composition root.
// Riverpod is our dependency-injection container: each layer asks for the layer
// below it via `ref`, and nothing constructs its own dependencies.
// -----------------------------------------------------------------------------

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

/// Overridden in `main()` once SharedPreferences has been initialized.
final sharedPrefsServiceProvider = Provider<SharedPrefsService>((ref) {
  throw UnimplementedError(
    'sharedPrefsServiceProvider must be overridden in main()',
  );
});

// -----------------------------------------------------------------------------
// Data + domain wiring
// -----------------------------------------------------------------------------

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

/// The single source of truth for "who is logged in". Combines Firebase Auth
/// state with the user's Firestore profile (so the role is included). The
/// router and any screen can watch this reactively.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

// -----------------------------------------------------------------------------
// Auth controller — handles the imperative actions (sign in / out / reset) and
// exposes their progress as an AsyncValue the UI can react to (loading/error).
// -----------------------------------------------------------------------------

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  AuthRepository get _repo => ref.read(authRepositoryProvider);
  SharedPrefsService get _prefs => ref.read(sharedPrefsServiceProvider);

  Future<bool> signIn({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await _repo.signIn(identifier: identifier, password: password);
      await _prefs.setRememberMe(rememberMe, identifier: identifier);
    });
    state = result;
    return !result.hasError;
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.signOut());
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _repo.sendPasswordReset(email);
      return null; // success
    } catch (e) {
      return authErrorMessage(e);
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);
