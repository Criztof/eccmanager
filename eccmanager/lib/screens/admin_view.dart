import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_service.dart';
import 'login_screen.dart';
import 'filtrado_tickets_screen.dart';
import 'inventario_screen.dart';
import 'buscar_inventario_screen.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final AdminService _adminService = AdminService();

  @override
  void initState() {
    super.initState();
    _adminService.actualizarTicketsVencidos();
  }

  // ---------------------------------------------------------------------------
  // MODAL NUEVO TICKET
  // ---------------------------------------------------------------------------

  void _mostrarModalNuevoTicket(BuildContext context) {
    final TextEditingController tituloController = TextEditingController();
    final TextEditingController descripcionController = TextEditingController();
    final TextEditingController salonController = TextEditingController();

    String? tipoSeleccionado;
    String? prioridadSeleccionada;
    String? becarioUidSeleccionado;
    String? becarioNombreSeleccionado;

    final _formKey = GlobalKey<FormState>();
    final Future<List<Map<String, dynamic>>> becariosFuture =
        _adminService.obtenerBecarios();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Preview de la fecha de vencimiento según el tipo seleccionado
            String previsualizarVencimiento() {
              if (tipoSeleccionado == null) return '';
              final DateTime fv =
                  AdminService.calcularFechaVencimiento(tipoSeleccionado!);
              final dias = ['', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
              return 'Vence el ${dias[fv.weekday]} '
                  '${fv.day.toString().padLeft(2, '0')}/'
                  '${fv.month.toString().padLeft(2, '0')}/'
                  '${fv.year} a las 12:00';
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nuevo Ticket',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: tituloController,
                        decoration: InputDecoration(
                          labelText: 'Título del Ticket',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descripcionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Tipo de Ticket',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: [
                          'Inventariar software',
                          'Inventariar material del CET',
                          'Armado de cajas',
                        ]
                            .map((t) =>
                                DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => tipoSeleccionado = val),
                        validator: (val) => val == null ? 'Requerido' : null,
                      ),
                      // Preview de vencimiento
                      if (tipoSeleccionado != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 16, color: Color(0xFF1B5E20)),
                              const SizedBox(width: 6),
                              Text(
                                previsualizarVencimiento(),
                                style: const TextStyle(
                                    color: Color(0xFF1B5E20),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Prioridad',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              items: ['Baja', 'Media', 'Alta']
                                  .map((p) => DropdownMenuItem(
                                      value: p, child: Text(p)))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => prioridadSeleccionada = val),
                              validator: (val) =>
                                  val == null ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: salonController,
                              decoration: InputDecoration(
                                labelText: 'Salón',
                                hintText: 'Ej. 2-104',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: becariosFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final becarios = snapshot.data!;
                          final unique = {
                            for (var b in becarios) b['uid']: b
                          }.values.toList();

                          return DropdownButtonFormField<String>(
                            value: becarioUidSeleccionado,
                            decoration: InputDecoration(
                              labelText: 'Asignar a Becario',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            items: unique
                                .map((b) => DropdownMenuItem<String>(
                                      value: b['uid'] as String,
                                      child: Text(
                                        b['nombre'] ?? 'Sin nombre',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                becarioUidSeleccionado = val;
                                becarioNombreSeleccionado = unique
                                        .firstWhere((b) => b['uid'] == val)[
                                            'nombre'] ??
                                    'Desconocido';
                              });
                            },
                            validator: (val) =>
                                val == null ? 'Requerido' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate() &&
                                tipoSeleccionado != null &&
                                prioridadSeleccionada != null &&
                                becarioUidSeleccionado != null) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(
                                    child: CircularProgressIndicator()),
                              );
                              await _adminService.crearTicket(
                                titulo: tituloController.text.trim(),
                                descripcion:
                                    descripcionController.text.trim(),
                                prioridad: prioridadSeleccionada!,
                                encargadoUid: becarioUidSeleccionado!,
                                encargadoNombre:
                                    becarioNombreSeleccionado ?? 'Desconocido',
                                tipo: tipoSeleccionado!,
                                salon: salonController.text.trim(),
                              );
                              Navigator.pop(context); // loader
                              Navigator.pop(context); // modal
                            }
                          },
                          child: const Text('Asignar Ticket',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'eccmanager',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF1B5E20),
              child: Text(
                userName.isNotEmpty
                    ? userName.substring(0, 1).toUpperCase()
                    : 'A',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1B5E20),
        shape: const CircleBorder(),
        elevation: 5,
        child: const Text(
          'ECC',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.home_filled, color: Color(0xFF1B5E20)),
                  Text('Inicio',
                      style: TextStyle(
                          color: Color(0xFF1B5E20), fontSize: 10)),
                ],
              ),
              const SizedBox(width: 48),
              GestureDetector(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.logout_outlined, color: Colors.grey),
                    Text('Salir',
                        style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
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
            // ── 1. Hero ──────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, $userName',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<int>(
                    stream: _adminService.obtenerConteoTicketsAbiertos(),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return Text(
                        'Tienes $count ticket${count == 1 ? '' : 's'} pendiente${count == 1 ? '' : 's'} esta semana.',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FiltradoTicketsScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Ver Todos',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ── 2. Stats ─────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<int>(
                    stream: _adminService.obtenerConteoTicketsAbiertos(),
                    builder: (context, snapshot) => _buildStatCard(
                      '${snapshot.data ?? 0}',
                      'Tickets Abiertos',
                      Icons.confirmation_number_outlined,
                      Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StreamBuilder<int>(
                    stream: _adminService.obtenerConteoInventario(),
                    builder: (context, snapshot) => _buildStatCard(
                      '${snapshot.data ?? 0}',
                      'Artículos Stock',
                      Icons.inventory_2_outlined,
                      Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // ── 3. Gestión Rápida ─────────────────────────────────────────────
            const Text(
              'Gestión Rápida',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => _mostrarModalNuevoTicket(context),
              child: _buildActionTile(Icons.add_circle_outline,
                  'Nuevo Ticket', 'Crear reporte de soporte'),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const InventarioScreen())),
              child: _buildActionTile(Icons.handyman_outlined,
                  'Herramientas', 'Inventario de equipo'),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BuscarInventarioScreen())),
              child: _buildActionTile(Icons.search, 'Buscar Inventario',
                  'Localizar componentes de material'),
            ),
            const SizedBox(height: 25),

            // ── 4. Tickets Recientes ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tickets Recientes',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20)),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FiltradoTicketsScreen())),
                  child: const Text('Ver todo',
                      style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _adminService.obtenerTicketsRecientes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF1B5E20)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                        child: Text('No hay tickets recientes.')),
                  );
                }
                return Column(
                  children: snapshot.data!.docs
                      .map((doc) => TicketCardAdmin(
                          data: doc.data() as Map<String, dynamic>))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS UI
  // ---------------------------------------------------------------------------

  Widget _buildStatCard(
      String count, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 15),
          Text(count,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionTile(
      IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02), blurRadius: 5)
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1B5E20)),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        subtitle:
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 16, color: Colors.grey),
      ),
    );
  }
}

