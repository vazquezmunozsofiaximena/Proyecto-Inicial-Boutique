import 'package:flutter/material.dart';
import 'package:myapp/src/auth/data/repositories/auth_repository.dart';
import 'package:myapp/src/auth/domain/entities/user_entity.dart';

class EditProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  EditProfileViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserEntity? get currentUser => _authRepository.currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  Future<void> updateDisplayName(String newName) async {
    if (newName.isEmpty) {
      _errorMessage = "El nombre no puede estar vacío.";
      notifyListeners();
      return;
    }
    _setLoading(true);
    _clearMessages();
    try {
      await _authRepository.updateDisplayName(newName);
      _successMessage = "¡Nombre actualizado con éxito!";
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePassword(String newPassword, String confirmPassword) async {
    if (newPassword.isEmpty || newPassword != confirmPassword) {
      _errorMessage = "Las contraseñas no coinciden o están vacías.";
      notifyListeners();
      return;
    }
    _setLoading(true);
    _clearMessages();
    try {
      await _authRepository.updatePassword(newPassword);
      _successMessage = "¡Contraseña actualizada con éxito!";
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }
}
