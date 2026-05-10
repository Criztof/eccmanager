import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/supervisor_service.dart';
import 'supervisor_tickets_screen.dart';
import 'login_screen.dart';

// ─── Colores ─────────────────────────────────────────────────────────────────
const Color _verde = Color(0xFF1B5E20);
const Color _verdeClaro = Color(0xFF2E7D32);
const Color _fondo = Color(0xFFF0F4F0);
const Color _blanco = Colors.white;

// =============================================================================
// PANTALLA PRINCIPAL
// =============================================================================

class PantallaSupervisor extends StatefulWidget {
  const PantallaSupervisor({super.key});
  @override
  State<PantallaSupervisor> createState() => _PantallaSupervisorState();
}

class _PantallaSupervisorState extends State<PantallaSupervisor>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final SupervisorService _svc = SupervisorService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
    _svc.actualizarTicketsVencidos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _svc.obtenerNombreSupervisor();
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'S';

    return Scaffold(
      backgroundColor: _fondo,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: _blanco,
            elevation: 0,
            automaticallyImplyLeading: false,
            expandedHeight: 0,
            centerTitle: true,
            title: const Text(
              'eccmanager',
              style: TextStyle(color: _verde, fontWeight: FontWeight.bold, fontSize: 22),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  backgroundColor: _verde.withOpacity(0.12),
                  radius: 18,
                  child: Text(inicial,
                      style: const TextStyle(
                          color: _verde, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: _verde,
              unselectedLabelColor: Colors.grey,
              indicatorColor: _verde,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [Tab(text: 'Resumen'), Tab(text: 'Usuarios')],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _TabResumen(svc: _svc, nombre: nombre),
            _TabUsuarios(svc: _svc),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _verde,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Text('ECC',
            style: TextStyle(color: _blanco, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomBar(tabController: _tabController, onLogout: _cerrarSesion),
    );
  }

  void _mostrarMenuPerfil() {
    final nombre = _svc.obtenerNombreSupervisor();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: _blanco,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: _verde.withOpacity(0.12),
              child: Text(nombre.isNotEmpty ? nombre[0].toUpperCase() : 'S',
                  style: const TextStyle(
                      color: _verde, fontWeight: FontWeight.bold, fontSize: 26)),
            ),
            const SizedBox(height: 12),
            Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: _verde.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: const Text('Supervisor',
                  style: TextStyle(color: _verde, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar sesión',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              onTap: () { Navigator.pop(context); _cerrarSesion(); },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    await _svc.cerrarSesion();
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }
}

// =============================================================================
// TAB 1 — RESUMEN
// =============================================================================

class _TabResumen extends StatelessWidget {
  final SupervisorService svc;
  final String nombre;
  const _TabResumen({required this.svc, required this.nombre});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: svc.obtenerTodosLosTickets(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final semana = SupervisorService.filtrarPorSemana(docs);
        final pendientes = semana.where((d) => _estado(d) == 'pendiente').length;
        final completados = semana.where((d) => _estado(d) == 'completado').length;
        final vencidos = semana.where((d) => _estado(d) == 'vencido').length;
        final conEvidencia = semana
            .where((d) =>
                _estado(d) == 'completado' &&
                (_field(d, 'evidencia_url') ?? '').isNotEmpty)
            .toList();

        return RefreshIndicator(
          color: _verde,
          onRefresh: () async => svc.actualizarTicketsVencidos(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              _SaludoHeader(nombre: nombre),
              const SizedBox(height: 20),

              // ── Stats semana ──
              Row(children: [
                _StatChip(count: completados, label: 'Completados',
                    icon: Icons.check_circle_outline, color: Colors.green),
                const SizedBox(width: 10),
                _StatChip(count: pendientes, label: 'Pendientes',
                    icon: Icons.timer_outlined, color: Colors.orange),
                const SizedBox(width: 10),
                _StatChip(count: vencidos, label: 'Vencidos',
                    icon: Icons.error_outline, color: Colors.red),
              ]),
              const SizedBox(height: 6),
              const SizedBox(height: 28),

              // ── Rendimiento admins ──
              _ResumenAdmins(docs: semana),
              const SizedBox(height: 28),

              // ── Evidencias ──
              _SeccionHeader(
                titulo: 'Evidencias de la semana',
                accion: 'Ver todo',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SupervisorTicketsScreen())),
              ),
              const SizedBox(height: 12),
              if (conEvidencia.isEmpty)
                _EmptyState(
                    icon: Icons.photo_library_outlined,
                    mensaje: 'Sin evidencias esta semana.')
              else
                ...conEvidencia.map((doc) =>
                    _EvidenciaCard(data: doc.data() as Map<String, dynamic>)),
            ],
          ),
        );
      },
    );
  }

  String _estado(QueryDocumentSnapshot d) =>
      (d.data() as Map<String, dynamic>)['estado'] ?? 'pendiente';
  String? _field(QueryDocumentSnapshot d, String key) =>
      (d.data() as Map<String, dynamic>)[key] as String?;
}

