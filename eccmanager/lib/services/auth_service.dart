import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener el rol del usuario desde Firestore
  Future<String> obtenerRolUsuario(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return (doc.data() as Map<String, dynamic>)['rol'] ?? 'becario';
      }
      return 'becario';
    } catch (e) {
      return 'becario';
    }
  }

  // Iniciar sesión
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Registrar usuario
  Future<void> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );

    await userCredential.user!.updateDisplayName(nombre);

    await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
      'nombre': nombre,
      'correo': email,
      'rol': 'becario',
      'fecha_registro': FieldValue.serverTimestamp(),
    });
  }

  // Restablecer contraseña con verificación previa en Firestore
  Future<void> recuperarPassword(String email) async {
    try {
      // 1. Buscar en la colección 'usuarios' si el campo 'correo' coincide
      final querySnapshot = await _firestore
          .collection('usuarios')
          .where('correo', isEqualTo: email)
          .get();

      // 2. Si no se encuentra el documento, lanzamos error manual
      if (querySnapshot.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Este correo no está registrado en la base de datos de usuarios.',
        );
      }

      // 3. Si existe, enviar el correo de recuperación mediante Firebase Auth
      await _auth.sendPasswordResetEmail(email: email);
      
    } on FirebaseAuthException {
      rethrow; 
    } catch (e) {
      // Si cae aquí, puede ser un error de permisos (Rules) o de red
      throw FirebaseAuthException(
        code: 'error-verificacion',
        message: 'Error técnico al verificar: ${e.toString()}',
      );
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }
}