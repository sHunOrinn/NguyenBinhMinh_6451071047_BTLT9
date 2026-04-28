import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  User? get currentUser => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _authService.signUpWithEmail(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _authService.signInWithEmail(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  String getErrorMessage(String code) {
    return _authService.getErrorMessage(code);
  }
}