// =============================================================================
// TAB 2 — USUARIOS
// =============================================================================

class _TabUsuarios extends StatelessWidget {
  final SupervisorService svc;
  const _TabUsuarios({required this.svc});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: svc.getUsuariosStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _verde));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar usuarios.'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _EmptyState(
              icon: Icons.group_outlined, mensaje: 'No hay usuarios registrados.');
        }
        final supervisores = docs.where((d) => _rol(d) == 'supervisor').toList();
        final admins = docs.where((d) => _rol(d) == 'admin').toList();
        final becarios = docs.where((d) => _rol(d) == 'becario').toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            if (supervisores.isNotEmpty) ...[
              _GrupoLabel(label: 'Supervisores', icono: Icons.shield_outlined),
              const SizedBox(height: 8),
              ...supervisores.map((d) => _UserCard(doc: d, svc: svc)),
              const SizedBox(height: 16),
            ],
            if (admins.isNotEmpty) ...[
              _GrupoLabel(label: 'Administradores', icono: Icons.manage_accounts_outlined),
              const SizedBox(height: 8),
              ...admins.map((d) => _UserCard(doc: d, svc: svc)),
              const SizedBox(height: 16),
            ],
            if (becarios.isNotEmpty) ...[
              _GrupoLabel(label: 'Becarios', icono: Icons.school_outlined),
              const SizedBox(height: 8),
              ...becarios.map((d) => _UserCard(doc: d, svc: svc)),
            ],
          ],
        );
      },
    );
  }

  String _rol(QueryDocumentSnapshot d) =>
      (d.data() as Map<String, dynamic>)['rol'] ?? 'becario';
}

// =============================================================================
// BOTTOM BAR
// =============================================================================

