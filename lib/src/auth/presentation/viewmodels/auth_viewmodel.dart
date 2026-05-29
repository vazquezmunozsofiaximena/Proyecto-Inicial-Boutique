import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/auth/data/repository/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? get user => _authRepository.currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final userResult = await _authRepository.signInWithEmailAndPassword(email, password);
      if (userResult == null) {
        _setErrorMessage('Error en el inicio de sesión. Por favor, comprueba tus credenciales.');
        return false;
      }
      return true;
    } catch (e) {
      _setErrorMessage(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } final {
      _setLoading(false);
    }
  }

  Future<bool> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String telefono,
    required String direccion,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final userResult = await _authRepository.createUserWithEmailAndPassword(
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        direccion: direccion,
      );
      if (userResult == null) {
        _setErrorMessage('Error en el registro. Por favor, inténtalo de nuevo.');
        return false;
      }
      return true;
    } catch (e) {
      _setErrorMessage(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}