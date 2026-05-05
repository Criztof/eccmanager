import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener el rol del usuario para validación
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

  // Obtener lista de usuarios con el rol 'becario'
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

  // Stream de tickets recientes (limitado a 3)
  Stream<QuerySnapshot> obtenerTicketsRecientes() {
    return _firestore
        .collection('tickets')
        .orderBy('fecha', descending: true)
        .limit(3)
        .snapshots();
  }

  // Stream de todos los tickets pendientes (para conteo en hero)
  Stream<QuerySnapshot> obtenerTicketsPendientes() {
    return _firestore
        .collection('tickets')
        .where('estado', isEqualTo: 'pendiente')
        .snapshots();
  }

  // Stream de tickets filtrados por estado (pendiente / completado / vencido)
  Stream<QuerySnapshot> obtenerTicketsPorEstado(String estado) {
    return _firestore
        .collection('tickets')
        .where('estado', isEqualTo: estado)
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  // Stream de inventario para la vista de inventario_material
  Stream<QuerySnapshot> obtenerInventarioMaterial() {
    return _firestore.collection('inventario_material').snapshots();
  }

  // Buscar documentos en inventario_material por nombre de artículo (búsqueda local)
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

  // Conteo de documentos en inventario_material (número de tipos/artículos únicos)
  Stream<int> obtenerConteoInventario() {
    return _firestore.collection('inventario_material').snapshots().map(
          (snapshot) => snapshot.docs.length,
        );
  }

  // Conteo de tickets abiertos (pendientes)
  Stream<int> obtenerConteoTicketsAbiertos() {
    return _firestore
        .collection('tickets')
        .where('estado', isEqualTo: 'pendiente')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Verificar y actualizar tickets vencidos (llamar periódicamente o al abrir la app)
  Future<void> actualizarTicketsVencidos() async {
    try {
      final ahora = DateTime.now();
      final QuerySnapshot pendientes = await _firestore
          .collection('tickets')
          .where('estado', isEqualTo: 'pendiente')
          .get();

      for (var doc in pendientes.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final fechaVencimiento = data['fecha_vencimiento'] as Timestamp?;
        if (fechaVencimiento != null &&
            fechaVencimiento.toDate().isBefore(ahora)) {
          await doc.reference.update({'estado': 'vencido'});
        }
      }
    } catch (e) {
      print("Error actualizando tickets vencidos: $e");
    }
  }

  // Crear nuevo ticket con lógica de autoasignación de fechas y valores vacíos
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
      // Número de ticket automático usando milisegundos para ser único
      String numeroTicket =
          "TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

      // Cálculo de fecha de vencimiento (Jueves o Viernes más cercano)
      DateTime now = DateTime.now();
      int targetDay = (tipo == 'Inventariar material del CET')
          ? DateTime.friday
          : DateTime.thursday;

      int daysToAdd = targetDay - now.weekday;
      if (daysToAdd <= 0) {
        daysToAdd += 7;
      }
      DateTime fechaVencimiento = now.add(Duration(days: daysToAdd));

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
        'fecha_vencimiento': Timestamp.fromDate(fechaVencimiento),
        // Valores que el becario rellenará
        'cables_danados': 0,
        'evidencia_url': "",
        'observaciones': "",
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
