import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class UserEntity {
  final String uid;
  final String? email;
  final String? displayName;
  final bool isAdmin;

  UserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.isAdmin = false,
  });

  // Convert a Firebase User object to our UserEntity
  static Future<UserEntity> fromFirebaseUser(firebase_auth.User firebaseUser) async {
    bool isAdmin = false;
    try {
      // Consulta a Firestore para obtener el rol del usuario
      final docSnapshot = await FirebaseFirestore.instance
          .collection('roles')
          .doc(firebaseUser.uid)
          .get();

      if (docSnapshot.exists && docSnapshot.data()!['isAdmin'] == true) {
        isAdmin = true;
      }
    } catch (e, s) {
      // Si hay un error (ej. permisos), asumimos que no es admin.
      developer.log(
        'Error al verificar el rol de administrador',
        name: 'UserEntity',
        error: e,
        stackTrace: s,
      );
      isAdmin = false;
    }

    return UserEntity(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      isAdmin: isAdmin,
    );
  }
}
