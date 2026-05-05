import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupervisorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener el flujo de usuarios en tiempo real
  Stream<QuerySnapshot> getUsuariosStream() {
    return _firestore.collection('usuarios').snapshots();
  }

  // Actualizar el rol de un usuario
  Future<void> actualizarRolUsuario(String uid, String nuevoRol) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({
        'rol': nuevoRol,
      });
    } catch (e) {
      print("Error al actualizar rol: $e");
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  // Obtener nombre del usuario actual
  String getObtenerNombreSupervisor() {
    return _auth.currentUser?.displayName ?? 'Supervisor';
  }
}