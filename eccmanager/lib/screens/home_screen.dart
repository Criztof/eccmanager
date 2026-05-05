import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'admin_view.dart';
import 'becario_view.dart';
import 'supervisor_view.dart';

class HomeScreen extends StatelessWidget {
  final String rol;

  const HomeScreen({super.key, required this.rol});

  @override
  Widget build(BuildContext context) {
    // IMPORTANTE: Se eliminó 'const' de los retornos porque las vistas
    // manejan datos dinámicos de Firebase.
    
    if (rol == 'admin') {
      return AdminView(); 
    } else if (rol == 'supervisor') {
      return PantallaSupervisor(); // <-- Aquí estaba el error, ahora sin 'const'
    } else {
      return PantallaBecario();
    }
  }

  // Función para cerrar sesión (puedes llamarla desde los botones de logout de tus vistas)
  static void confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}