import 'package:flutter/material.dart';
import 'package:myapp/src/auth/data/repositories/auth_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  ProfileViewModel({required this.authRepository});
}