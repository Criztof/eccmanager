import 'package:firebase_auth/firebase_auth.dart';

class BecarioService {
  // Obtiene el nombre del usuario actual desde Firebase
  String obtenerNombreUsuario() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? 'Becario';
  }

  // Se encarga de cerrar la sesión en Firebase
  Future<void> cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
  }
}