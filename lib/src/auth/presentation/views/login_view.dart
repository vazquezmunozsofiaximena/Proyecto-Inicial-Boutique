import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/auth/data/repository/auth_repository.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'CLIENTE'; // Controla el rol: 'CLIENTE' o 'ADMIN'
  bool _isRegistering = false;     // Controla el formulario de registro (Solo clientes)
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authRepo = context.read<AuthRepository>();

    try {
      if (_isRegistering && _selectedRole == 'CLIENTE') {
        // Registro simplificado al extremo: Solo requiere correo y contraseña
        await authRepo.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          nombre: 'Cliente',
          apellido: 'Boutique',
          telefono: '00000000',
          direccion: 'No especificada',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Registro exitoso! Por favor inicia sesión ahora.'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isRegistering = false;
            _passwordController.clear();
          });
        }
      } else {
        // Inicio de sesión unificado (Tanto para Admin como para Cliente)
        await authRepo.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- SELECTOR DE DOS OPCIONES DE INICIO ---
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRole = 'CLIENTE';
                                  _emailController.clear();
                                  _passwordController.clear();
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedRole == 'CLIENTE' ? theme.primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'Soy Cliente',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedRole == 'CLIENTE' ? Colors.white : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRole = 'ADMIN';
                                  _isRegistering = false; // Administradores no se registran públicamente
                                  _emailController.text = 'admin@boutique.com'; // Ayuda visual rápida
                                  _passwordController.clear();
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedRole == 'ADMIN' ? Colors.purple : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'Soy Administrador',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedRole == 'ADMIN' ? Colors.white : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Icon(
                      _selectedRole == 'ADMIN' 
                          ? Icons.admin_panel_settings_outlined 
                          : (_isRegistering ? Icons.person_add_outlined : Icons.lock_outline),
                      size: 64,
                      color: _selectedRole == 'ADMIN' ? Colors.purple : theme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedRole == 'ADMIN' 
                          ? 'Acceso Administrador' 
                          : (_isRegistering ? 'Crear Cuenta Cliente' : 'Ingreso Clientes'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico',
                        prefixIcon: const Icon(Icons.email),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _selectedRole == 'ADMIN' ? Colors.purple : theme.primaryColor),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Introduce el correo' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _selectedRole == 'ADMIN' ? Colors.purple : theme.primaryColor),
                        ),
                      ),
                      validator: (value) => value == null || value.length < 6 ? 'Mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedRole == 'ADMIN' ? Colors.purple : theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              _isRegistering ? 'REGISTRARME' : 'INICIAR SESIÓN',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                    
                    if (_selectedRole == 'CLIENTE') ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _isRegistering = !_isRegistering;
                                  _formKey.currentState?.reset();
                                });
                              },
                        child: Text(
                          _isRegistering
                              ? '¿Ya tienes una cuenta? Inicia Sesión'
                              : '¿No tienes cuenta? Regístrate aquí con solo correo',
                          style: TextStyle(color: theme.primaryColor),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}