import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // USUARIOS
  // ---------------------------------------------------------------------------

  Future<String> obtenerRolUsuario(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        return doc.get('rol') ?? 'becario';
      }
      return 'becario';
    } catch (e) {
      return 'becario';
    }
  }

  Future<List<Map<String, dynamic>>> obtenerBecarios() async {
    try {
      QuerySnapshot query = await _firestore
          .collection('usuarios')
          .where('rol', isEqualTo: 'becario')
          .get();

      return query.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error obteniendo becarios: $e");
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // TICKETS — streams
  // ---------------------------------------------------------------------------

  Stream<QuerySnapshot> obtenerTicketsRecientes() {
    return _firestore
        .collection('tickets')
        .orderBy('fecha', descending: true)
        .limit(3)
        .snapshots();
  }

  Stream<QuerySnapshot> obtenerTicketsPendientes() {
    return _firestore
        .collection('tickets')
        .where('estado', isEqualTo: 'pendiente')
        .snapshots();
  }

  /// Estado puede ser: 'pendiente', 'completado' o 'vencido'
  Stream<QuerySnapshot> obtenerTicketsPorEstado(String estado) {
    return _firestore
        .collection('tickets')
        .where('estado', isEqualTo: estado)
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  Stream<int> obtenerConteoTicketsAbiertos() {
    return _firestore
        .collection('tickets')
        .where('estado', isEqualTo: 'pendiente')
        .snapshots()
        .map((s) => s.docs.length);
  }

  // ---------------------------------------------------------------------------
  // INVENTARIO
  // ---------------------------------------------------------------------------

  Stream<QuerySnapshot> obtenerInventarioMaterial() {
    return _firestore.collection('inventario_material').snapshots();
  }

  Stream<int> obtenerConteoInventario() {
    return _firestore
        .collection('inventario_material')
        .snapshots()
        .map((s) => s.docs.length);
  }

  Future<List<Map<String, dynamic>>> buscarInventario(String query) async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('inventario_material').get();
      final q = query.toLowerCase();
      return snapshot.docs
          .map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['doc_id'] = doc.id;
            return data;
          })
          .where((item) =>
              (item['articulo'] ?? '').toString().toLowerCase().contains(q) ||
              (item['categoria'] ?? '').toString().toLowerCase().contains(q))
          .toList();
    } catch (e) {
      print("Error buscando inventario: $e");
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // LÓGICA DE VENCIMIENTO
  //
  // Regla de negocio:
  //   • 'Inventariar material del CET' → vence el VIERNES a las 12:00
  //   • Cualquier otro tipo            → vence el JUEVES a las 12:00
  //
  // Si hoy ya es ese día pero ya pasó el mediodía, o el día ya pasó en la
  // semana, se avanza a la semana siguiente para dar al menos un ciclo.
  // ---------------------------------------------------------------------------

  /// Calcula la DateTime exacta de vencimiento: 12:00:00 del Jueves o Viernes
  /// más próximo según el tipo de ticket.
  static DateTime calcularFechaVencimiento(String tipo) {
    final DateTime now = DateTime.now();

    // Día objetivo de la semana (1=lunes … 5=viernes)
    final int targetWeekday =
        (tipo == 'Inventariar material del CET') ? DateTime.friday : DateTime.thursday;

    int daysToAdd = targetWeekday - now.weekday;

    // Si ya pasó ese día esta semana, o es hoy pero ya pasó el mediodía → siguiente semana
    if (daysToAdd < 0 || (daysToAdd == 0 && now.hour >= 12)) {
      daysToAdd += 7;
    }

    final DateTime fechaBase = now.add(Duration(days: daysToAdd));

    // Fijar exactamente a las 12:00:00 (mediodía)
    return DateTime(
      fechaBase.year,
      fechaBase.month,
      fechaBase.day,
      12,
      0,
      0,
    );
  }

  /// Revisa todos los tickets 'pendiente' y, si su fecha_vencimiento
  /// (mediodía del día objetivo) ya pasó, los actualiza a 'vencido'.
  /// Llamar al iniciar AdminView y FiltradoTicketsScreen.
  Future<void> actualizarTicketsVencidos() async {
    try {
      final DateTime ahora = DateTime.now();
      final QuerySnapshot pendientes = await _firestore
          .collection('tickets')
          .where('estado', isEqualTo: 'pendiente')
          .get();

      for (final doc in pendientes.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final Timestamp? ts = data['fecha_vencimiento'] as Timestamp?;
        if (ts != null && ts.toDate().isBefore(ahora)) {
          await doc.reference.update({'estado': 'vencido'});
        }
      }
    } catch (e) {
      print("Error actualizando tickets vencidos: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // CREAR TICKET
  // Guarda también 'levantado_por' con el nombre del admin que creó el ticket.
  // Este campo se muestra al becario pero NO se muestra al admin en su vista.
  // ---------------------------------------------------------------------------

  Future<void> crearTicket({
    required String titulo,
    required String descripcion,
    required String prioridad,
    required String encargadoUid,
    required String encargadoNombre,
    required String tipo,
    required String salon,
  }) async {
    try {
      final String numeroTicket =
          "TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

      // Mediodía del jueves o viernes más próximo
      final DateTime fechaVencimiento = calcularFechaVencimiento(tipo);

      // Nombre del admin que levanta el ticket (oculto en la vista admin)
      final user = FirebaseAuth.instance.currentUser;
      final String levantadoPor = user?.displayName ?? 'Administrador';

      await _firestore.collection('tickets').add({
        'titulo': titulo,
        'descripcion': descripcion,
        'numero_ticket': numeroTicket,
        'prioridad': prioridad,
        'encargado_uid': encargadoUid,
        'encargado_nombre': encargadoNombre,
        'tipo': tipo,
        'salon': salon,
        'estado': 'pendiente',
        'fecha': FieldValue.serverTimestamp(),
        // Vence exactamente a las 12:00:00 del día objetivo
        'fecha_vencimiento': Timestamp.fromDate(fechaVencimiento),
        // Quién levantó el ticket (se muestra al becario, no al admin)
        'levantado_por': levantadoPor,
        // Campos que el becario rellenará al completar
        'cables_danados': 0,
        'evidencia_url': '',
        'observaciones': '',
        'pcs_autocad': 0,
        'pcs_no_encienden': 0,
        'pcs_sin_internet': 0,
      });
    } catch (e) {
      print("Error creando ticket: $e");
      rethrow;
    }
  }
}