// =============================================================================
// TICKET CARD — usada en AdminView (tickets recientes)
// =============================================================================

class TicketCardAdmin extends StatelessWidget {
  final Map<String, dynamic> data;

  const TicketCardAdmin({Key? key, required this.data}) : super(key: key);

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

  String _tiempoTranscurrido(Timestamp? ts) {
    if (ts == null) return 'Hace un momento';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inDays > 0) return 'Hace ${diff.inDays} d';
    if (diff.inHours > 0) return 'Hace ${diff.inHours} h';
    if (diff.inMinutes > 0) return 'Hace ${diff.inMinutes} min';
    return 'Hace un momento';
  }

  String _formatFechaHora(Timestamp? ts) {
    if (ts == null) return 'N/A';
    final d = ts.toDate();
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} $h:$m';
  }

  void _mostrarDetalleTicket(BuildContext context) {
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
          initialChildSize: 0.6,
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
                      width: 40, height: 5,
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
                        color: Color(0xFF1B5E20)),
                  ),
                  const SizedBox(height: 6),
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
                              color: Colors.grey, fontSize: 16)),
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
                        style:
                            const TextStyle(color: Colors.black87)),
                  ),

                  // Info del becario si completado
                  if (esCompletado) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    const Text('Información completada por el becario',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1B5E20))),
                    const SizedBox(height: 12),
                    _detalleRow(
                        Icons.check_circle_outline,
                        'Completado',
                        _formatFechaHora(
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
                    // ── Evidencia: imagen en lugar de URL ──
                    if ((data['evidencia_url'] ?? '').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('Evidencia fotográfica',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          data['evidencia_url'],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder:
                              (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey.shade100,
                              child: const Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF1B5E20))),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 100,
                              color: Colors.grey.shade100,
                              child: const Center(
                                  child: Text(
                                      'No se pudo cargar la imagen',
                                      style: TextStyle(
                                          color: Colors.grey))),
                            );
                          },
                        ),
                      ),
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
                              'Este ticket venció a las 12:00 sin ser completado.',
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
    final Color color = _getPriorityColor(priority);
    final Color estadoColor = _getEstadoColor(estado);
    final String subtitle =
        '${_tiempoTranscurrido(data['fecha'] as Timestamp?)} • ${data['salon'] ?? ''}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02), blurRadius: 4),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _mostrarDetalleTicket(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                      color: estadoColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      if (data['encargado_nombre'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Asignado a: ${data['encargado_nombre']}',
                          style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(priority.toUpperCase(),
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
