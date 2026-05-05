import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_service.dart';

class FiltradoTicketsScreen extends StatefulWidget {
  const FiltradoTicketsScreen({Key? key}) : super(key: key);

  @override
  State<FiltradoTicketsScreen> createState() => _FiltradoTicketsScreenState();
}

class _FiltradoTicketsScreenState extends State<FiltradoTicketsScreen> {
  final AdminService _adminService = AdminService();

  @override
  void initState() {
    super.initState();
    _adminService.actualizarTicketsVencidos();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F9F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1B5E20),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Todos los Tickets',
              style: TextStyle(color: Colors.white)),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'Pendientes'),
              Tab(text: 'Completados'),
              Tab(text: 'Vencidos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLista('pendiente'),
            _buildLista('completado'),
            _buildLista('vencido'),
          ],
        ),
      ),
    );
  }

  Widget _buildLista(String estado) {
    return StreamBuilder<QuerySnapshot>(
      stream: _adminService.obtenerTicketsPorEstado(estado),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF1B5E20)));
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  const Text('Error al cargar tickets.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text('${snapshot.error}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text('No hay tickets en este estado.',
                  style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return _TicketCard(data: data);
          },
        );
      },
    );
  }
}

// =============================================================================
// TICKET CARD — Filtrado
// =============================================================================

class _TicketCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TicketCard({required this.data});

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

  Color _getEstadoColor(String e) {
    switch (e.toLowerCase()) {
      case 'completado':
        return Colors.green;
      case 'vencido':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  /// Formatea un Timestamp como dd/MM/yyyy HH:mm
  String _formatFechaHora(Timestamp? ts) {
    if (ts == null) return 'N/A';
    final d = ts.toDate();
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year} $h:$m';
  }

  void _mostrarDetalle(BuildContext context) {
    final estado = data['estado'] ?? 'pendiente';
    final esCompletado = estado == 'completado';
    final esVencido = estado == 'vencido';

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
                  // Handle
                  Center(
                    child: Container(
                      width: 40, height: 5,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  Text(
                    data['titulo'] ?? 'Ticket sin título',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20)),
                  ),
                  const SizedBox(height: 8),

                  // Badge estado
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getEstadoColor(estado).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(estado.toUpperCase(),
                          style: TextStyle(
                              color: _getEstadoColor(estado),
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _detalleRow(Icons.assignment_ind_outlined, 'Asignado a',
                      data['encargado_nombre'] ?? 'Sin asignar'),
                  _detalleRow(Icons.meeting_room_outlined, 'Salón',
                      data['salon'] ?? 'N/A'),
                  _detalleRow(Icons.category_outlined, 'Tipo',
                      data['tipo'] ?? 'N/A'),
                  _detalleRow(
                      Icons.calendar_today_outlined,
                      'Creado',
                      _formatFechaHora(data['fecha'] as Timestamp?)),
                  // Vencimiento con la hora exacta (12:00)
                  _detalleRow(
                      Icons.event_busy_outlined,
                      'Vence (mediodía)',
                      _formatFechaHora(
                          data['fecha_vencimiento'] as Timestamp?)),
                  const SizedBox(height: 8),

                  // Prioridad
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.grey),
                      const SizedBox(width: 10),
                      const Text('Prioridad: ',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 15)),
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

                  // Descripción
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
                        style:
                            const TextStyle(color: Colors.black87)),
                  ),

                  // Info del becario si completado
                  if (esCompletado) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    const Text(
                      'Información completada por el becario',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1B5E20)),
                    ),
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
                        style:
                            const TextStyle(color: Colors.black87),
                      ),
                    ),
                    if ((data['evidencia_url'] ?? '').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('Evidencia (URL)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      const SizedBox(height: 5),
                      Text(data['evidencia_url'],
                          style: const TextStyle(
                              color: Colors.blue,
                              decoration:
                                  TextDecoration.underline)),
                    ],
                  ],

                  // Aviso si vencido
                  if (esVencido) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.error_outline,
                              color: Colors.red),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Este ticket venció a las 12:00 sin ser completado por el becario.',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar',
                        style: TextStyle(
                            color: Colors.white, fontSize: 16)),
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
    final String title = data['titulo'] ?? 'Sin título';
    final String priority = data['prioridad'] ?? 'Baja';
    final String estado = data['estado'] ?? 'pendiente';
    final Color priorityColor = _getPriorityColor(priority);
    final Color estadoColor = _getEstadoColor(estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03), blurRadius: 6),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _mostrarDetalle(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                          color: estadoColor,
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(priority.toUpperCase(),
                          style: TextStyle(
                              color: priorityColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        data['encargado_nombre'] ?? 'Sin asignar',
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.meeting_room_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(data['salon'] ?? 'N/A',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                // Badge estado en la card
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: estadoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(estado.toUpperCase(),
                        style: TextStyle(
                            color: estadoColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
