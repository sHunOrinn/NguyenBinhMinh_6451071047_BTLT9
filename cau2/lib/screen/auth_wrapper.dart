import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/repository/auth_repository.dart';
import 'auth/login_screen.dart';
import 'auth/home_screen.dart';

/// Wrapper tự động điều hướng dựa trên trạng thái đăng nhập.
/// - Đã đăng nhập → HomeScreen
/// - Chưa đăng nhập → LoginScreen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();

    return StreamBuilder<User?>(
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        // Đang kiểm tra trạng thái
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            ),
          );
        }

        // Đã đăng nhập
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // Chưa đăng nhập
        return const LoginScreen();
      },
    );
  }
}