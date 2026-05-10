import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/supervisor_service.dart';

// =============================================================================
// COLORES
// =============================================================================
const Color _verde = Color(0xFF1B5E20);
const Color _blanco = Colors.white;

// =============================================================================
// PANTALLA DE TICKETS FILTRADOS — SUPERVISOR
// =============================================================================

class SupervisorTicketsScreen extends StatefulWidget {
  const SupervisorTicketsScreen({super.key});

  @override
  State<SupervisorTicketsScreen> createState() =>
      _SupervisorTicketsScreenState();
}

class _SupervisorTicketsScreenState extends State<SupervisorTicketsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final SupervisorService _svc = SupervisorService();
  String _busqueda = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _svc.actualizarTicketsVencidos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      appBar: AppBar(
        backgroundColor: _verde,
        iconTheme: const IconThemeData(color: _blanco),
        elevation: 0,
        title: const Text(
          'Todos los Tickets',
          style: TextStyle(
              color: _blanco, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: _blanco.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: _blanco, fontSize: 14),
                    cursorColor: _blanco,
                    decoration: InputDecoration(
                      hintText: 'Buscar por título, becario o admin…',
                      hintStyle: TextStyle(
                          color: _blanco.withOpacity(0.6), fontSize: 13),
                      prefixIcon: Icon(Icons.search,
                          color: _blanco.withOpacity(0.7), size: 20),
                      suffixIcon: _busqueda.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close,
                                  color: _blanco.withOpacity(0.7),
                                  size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _busqueda = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                    ),
                    onChanged: (v) => setState(() => _busqueda = v.trim()),
                  ),
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: _blanco,
                labelColor: _blanco,
                unselectedLabelColor: _blanco.withOpacity(0.55),
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: 'Pendientes'),
                  Tab(text: 'Completados'),
                  Tab(text: 'Vencidos'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ListaFiltrada(
              stream: _svc.obtenerTicketsPendientes(),
              busqueda: _busqueda),
          _ListaFiltrada(
              stream: _svc.obtenerTicketsCompletados(),
              busqueda: _busqueda),
          _ListaFiltrada(
              stream: _svc.obtenerTicketsVencidos(),
              busqueda: _busqueda),
        ],
      ),
    );
  }
}

// =============================================================================
// LISTA FILTRADA
// =============================================================================

class _ListaFiltrada extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  final String busqueda;
  const _ListaFiltrada({required this.stream, required this.busqueda});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: _verde));
        }
        if (snapshot.hasError) {
          return _ErrorView(error: '${snapshot.error}');
        }

        var docs = snapshot.data?.docs ?? [];

        // Filtro de búsqueda en cliente
        if (busqueda.isNotEmpty) {
          final q = busqueda.toLowerCase();
          docs = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return (data['titulo'] ?? '').toString().toLowerCase().contains(q) ||
                (data['encargado_nombre'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(q) ||
                (data['levantado_por'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(q) ||
                (data['salon'] ?? '').toString().toLowerCase().contains(q);
          }).toList();
        }

        if (docs.isEmpty) {
          return _EmptyView(busqueda: busqueda);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: docs.length,
          itemBuilder: (ctx, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return _TicketCardSupervisor(data: data);
          },
        );
      },
    );
  }
}

// =============================================================================
// TICKET CARD (pantalla filtrada)
// =============================================================================

class _TicketCardSupervisor extends StatelessWidget {
  final Map<String, dynamic> data;
  const _TicketCardSupervisor({required this.data});

