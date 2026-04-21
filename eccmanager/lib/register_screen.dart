import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Lista de dominios permitidos.
  final List<String> _dominiosPermitidos = [
    '@gmail.com',
    '@outlook.com',
    '@uanl.edu.mx',
  ];

  Future<void> _registrar() async {
    String email = _emailController.text.trim().toLowerCase();
    String password = _passwordController.text.trim();
    String nombre = _nombreController.text.trim();

    // 1. Validar que no haya campos vacíos
    if (email.isEmpty || password.isEmpty || nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor llena todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. FILTRO DE DOMINIO: Validar que el correo tenga una terminación permitida
    bool dominioValido = _dominiosPermitidos.any(
      (dominio) => email.endsWith(dominio),
    );

    if (!dominioValido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Usa un correo válido (@gmail, @outlook o @uanl.edu.mx)',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return; // Detiene la función, no llega a Firebase
    }

    setState(() => _isLoading = true);

    try {
      // 3. Crear la cuenta en Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Le actualizamos el nombre al perfil básico de Firebase
      await userCredential.user!.updateDisplayName(nombre);

      String uid = userCredential.user!.uid;

      // 4. EL CANDADO: Guardar su perfil en Firestore forzando el rol "becario"
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nombre': nombre,
        'correo': email,
        'rol': 'becario', // Forzado a becario, no hay forma de cambiarlo aquí
        'fecha_registro': FieldValue.serverTimestamp(),
      });

      // 5. Redirigir a la pantalla principal pasándole su rol de becario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen(rol: 'becario')),
          (route) =>
              false, // Elimina el historial para no regresar al login con el botón de "Atrás"
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Error al registrarse'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Crear Cuenta',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Regístrate para gestionar los rondines',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Inputs de Registro
              _CustomTextField(
                controller: _nombreController,
                icon: Icons.person_outline,
                hint: 'Nombre Completo',
              ),
              const SizedBox(height: 16),
              _CustomTextField(
                controller: _emailController,
                icon: Icons.email_outlined,
                hint: 'Correo electrónico',
              ),
              const SizedBox(height: 16),
              _CustomTextField(
                controller: _passwordController,
                icon: Icons.lock_outline,
                hint: 'Contraseña (mínimo 6 letras)',
                isPassword: true,
              ),

              const SizedBox(height: 30),

              // Botón de Registro
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Registrarse',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reutilizamos TextField 
class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool isPassword;

  const _CustomTextField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
