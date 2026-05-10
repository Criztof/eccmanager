import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BecarioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // USUARIO
  // ---------------------------------------------------------------------------

  String obtenerNombreUsuario() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? 'Becario';
  }

  String obtenerUidUsuario() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<void> cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
  }

  // ---------------------------------------------------------------------------
  // TICKETS DEL BECARIO
  // ---------------------------------------------------------------------------

  /// Tickets pendientes asignados al becario actual
  Stream<QuerySnapshot> obtenerMisTicketsPendientes() {
    final uid = obtenerUidUsuario();
    return _firestore
        .collection('tickets')
        .where('encargado_uid', isEqualTo: uid)
        .where('estado', isEqualTo: 'pendiente')
        .snapshots();
  }

  /// TODOS los tickets completados del becario actual.
  /// El filtrado por semana se hace en el cliente para evitar requerir
  /// índices compuestos en Firestore que causaban que el stream fallara
  /// silenciosamente y devolviera 0 documentos.
  Stream<QuerySnapshot> obtenerMisTicketsCompletados() {
    final uid = obtenerUidUsuario();
    return _firestore
        .collection('tickets')
        .where('encargado_uid', isEqualTo: uid)
        .where('estado', isEqualTo: 'completado')
        .snapshots();
  }

  /// Filtra en memoria los tickets completados de la SEMANA ACTUAL.
  /// Lunes 00:00 → Domingo 23:59:59
  static List<QueryDocumentSnapshot> filtrarCompletadosSemana(
      List<QueryDocumentSnapshot> docs) {
    final ahora = DateTime.now();
    final diasDesdeElLunes = ahora.weekday - DateTime.monday;
    final inicioSemana = DateTime(
      ahora.year,
      ahora.month,
      ahora.day - diasDesdeElLunes,
    );
    final finSemana = inicioSemana.add(const Duration(days: 7));

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final ts = data['fecha_completado'] as Timestamp?;
      if (ts == null) return false;
      final fecha = ts.toDate();
      return fecha.isAfter(inicioSemana) &&
          fecha.isBefore(finSemana);
    }).toList();
  }

  /// Filtra en memoria los tickets completados HOY.
  static List<QueryDocumentSnapshot> filtrarCompletadosHoy(
      List<QueryDocumentSnapshot> docs) {
    final ahora = DateTime.now();
    final inicioDia = DateTime(ahora.year, ahora.month, ahora.day);
    final finDia = inicioDia.add(const Duration(days: 1));

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final ts = data['fecha_completado'] as Timestamp?;
      if (ts == null) return false;
      final fecha = ts.toDate();
      return fecha.isAfter(inicioDia) && fecha.isBefore(finDia);
    }).toList();
  }

  /// Actualiza el ticket al completarlo con los datos del becario
  Future<void> completarTicket({
    required String ticketId,
    required int pcsAutocad,
    required int pcsSinInternet,
    required int pcsNoEncienden,
    required int cablesDanados,
    required String observaciones,
    required String evidenciaUrl,
  }) async {
    await _firestore.collection('tickets').doc(ticketId).update({
      'estado': 'completado',
      'fecha_completado': FieldValue.serverTimestamp(),
      'pcs_autocad': pcsAutocad,
      'pcs_sin_internet': pcsSinInternet,
      'pcs_no_encienden': pcsNoEncienden,
      'cables_danados': cablesDanados,
      'observaciones': observaciones,
      'evidencia_url': evidenciaUrl,
    });
  }

  // ---------------------------------------------------------------------------
  // INVENTARIO MATERIAL
  // ---------------------------------------------------------------------------

  Stream<QuerySnapshot> obtenerInventarioMaterial() {
    return _firestore.collection('inventario_material').snapshots();
  }

  Future<List<String>> obtenerCategoriasInventario() async {
    final snap = await _firestore.collection('inventario_material').get();
    final cats = snap.docs
        .map((d) => (d.data()['categoria'] ?? '').toString().trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    cats.sort();
    return cats;
  }

  Future<void> agregarArticuloInventario({
    required String articulo,
    required String categoria,
    required String estado,
    required int cantidad,
  }) async {
    await _firestore.collection('inventario_material').add({
      'articulo': articulo,
      'categoria': categoria,
      'estado': estado,
      'cantidad': cantidad,
      'solicitados': 0,
    });
  }

  // ---------------------------------------------------------------------------
  // INVENTARIO SALONES
  // ---------------------------------------------------------------------------

  Stream<QuerySnapshot> obtenerInventarioSalones() {
    return _firestore.collection('inventario_salones').snapshots();
  }

  Future<List<String>> obtenerSoftwaresExistentes() async {
    final snap = await _firestore.collection('inventario_salones').get();
    final softwares = snap.docs
        .map((d) =>
            (d.data()['software_asignado'] ?? '').toString().trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    softwares.sort();
    return softwares;
  }

  Future<void> agregarSalon({
    required String numeroSala,
    required int alumnos,
    required int maestro,
    required String softwareAsignado,
  }) async {
    await _firestore.collection('inventario_salones').add({
      'numero_sala': numeroSala,
      'salon': numeroSala,
      'equipos': {
        'alumnos': alumnos,
        'maestro': maestro,
      },
      'software_asignado': softwareAsignado,
    });
  }
}
