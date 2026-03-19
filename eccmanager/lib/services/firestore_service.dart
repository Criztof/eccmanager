import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // 1. LÓGICA DE ROLES
  // ==========================================

  // Obtener el rol del usuario que acaba de iniciar sesión
  Future<String> obtenerRolUsuario(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('usuarios').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.get('rol') ??
            'becario'; // Por defecto es becario si no tiene rol
      }
      return 'becario';
    } catch (e) {
      return 'becario';
    }
  }

  // ==========================================
  // 2. LÓGICA DE TICKETS (Híbrido)
  // ==========================================

  Future<void> crearTicketRondin(String salon, String adminUid) async {
    await _db.collection('tickets').add({
      'titulo': 'Rondín Salón $salon',
      'tipo': 'rutina_semanal',
      'estado': 'abierto',
      'asignado_a_uid': null,
      'fecha_creacion': FieldValue.serverTimestamp(),
      'creado_por': adminUid,
    });
  }

  Stream<QuerySnapshot> verBolsaDeTrabajo() {
    return _db
        .collection('tickets')
        .where('estado', isEqualTo: 'abierto')
        .where('asignado_a_uid', isNull: true)
        .snapshots();
  }

  Future<void> tomarTicket(String ticketId, String becarioUid) async {
    await _db.collection('tickets').doc(ticketId).update({
      'asignado_a_uid': becarioUid,
      'estado': 'en_progreso',
    });
  }

  Stream<QuerySnapshot> verMisTareas(String becarioUid) {
    return _db
        .collection('tickets')
        .where('asignado_a_uid', isEqualTo: becarioUid)
        .where('estado', isEqualTo: 'en_progreso')
        .snapshots();
  }

  // ==========================================
  // 3. LÓGICA DE INVENTARIO (Rondines)
  // ==========================================

  Future<void> actualizarEstadoSalon(
    String idSalon,
    int pcAlumnosOK,
    int pcMaestroOK,
    int defectuosas,
    int sinInternet,
    String nombreRevisor,
  ) async {
    await _db.collection('inventario_salones').doc(idSalon).update({
      'estado_actual': {
        'alumnos_ok': pcAlumnosOK,
        'maestro_ok': pcMaestroOK,
        'defectuosas': defectuosas,
        'sin_internet': sinInternet,
      },
      'auditoria': {
        'ultimo_revisor': nombreRevisor,
        'fecha': FieldValue.serverTimestamp(),
      },
    });
  }
}
