import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'formulario_rondin_screen.dart';
import 'becario_inventario_material_screen.dart';
import 'becario_inventario_salones_screen.dart';
import '../services/becario_service.dart';

class PantallaBecario extends StatefulWidget {
  const PantallaBecario({super.key});

  @override
  State<PantallaBecario> createState() => _PantallaBecarioState();
}

class _PantallaBecarioState extends State<PantallaBecario> {
  final BecarioService _becarioService = BecarioService();

  static const Color verdeUANL = Color(0xFF1B5E20);
  static const Color fondoGrisaceo = Color(0xFFF5F9F5);
  static const Color textoNegro = Color(0xFF1D261D);

  // Formatea Timestamp como "dd/MM/yyyy HH:mm"
  String _formatFechaHora(Timestamp? ts) {
    if (ts == null) return 'Sin fecha';
    final d = ts.toDate();
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year} $h:$m';
  }

  // Formatea "Completado a las HH:mm del dd/MM"
  String _formatCompletado(Timestamp? ts) {
    if (ts == null) return 'Completado esta semana';
    final d = ts.toDate();
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    final dia = d.day.toString().padLeft(2, '0');
    final mes = d.month.toString().padLeft(2, '0');
    return 'Completado el $dia/$mes a las $h:$m';
  }

  // Muestra detalle de ticket completado
  void _mostrarDetalleCompletado(
      BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (_, sc) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: sc,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    data['titulo'] ?? 'Ticket sin título',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: verdeUANL),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('COMPLETADO',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _detalleRow(Icons.meeting_room_outlined, 'Salón',
                      data['salon'] ?? 'N/A'),
                  _detalleRow(Icons.category_outlined, 'Tipo',
                      data['tipo'] ?? 'N/A'),
                  _detalleRow(
                      Icons.calendar_today_outlined,
                      'Creado',
                      _formatFechaHora(data['fecha'] as Timestamp?)),
                  _detalleRow(
                      Icons.check_circle_outline,
                      'Completado',
                      _formatFechaHora(
                          data['fecha_completado'] as Timestamp?)),
                  if ((data['levantado_por'] ?? '').isNotEmpty)
                    _detalleRow(Icons.person_outline, 'Solicitado por',
                        data['levantado_por']),
                  const SizedBox(height: 8),
                  // Prioridad
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.grey),
                      const SizedBox(width: 10),
                      const Text('Prioridad: ',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(
                                  data['prioridad'] ?? '')
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (data['prioridad'] ?? 'N/A').toUpperCase(),
                          style: TextStyle(
                              color: _getPriorityColor(
                                  data['prioridad'] ?? ''),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Descripción',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(data['descripcion'] ?? 'Sin descripción',
                        style: const TextStyle(color: Colors.black87)),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text('Información del reporte',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: verdeUANL)),
                  const SizedBox(height: 12),
                  _detalleRow(Icons.cable, 'Cables dañados',
                      '${data['cables_danados'] ?? 0}'),
                  _detalleRow(Icons.computer, 'PCs no encienden',
                      '${data['pcs_no_encienden'] ?? 0}'),
                  _detalleRow(Icons.wifi_off, 'PCs sin internet',
                      '${data['pcs_sin_internet'] ?? 0}'),
                  _detalleRow(Icons.design_services, 'PCs con AutoCAD',
                      '${data['pcs_autocad'] ?? 0}'),
                  const SizedBox(height: 8),
                  const Text('Observaciones',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      (data['observaciones'] ?? '').isNotEmpty
                          ? data['observaciones']
                          : 'Sin observaciones',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  // Evidencia: muestra la imagen si existe
                  if ((data['evidencia_url'] ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Evidencia fotográfica',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        data['evidencia_url'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey.shade100,
                            child: const Center(
                                child: CircularProgressIndicator(
                                    color: verdeUANL)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            color: Colors.grey.shade100,
                            child: const Center(
                                child: Text('No se pudo cargar la imagen',
                                    style:
                                        TextStyle(color: Colors.grey))),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verdeUANL,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar',
                        style:
                            TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getPriorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _detalleRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 10),
          Text('$label: ',
              style:
                  const TextStyle(color: Colors.grey, fontSize: 15)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String userName = _becarioService.obtenerNombreUsuario();

    return Scaffold(
      backgroundColor: fondoGrisaceo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Tareas de Hoy',
                style: TextStyle(
                  color: textoNegro,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: verdeUANL.withOpacity(0.1),
                child: Text(
                  userName.isNotEmpty
                      ? userName.substring(0, 1).toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: verdeUANL,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tarjeta de progreso ────────────────────────────────────────
            _buildProgressCard(),
            const SizedBox(height: 25),

            // ── Acceso rápido ──────────────────────────────────────────────
            Row(
              children: [
                _buildQuickAccess(
                  'Material',
                  'INVENTARIO',
                  Icons.inventory_2_outlined,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const BecarioInventarioMaterialScreen()),
                  ),
                ),
                const SizedBox(width: 15),
                _buildQuickAccess(
                  'Software',
                  'SALONES',
                  Icons.computer_outlined,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const BecarioInventarioSalonesScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ── Pendientes desde Firestore ─────────────────────────────────
            const Text(
              'PENDIENTES',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 15),

            StreamBuilder<QuerySnapshot>(
              stream: _becarioService.obtenerMisTicketsPendientes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: verdeUANL));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style:
                              const TextStyle(color: Colors.red)));
                }
                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        '¡Sin pendientes por ahora! 🎉',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 15),
                      ),
                    ),
                  );
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data =
                        doc.data() as Map<String, dynamic>;
                    return _buildTicketPendienteCard(
                      context,
                      ticketId: doc.id,
                      titulo: data['titulo'] ?? 'Sin título',
                      salon: data['salon'] ?? 'N/A',
                      descripcion: data['descripcion'] ?? '',
                      tipo: data['tipo'] ?? '',
                      prioridad: data['prioridad'] ?? 'Media',
                      fechaVencimiento:
                          data['fecha_vencimiento'] as Timestamp?,
                      levantadoPor: data['levantado_por'] ?? '',
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 30),

            // ── Completadas esta semana ────────────────────────────────────
            const Text(
              'COMPLETADAS ESTA SEMANA',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 15),

            // Se usa el stream de todos los completados y se filtra en cliente
            // por semana actual para evitar el índice compuesto en Firestore.
            StreamBuilder<QuerySnapshot>(
              stream: _becarioService.obtenerMisTicketsCompletados(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: verdeUANL));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style:
                              const TextStyle(color: Colors.red)));
                }

                // Filtrado en cliente: solo tickets completados esta semana
                final docsEstaSemana = snapshot.hasData
                    ? BecarioService.filtrarCompletadosSemana(
                        snapshot.data!.docs)
                    : <QueryDocumentSnapshot>[];

                if (docsEstaSemana.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                          'Aún no has completado tareas esta semana.',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return Column(
                  children: docsEstaSemana.map((doc) {
                    final data =
                        doc.data() as Map<String, dynamic>;
                    return _buildCompletedTaskCard(
                      context: context,
                      data: data,
                      horarioCompleto: _formatCompletado(
                          data['fecha_completado'] as Timestamp?),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: verdeUANL,
        shape: const CircleBorder(),
        elevation: 5,
        child: const Text(
          'ECC',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home_filled, color: verdeUANL),
                  Text('Inicio',
                      style: TextStyle(color: verdeUANL, fontSize: 10)),
                ],
              ),
              const SizedBox(width: 48),
              GestureDetector(
                onTap: () async {
                  await _becarioService.cerrarSesion();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                    );
                  }
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout_outlined, color: Colors.grey),
                    Text('Salir',
                        style:
                            TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── TARJETA DE PROGRESO ──────────────────────────────────────────────────────
  // total = pendientes actuales + completados esta semana
  // Al completar un ticket: pendientes baja 1, completados sube 1 → total estable
  // y el numerador sube correctamente mostrando 1/1 en vez de 0/0.
  Widget _buildProgressCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _becarioService.obtenerMisTicketsPendientes(),
      builder: (context, snapPend) {
        return StreamBuilder<QuerySnapshot>(
          // Usamos el stream simple (sin filtro de fecha en Firestore)
          stream: _becarioService.obtenerMisTicketsCompletados(),
          builder: (context, snapComp) {
            final pendientes = snapPend.data?.docs.length ?? 0;

            // Filtramos en cliente para contar solo los de esta semana
            final completadosSemana = snapComp.hasData
                ? BecarioService.filtrarCompletadosSemana(
                    snapComp.data!.docs)
                : <QueryDocumentSnapshot>[];
            final completados = completadosSemana.length;

            final total = pendientes + completados;
            final progreso =
                total > 0 ? completados / total : 0.0;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: verdeUANL,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: verdeUANL.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PROGRESO SEMANAL',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Text(
                        '$completados/$total',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 44,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        'Completadas',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: progreso,
                      backgroundColor: Colors.black12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── BOTÓN ACCESO RÁPIDO ──────────────────────────────────────────────────────
  Widget _buildQuickAccess(
    String titulo,
    String subtitulo,
    IconData icono,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F7F3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono,
                    color: const Color(0xFF65AE69), size: 22),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                        overflow: TextOverflow.ellipsis),
                    Text(subtitulo,
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── TARJETA TICKET PENDIENTE ─────────────────────────────────────────────────
  Widget _buildTicketPendienteCard(
    BuildContext context, {
    required String ticketId,
    required String titulo,
    required String salon,
    required String descripcion,
    required String tipo,
    required String prioridad,
    required Timestamp? fechaVencimiento,
    required String levantadoPor,
  }) {
    Color prioColor;
    switch (prioridad.toLowerCase()) {
      case 'alta':
        prioColor = Colors.red;
        break;
      case 'media':
        prioColor = const Color(0xFFEF9E4E);
        break;
      default:
        prioColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FormularioRondinScreen(
                  ticketId: ticketId,
                  salon: salon,
                  titulo: titulo,
                  descripcion: descripcion,
                  tipo: tipo,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila superior: vencimiento + prioridad
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F4F1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Vence: ${_formatFechaHora(fechaVencimiento)}',
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: prioColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 12, color: Color(0xFFEF9E4E)),
                          const SizedBox(width: 4),
                          Text(
                            prioridad.toUpperCase(),
                            style: TextStyle(
                                color: prioColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Título
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 6),
                // Salón
                Row(
                  children: [
                    const Icon(Icons.meeting_room_outlined,
                        color: Colors.grey, size: 15),
                    const SizedBox(width: 4),
                    Text('Salón $salon',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13)),
                  ],
                ),
                // Solicitado por (solo si existe)
                if (levantadoPor.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          color: Colors.grey, size: 15),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Solicitado por: $levantadoPor',
                          style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
                // Descripción
                if (descripcion.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    descripcion,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
                const SizedBox(height: 12),
                // Botón ir
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F4F1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.keyboard_arrow_right,
                        color: Colors.grey, size: 28),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── TARJETA COMPLETADA con detalle al tocar ──────────────────────────────────
  Widget _buildCompletedTaskCard({
    required BuildContext context,
    required Map<String, dynamic> data,
    required String horarioCompleto,
  }) {
    return GestureDetector(
      onTap: () => _mostrarDetalleCompletado(context, data),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FCF8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: verdeUANL.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outlined,
                color: Color(0xFF65AE69), size: 24),
          ),
          title: Text(
            data['titulo'] ?? 'Sin título',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: TextDecoration.lineThrough,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(horarioCompleto,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 12)),
              if ((data['salon'] ?? '').isNotEmpty)
                Text('Salón ${data['salon']}',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12)),
            ],
          ),
          trailing: const Icon(Icons.chevron_right,
              color: Colors.grey, size: 20),
        ),
      ),
    );
  }
}
