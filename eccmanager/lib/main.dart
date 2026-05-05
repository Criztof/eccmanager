import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  // 1. Garantiza que los bindings de Flutter estén listos
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inicializa Firebase con las opciones de tu proyecto
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ECC Manager',

      // 3. Configuración del Tema Global
      // Mantiene el color verde institucional en toda la app
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          primary: const Color(0xFF1B5E20),
          secondary: const Color(0xFF2E7D32),
        ),
        // Estilo global para botones para que se vean profesionales
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Fondo por defecto de las pantallas
        scaffoldBackgroundColor: const Color(0xFFF5F9F5),
      ),

      // 4. Punto de entrada de la aplicación
      home: const LoginScreen(),
    );
  }
}