  Color _prioridadColor(String p) {
    switch (p.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Color _estadoColor(String e) {
    switch (e.toLowerCase()) {
      case 'completado':
        return Colors.green;
      case 'vencido':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatFecha(Timestamp? ts) {
    if (ts == null) return 'N/A';
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}  '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final titulo = data['titulo'] ?? 'Sin título';
    final prioridad = data['prioridad'] ?? 'Baja';
    final estado = data['estado'] ?? 'pendiente';
    final encargado = data['encargado_nombre'] ?? 'Sin asignar';
    final salon = data['salon'] ?? 'N/A';
    final levantadoPor = data['levantado_por'] ?? 'Administrador';
    final pColor = _prioridadColor(prioridad);
    final eColor = _estadoColor(estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
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
                // ── Fila 1: dot estado + título + badge prioridad ──
                Row(
                  children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: eColor, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        titulo,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: pColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        prioridad.toUpperCase(),
                        style: TextStyle(
                            color: pColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ── Fila 2: becario + salón ──
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        encargado,
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.meeting_room_outlined,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(salon,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),

                // ── Fila 3: admin + badge estado ──
                Row(
                  children: [
                    const Icon(Icons.admin_panel_settings_outlined,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Admin: $levantadoPor',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _EstadoBadge(estado: estado),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDetalle(BuildContext context) {
    final estado = data['estado'] ?? 'pendiente';
    final esCompletado = estado == 'completado';
    final esVencido = estado == 'vencido';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.97,
        minChildSize: 0.4,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
            color: _blanco,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: sc,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                data['titulo'] ?? 'Ticket sin título',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _verde),
              ),
              const SizedBox(height: 8),
              _EstadoBadge(estado: estado),
              const SizedBox(height: 16),

              // Filas de info
              _detalleRow(Icons.assignment_ind_outlined, 'Becario encargado',
                  data['encargado_nombre'] ?? 'Sin asignar'),
              _detalleRow(
                  Icons.admin_panel_settings_outlined,
                  'Levantado por (Admin)',
                  data['levantado_por'] ?? 'N/A'),
              _detalleRow(Icons.meeting_room_outlined, 'Salón',
                  data['salon'] ?? 'N/A'),
              _detalleRow(Icons.category_outlined, 'Tipo',
                  data['tipo'] ?? 'N/A'),
              _detalleRow(
                  Icons.tag,
                  'No. Ticket',
                  data['numero_ticket'] ?? 'N/A'),
              _detalleRow(
                  Icons.calendar_today_outlined,
                  'Creado',
                  _formatFecha(data['fecha'] as Timestamp?)),
              _detalleRow(
                  Icons.event_busy_outlined,
                  'Vence (mediodía)',
                  _formatFecha(
                      data['fecha_vencimiento'] as Timestamp?)),
              const SizedBox(height: 8),

              // Prioridad chip
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.grey, size: 18),
                  const SizedBox(width: 8),
                  const Text('Prioridad: ',
                      style:
                          TextStyle(color: Colors.grey, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _prioridadColor(data['prioridad'] ?? '')
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (data['prioridad'] ?? 'N/A').toUpperCase(),
                      style: TextStyle(
                          color: _prioridadColor(
                              data['prioridad'] ?? ''),
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Descripción
              const Text('Descripción',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  data['descripcion'] ?? 'Sin descripción',
                  style: const TextStyle(color: Colors.black87),
                ),
              ),

              // ── Si completado → info del becario + evidencia ──
              if (esCompletado) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  'Información completada por el becario',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _verde),
                ),
                const SizedBox(height: 12),
                _detalleRow(
                    Icons.check_circle_outline,
                    'Fecha completado',
                    _formatFecha(
                        data['fecha_completado'] as Timestamp?)),
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
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
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

                // Evidencia fotográfica — imagen a tamaño real
                if ((data['evidencia_url'] ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Evidencia fotográfica',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      data['evidencia_url'],
                      width: double.infinity,
                      // Sin altura fija → imagen ocupa su tamaño natural
                      fit: BoxFit.fitWidth,
                      loadingBuilder: (ctx, child, prog) {
                        if (prog == null) return child;
                        return Container(
                          height: 220,
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: _verde),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        height: 100,
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Text(
                            'No se pudo cargar la imagen',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],

              // ── Si vencido → aviso ──
              if (esVencido) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Este ticket venció sin ser completado. Revisar la asignación con el administrador.',
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
                  backgroundColor: _verde,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: _blanco, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detalleRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 18),
          const SizedBox(width: 10),
          Text('$label: ',
              style:
                  const TextStyle(color: Colors.grey, fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BADGE ESTADO
// =============================================================================

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  Color get _color {
    switch (estado.toLowerCase()) {
      case 'completado':
        return Colors.green;
      case 'vencido':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(
            color: _color,
            fontSize: 10,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

// =============================================================================
// HELPERS
// =============================================================================

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            const Text('Error al cargar tickets.',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text(error,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String busqueda;
  const _EmptyView({required this.busqueda});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              busqueda.isNotEmpty
                  ? 'Sin resultados para "$busqueda".'
                  : 'No hay tickets en este estado.',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
