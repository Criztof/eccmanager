import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart'; // Solo necesitas importar esto una vez

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

      // AQUÍ ESTÁ LA CORRECCIÓN:
      // Solo llamamos a la pantalla, sin pasarle nada adentro.
      home: const LoginScreen(),
    );
  }
}
