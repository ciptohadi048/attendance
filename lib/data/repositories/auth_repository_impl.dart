import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Concrete [AuthRepository] backed by [AuthRemoteDataSource].
///
/// In a larger app this layer is where you'd combine remote + local caches or
/// add cross-cutting concerns. Here it stays thin, delegating to the data
/// source while exposing only domain types to the rest of the app.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Stream<AppUser?> authStateChanges() => _remote.authStateChanges();

  @override
  Future<AppUser?> currentUser() => _remote.currentUser();

  @override
  Future<AppUser> signIn({
    required String identifier,
    required String password,
  }) =>
      _remote.signIn(identifier: identifier, password: password);

  @override
  Future<void> signOut() => _remote.signOut();

  @override
  Future<void> sendPasswordReset(String email) =>
      _remote.sendPasswordReset(email);
}