class _BottomBar extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onLogout;
  const _BottomBar({required this.tabController, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: _blanco,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomItem(icon: Icons.home_outlined, label: 'Inicio',
                onTap: () => tabController.animateTo(0)),
            const SizedBox(width: 48),
            _BottomItem(icon: Icons.logout, label: 'Salir',
                color: Colors.grey, onTap: onLogout),
          ],
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _BottomItem(
      {required this.icon, required this.label, this.color = _verde, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}

// =============================================================================
// WIDGETS REUTILIZABLES
// =============================================================================

class _SaludoHeader extends StatelessWidget {
  final String nombre;
  const _SaludoHeader({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('¡Hola, $nombre! 👋',
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        const Text('Aquí tienes el resumen de operaciones de esta semana.',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color color;
  const _StatChip(
      {required this.count, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: _blanco,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text('$count',
                    style: TextStyle(
                        color: color, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Sección header con barra lateral verde ──

class _SeccionHeader extends StatelessWidget {
  final String titulo;
  final String? accion;
  final VoidCallback? onTap;
  const _SeccionHeader({required this.titulo, this.accion, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _verde,
          ),
        ),
        if (accion != null && onTap != null)
          TextButton(
            onPressed: onTap,
            child: Text(accion!,
                style: const TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }
}

// ── Grupo label con fondo suave ──

class _GrupoLabel extends StatelessWidget {
  final String label;
  final IconData icono;
  const _GrupoLabel({required this.label, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: _verde.withOpacity(0.06), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icono, color: _verde, size: 16),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: _verde)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String mensaje;
  const _EmptyState({required this.icon, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade300, size: 56),
          const SizedBox(height: 12),
          Text(mensaje, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}

// =============================================================================
// RESUMEN ADMINS
// =============================================================================

class _ResumenAdmins extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  const _ResumenAdmins({required this.docs});

  @override
  Widget build(BuildContext context) {
    final Map<String, _AdminStats> mapa = {};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final admin = (data['levantado_por'] ?? 'Sin admin').toString();
      mapa.putIfAbsent(admin, () => _AdminStats(nombre: admin));
      final estado = data['estado'] ?? 'pendiente';
      if (estado == 'completado') mapa[admin]!.completados++;
      if (estado == 'pendiente') mapa[admin]!.pendientes++;
      if (estado == 'vencido') mapa[admin]!.vencidos++;
      mapa[admin]!.total++;
    }
    if (mapa.isEmpty) return const SizedBox.shrink();

    final lista = mapa.values.toList()..sort((a, b) => b.total.compareTo(a.total));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SeccionHeader(titulo: 'Rendimiento por Administrador'),
        const SizedBox(height: 6),
        const SizedBox(height: 12),
        ...lista.map((s) => _AdminRendimientoCard(stats: s)),
      ],
    );
  }
}

class _AdminStats {
  final String nombre;
  int total = 0, completados = 0, pendientes = 0, vencidos = 0;
  _AdminStats({required this.nombre});
}

class _AdminRendimientoCard extends StatelessWidget {
  final _AdminStats stats;
  const _AdminRendimientoCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final eficiencia = stats.total == 0 ? 0.0 : stats.completados / stats.total;
    final pct = (eficiencia * 100).toStringAsFixed(0);
    final color = eficiencia >= 0.7
        ? Colors.green
        : eficiencia >= 0.4
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _verde.withOpacity(0.1),
                child: Text(
                  stats.nombre.isNotEmpty ? stats.nombre[0].toUpperCase() : 'A',
                  style: const TextStyle(
                      color: _verde, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stats.nombre,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                        '${stats.total} ticket${stats.total == 1 ? '' : 's'} esta semana',
                        style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Text('$pct%',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: eficiencia,
              minHeight: 6,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MiniChip(label: '${stats.completados} compl.', color: Colors.green),
              const SizedBox(width: 6),
              _MiniChip(label: '${stats.pendientes} pend.', color: Colors.orange),
              const SizedBox(width: 6),
              _MiniChip(label: '${stats.vencidos} venc.', color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

// =============================================================================
// EVIDENCIA CARD
// =============================================================================

class _EvidenciaCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const _EvidenciaCard({required this.data});

  @override
  State<_EvidenciaCard> createState() => _EvidenciaCardState();
}

class _EvidenciaCardState extends State<_EvidenciaCard> {
  bool _expandida = false;

  String _formatFecha(Timestamp? ts) {
    if (ts == null) return '';
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}  '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final url = data['evidencia_url'] ?? '';
    final titulo = data['titulo'] ?? 'Ticket sin título';
    final encargado = data['encargado_nombre'] ?? 'Becario';
    final salon = data['salon'] ?? 'N/A';
    final levantadoPor = data['levantado_por'] ?? 'Administrador';
    final fechaCompletado = _formatFecha(data['fecha_completado'] as Timestamp?);
    final observaciones = (data['observaciones'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _blanco,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (url.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                url,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                loadingBuilder: (ctx, child, prog) {
                  if (prog == null) return child;
                  return Container(
                    height: 220,
                    color: Colors.grey.shade100,
                    child: const Center(child: CircularProgressIndicator(color: _verde)),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: Colors.grey.shade100,
                  child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: Colors.grey, size: 40)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Text(titulo,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87))),
                    const SizedBox(width: 8),
                    _EstadoBadge(estado: 'completado'),
                  ],
                ),
                const SizedBox(height: 10),
                _InfoRow(icon: Icons.person_outline, label: encargado, color: _verdeClaro),
                const SizedBox(height: 4),
                _InfoRow(
                    icon: Icons.meeting_room_outlined,
                    label: 'Salón $salon',
                    color: Colors.grey),
                const SizedBox(height: 4),
                _InfoRow(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Levantado por $levantadoPor',
                    color: Colors.grey),
                if (fechaCompletado.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _InfoRow(
                      icon: Icons.check_circle_outline,
                      label: fechaCompletado,
                      color: Colors.grey),
                ],
                if (_expandida) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  _MetricasGrid(data: data),
                  if (observaciones.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Observaciones',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200)),
                      child: Text(observaciones,
                          style: const TextStyle(color: Colors.black87, fontSize: 13)),
                    ),
                  ],
                ],
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() => _expandida = !_expandida),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_expandida ? 'Ocultar detalles' : 'Ver detalles',
                          style: const TextStyle(
                              color: _verde, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(width: 4),
                      Icon(
                        _expandida
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: _verde,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoRow({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
            child: Text(label,
                style: TextStyle(color: color, fontSize: 12),
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _MetricasGrid extends StatelessWidget {
  final Map<String, dynamic> data;
  const _MetricasGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MetricaItem(icon: Icons.computer, label: 'No encienden',
          value: '${data['pcs_no_encienden'] ?? 0}', color: Colors.red),
      _MetricaItem(icon: Icons.wifi_off, label: 'Sin internet',
          value: '${data['pcs_sin_internet'] ?? 0}', color: Colors.orange),
      _MetricaItem(icon: Icons.design_services, label: 'AutoCAD',
          value: '${data['pcs_autocad'] ?? 0}', color: Colors.blue),
      _MetricaItem(icon: Icons.cable, label: 'Cables dañados',
          value: '${data['cables_danados'] ?? 0}', color: Colors.purple),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items
          .map((item) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                    color: item.color.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(item.icon, color: item.color, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.value,
                              style: TextStyle(
                                  color: item.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          Text(item.label,
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _MetricaItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  _MetricaItem(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});
}

// =============================================================================
// USER CARD
// =============================================================================

class _UserCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final SupervisorService svc;
  const _UserCard({required this.doc, required this.svc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final nombre = data['nombre'] ?? 'Sin nombre';
    final correo = data['correo'] ?? 'Sin correo';
    final rol = data['rol'] ?? 'becario';
    final uid = doc.id;
    final esSupervisor = rol == 'supervisor';
    final esAdmin = rol == 'admin';
    final Color rolColor =
        esSupervisor ? Colors.purple : esAdmin ? _verde : Colors.blue;
    final IconData rolIcon = esSupervisor
        ? Icons.shield_outlined
        : esAdmin
            ? Icons.manage_accounts_outlined
            : Icons.school_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: rolColor.withOpacity(0.1),
          child: Text(nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
              style: TextStyle(
                  color: rolColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        title: Text(nombre,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(correo,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(rolIcon, size: 12, color: rolColor),
                const SizedBox(width: 4),
                Text(rol.toUpperCase(),
                    style: TextStyle(
                        color: rolColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        trailing: esSupervisor
            ? const Icon(Icons.security, color: Colors.grey, size: 22)
            : _RolToggleButton(
                esAdmin: esAdmin,
                onToggle: () =>
                    svc.actualizarRolUsuario(uid, esAdmin ? 'becario' : 'admin'),
              ),
      ),
    );
  }
}

class _RolToggleButton extends StatelessWidget {
  final bool esAdmin;
  final VoidCallback onToggle;
  const _RolToggleButton({required this.esAdmin, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (esAdmin ? Colors.orange : _verde).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(esAdmin ? Icons.arrow_downward : Icons.arrow_upward,
            color: esAdmin ? Colors.orange : _verde, size: 18),
      ),
    );
  }
}

// =============================================================================
// BADGE DE ESTADO
// =============================================================================

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  Color get _color {
    switch (estado.toLowerCase()) {
      case 'completado': return Colors.green;
      case 'vencido': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: _color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(estado.toUpperCase(),
          style: TextStyle(color: _color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
