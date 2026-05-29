import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository with ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  bool _isAdmin = false;
  bool _isLoading = true;

  AuthRepository({required FirebaseAuth firebaseAuth, required FirebaseFirestore firestore})
      : _firebaseAuth = firebaseAuth,
        _firestore = firestore {
    _firebaseAuth.authStateChanges().listen((user) async {
      await checkAdminStatus();
      _isLoading = false;
      notifyListeners();
    });
  }

  User? get currentUser => _firebaseAuth.currentUser;
  bool get isAuthenticated => currentUser != null;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;

  Future<void> checkAdminStatus() async {
    final user = _firebaseAuth.currentUser;
    bool previousAdminStatus = _isAdmin;
    if (user == null) {
      _isAdmin = false;
    } else {
      try {
        final doc = await _firestore.collection('usuarios').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          _isAdmin = data['role'] == 'admin';
        } else {
          _isAdmin = false;
        }
      } catch (e) {
        debugPrint('Error al verificar el rol de administrador en Firestore: $e');
        _isAdmin = false;
      }
    }
    if (_isAdmin != previousAdminStatus) {
      notifyListeners();
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    await checkAdminStatus();
    return userCredential.user;
  }

  // Ahora los campos adicionales son opcionales y toman valores por defecto
  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String nombre = 'Usuario',
    String apellido = 'Boutique',
    String telefono = '00000000',
    String direccion = 'No especificada',
  }) async {
    if (email.trim().toLowerCase() == 'admin@boutique.com') {
      throw Exception('No está permitido registrar administradores desde el formulario público.');
    }

    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    
    final user = userCredential.user;
    if (user != null) {
      // 1. Guardar en la colección reactiva de roles de usuario
      await _firestore.collection('usuarios').doc(user.uid).set({
        'uid': user.uid,
        'email': email.trim(),
        'role': 'cliente',
        'nombre': nombre.trim(),
      });

      // 2. Guardar el documento detallado en la colección de clientes (Igual al diagrama)
      await _firestore.collection('clientes').doc(user.uid).set({
        'id_cliente': user.uid,
        'nombre': nombre.trim(),
        'apellido': apellido.trim(),
        'email': email.trim(),
        'telefono': telefono.trim(),
        'direccion': direccion.trim(),
        'fecha_registro': FieldValue.serverTimestamp(),
      });

      await signOut();
    }

    return user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _isAdmin = false;
    notifyListeners();
  }
}