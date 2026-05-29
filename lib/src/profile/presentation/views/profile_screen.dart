import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/auth/data/repository/auth_repository.dart';
import 'package:go_router/go_router.dart'; // <--- AGREGA ESTA LÍNEA AQUÍ ARRIBA

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = context.read<AuthRepository>();
    final user = authRepo.currentUser;

    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Boutique Elegance', 
    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)
  ),
  backgroundColor: const Color(0xFFC8A2C8), // Color Lila original de tu tienda
  elevation: 2,
  // LEADING añade manualmente el botón de regreso que navega al Home sin romper el historial
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black87),
    onPressed: () => context.go('/'), // Te regresa de golpe a la pantalla principal
  ),
),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 80, color: Colors.purple),
              const SizedBox(height: 12),
              Text(user?.email ?? 'Sin correo', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () => authRepo.signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('CERRAR SESIÓN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}