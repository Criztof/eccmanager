import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SupervisorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Usuario ────────────────────────────────────────────────────────────────

  String obtenerNombreSupervisor() =>
      _auth.currentUser?.displayName ?? 'Supervisor';

  Future<void> cerrarSesion() async => _auth.signOut();

  // ── Usuarios — roles ───────────────────────────────────────────────────────

  Stream<QuerySnapshot> getUsuariosStream() =>
      _firestore.collection('usuarios').snapshots();

  Future<void> actualizarRolUsuario(String uid, String nuevoRol) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({'rol': nuevoRol});
    } catch (e) {
      print('Error al actualizar rol: $e');
      rethrow;
    }
  }

  // ── Tickets — streams ──────────────────────────────────────────────────────

  Stream<QuerySnapshot> obtenerTodosLosTickets() => _firestore
      .collection('tickets')
      .orderBy('fecha', descending: true)
      .snapshots();

  Stream<QuerySnapshot> obtenerTicketsPendientes() =>
      obtenerTicketsPorEstado('pendiente');

  Stream<QuerySnapshot> obtenerTicketsCompletados() =>
      obtenerTicketsPorEstado('completado');

  Stream<QuerySnapshot> obtenerTicketsVencidos() =>
      obtenerTicketsPorEstado('vencido');

  Stream<QuerySnapshot> obtenerTicketsPorEstado(String estado) => _firestore
      .collection('tickets')
      .where('estado', isEqualTo: estado)
      .orderBy('fecha', descending: true)
      .snapshots();

  // ── Filtrado en cliente — semana actual ────────────────────────────────────

  static DateTimeRange _rangoSemanaActual() {
    final ahora = DateTime.now();
    final inicioSemana = DateTime(
      ahora.year, ahora.month, ahora.day - (ahora.weekday - DateTime.monday),
    );
    return DateTimeRange(
        start: inicioSemana,
        end: inicioSemana.add(const Duration(days: 7)));
  }

  static List<QueryDocumentSnapshot> filtrarPorSemana(
    List<QueryDocumentSnapshot> docs, {
    String campoFecha = 'fecha',
  }) {
    final rango = _rangoSemanaActual();
    return docs.where((doc) {
      final ts = (doc.data() as Map<String, dynamic>)[campoFecha] as Timestamp?;
      if (ts == null) return false;
      final fecha = ts.toDate();
      return fecha.isAfter(rango.start) && fecha.isBefore(rango.end);
    }).toList();
  }

  // ── Tickets con evidencia ──────────────────────────────────────────────────

  Stream<QuerySnapshot> obtenerTicketsConEvidencia() => _firestore
      .collection('tickets')
      .where('estado', isEqualTo: 'completado')
      .orderBy('fecha_completado', descending: true)
      .snapshots();

  // ── Actualizar vencidos ────────────────────────────────────────────────────

  Future<void> actualizarTicketsVencidos() async {
    try {
      final ahora = DateTime.now();
      final pendientes = await _firestore
          .collection('tickets')
          .where('estado', isEqualTo: 'pendiente')
          .get();
      for (final doc in pendientes.docs) {
        final ts = (doc.data())['fecha_vencimiento'] as Timestamp?;
        if (ts != null && ts.toDate().isBefore(ahora)) {
          await doc.reference.update({'estado': 'vencido'});
        }
      }
    } catch (e) {
      print('Error actualizando tickets vencidos: $e');
    }
  }
}
