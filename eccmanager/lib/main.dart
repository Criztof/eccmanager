import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';

/*Cuenta de supercvisor:
Correo: prueba1@gmail.com
Contraseña: LLuvia_222

Cuenta de becario:
Correo: becario1@gmail.com
Contraseña: Fime2026

Cuenta de administrador:
Correo: admin1@gmail.com
Contraseña: Fime 2025
*/

void main() async {
  // Inicialización de Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Quita la etiqueta "Debug" de la esquina
      title: 'ECC Manager',

      // Configuración del Tema (Para que los controles nativos sean verdes)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        useMaterial3: true,
      ),

      home: const LoginScreen(),
    );
  }
}
