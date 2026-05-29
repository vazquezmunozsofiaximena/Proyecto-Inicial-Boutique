import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:myapp/src/auth/domain/entities/user_entity.dart';

class AuthRepository extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  StreamSubscription<firebase_auth.User?>? _authStateChangesSubscription;

  AuthRepository({firebase_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance {
    _authStateChangesSubscription =
        _firebaseAuth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        _user = await UserEntity.fromFirebaseUser(firebaseUser);
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  UserEntity? _user;

  UserEntity? get currentUser => _user;
  bool get isAuthenticated => _user != null;

  Future<UserEntity?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = result.user;
      if (firebaseUser != null) {
        _user = await UserEntity.fromFirebaseUser(firebaseUser);
        notifyListeners();
        return _user;
      }
      return null;
    } catch (e) {
      throw Exception('Error en el inicio de sesión: ${e.toString()}');
    }
  }

  Future<UserEntity?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = result.user;
      if (firebaseUser != null) {
        _user = await UserEntity.fromFirebaseUser(firebaseUser);
        notifyListeners();
        return _user;
      }
      return null;
    } catch (e) {
      throw Exception('Error en el registro: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> updateDisplayName(String newName) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(newName);
        // Actualizamos manualmente nuestro usuario local y notificamos
        _user = await UserEntity.fromFirebaseUser(firebaseUser);
        notifyListeners();
      } else {
        throw Exception('Usuario no autenticado');
      }
    } catch (e) {
      throw Exception('Error al actualizar el nombre: $e');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.updatePassword(newPassword);
      } else {
        throw Exception('Usuario no autenticado');
      }
    } catch (e) {
      throw Exception('Error al actualizar la contraseña: $e');
    }
  }

  @override
  void dispose() {
    _authStateChangesSubscription?.cancel();
    super.dispose();
  }
}
