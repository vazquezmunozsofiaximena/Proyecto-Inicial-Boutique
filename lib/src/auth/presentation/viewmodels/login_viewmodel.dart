import 'package:flutter/material.dart';
import 'package:myapp/src/auth/data/repository/auth_repository.dart';

class LoginViewModel with ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository);

  Future<bool> signIn(String email, String password) async {
    try {
      final user = await _authRepository.signInWithEmailAndPassword(email, password);
      return user != null;
    } catch (e) {
      rethrow; // Dejamos pasar el error para mostrarlo en la interfaz
    }
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authRepository.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return user != null;
    } catch (e) {
      rethrow;
    }
  }
}