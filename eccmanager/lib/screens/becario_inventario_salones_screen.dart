import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/becario_service.dart';

class BecarioInventarioSalonesScreen extends StatefulWidget {
  const BecarioInventarioSalonesScreen({Key? key}) : super(key: key);

  @override
  State<BecarioInventarioSalonesScreen> createState() =>
      _BecarioInventarioSalonesScreenState();
}

class _BecarioInventarioSalonesScreenState
    extends State<BecarioInventarioSalonesScreen> {
  final BecarioService _service = BecarioService();

  static const Color verdeUANL = Color(0xFF1B5E20);

  // Formatea un Timestamp a texto legible
  String _formatearFecha(dynamic ts) {
    if (ts == null) return 'N/A';
    if (ts is Timestamp) {
      final d = ts.toDate();
      return '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.year}  '
          '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';
    }
    return ts.toString();
  }

  // ── MODAL: DETALLE DE SALÓN ──────────────────────────────────────────────────
  void _mostrarDetalle(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          maxChildSize: 0.85,
          minChildSize: 0.35,
          builder: (_, sc) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.computer,
                            color: verdeUANL, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Salón ${data['salon'] ?? 'N/A'}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _infoRow(Icons.meeting_room_outlined, 'Salón',
                      data['salon'] ?? 'N/A'),
                  _infoRow(Icons.school_outlined, 'Cant. Alumnos',
                      '${data['cant_alumnos'] ?? 0}'),
                  _infoRow(Icons.person_outline, 'Cant. Maestros',
                      '${data['cant_maestros'] ?? 0}'),
                  _infoRow(Icons.apps, 'Software asignado',
                      data['software_asignado'] ?? 'N/A'),
                  _infoRow(Icons.update, 'Última actualización',
                      _formatearFecha(data['ultima_actualizacion'])),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verdeUANL,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── MODAL: AGREGAR SALÓN ─────────────────────────────────────────────────────
  void _mostrarFormularioAgregar() {
    final formKey = GlobalKey<FormState>();
    final salonCtrl = TextEditingController();
    final cantAlumnosCtrl = TextEditingController(text: '0');
    final cantMaestrosCtrl = TextEditingController(text: '1');
    final nuevoSoftwareCtrl = TextEditingController();

    String? softwareSeleccionado;
    bool agregandoNuevoSoftware = false;
    bool guardando = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FutureBuilder<List<String>>(
              future: _service.obtenerSoftwaresExistentes(),
              builder: (context, snap) {
                final softwares = snap.data ?? [];

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Handle
                            Center(
                              child: Container(
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius:
                                        BorderRadius.circular(10)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Agregar Salón',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: verdeUANL,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Salón
                            TextFormField(
                              controller: salonCtrl,
                              decoration: InputDecoration(
                                labelText: 'Salón',
                                hintText: 'Ej. 4-102',
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                              validator: (v) => v!.trim().isEmpty
                                  ? 'Requerido'
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            // Cantidad alumnos y maestros lado a lado
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: cantAlumnosCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Cant. Alumnos',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    validator: (v) {
                                      if (v!.trim().isEmpty)
                                        return 'Requerido';
                                      if (int.tryParse(v.trim()) == null)
                                        return 'Número inválido';
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: cantMaestrosCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Cant. Maestros',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    validator: (v) {
                                      if (v!.trim().isEmpty)
                                        return 'Requerido';
                                      if (int.tryParse(v.trim()) == null)
                                        return 'Número inválido';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Software asignado — dropdown + opción nueva
                            if (!agregandoNuevoSoftware) ...[
                              DropdownButtonFormField<String>(
                                value: softwareSeleccionado,
                                decoration: InputDecoration(
                                  labelText: 'Software asignado',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                items: [
                                  ...softwares.map((s) =>
                                      DropdownMenuItem(
                                          value: s, child: Text(s))),
                                  const DropdownMenuItem(
                                    value: '__nuevo__',
                                    child: Text('+ Nuevo software',
                                        style: TextStyle(
                                            color: verdeUANL,
                                            fontWeight:
                                                FontWeight.bold)),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v == '__nuevo__') {
                                    setModalState(() {
                                      agregandoNuevoSoftware = true;
                                      softwareSeleccionado = null;
                                    });
                                  } else {
                                    setModalState(
                                        () => softwareSeleccionado = v);
                                  }
                                },
                                validator: (v) =>
                                    (v == null || v == '__nuevo__')
                                        ? 'Selecciona un software'
                                        : null,
                              ),
                            ] else ...[
                              TextFormField(
                                controller: nuevoSoftwareCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Nuevo software',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => setModalState(() {
                                      agregandoNuevoSoftware = false;
                                      nuevoSoftwareCtrl.clear();
                                    }),
                                  ),
                                ),
                                validator: (v) =>
                                    (agregandoNuevoSoftware &&
                                            v!.trim().isEmpty)
                                        ? 'Ingresa el software'
                                        : null,
                              ),
                            ],
                            const SizedBox(height: 24),

                            // Botón guardar
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: verdeUANL,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                                onPressed: guardando
                                    ? null
                                    : () async {
                                        if (!formKey.currentState!
                                            .validate()) return;

                                        final swFinal =
                                            agregandoNuevoSoftware
                                                ? nuevoSoftwareCtrl.text
                                                    .trim()
                                                : softwareSeleccionado!;

                                        setModalState(
                                            () => guardando = true);

                                        await _service.agregarSalon(
                                          salon: salonCtrl.text.trim(),
                                          cantAlumnos: int.parse(
                                              cantAlumnosCtrl.text
                                                  .trim()),
                                          cantMaestros: int.parse(
                                              cantMaestrosCtrl.text
                                                  .trim()),
                                          softwareAsignado: swFinal,
                                        );

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  '✅ Salón agregado'),
                                              backgroundColor:
                                                  Colors.green,
                                            ),
                                          );
                                        }
                                      },
                                child: guardando
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5),
                                      )
                                    : const Text('Guardar Salón',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16)),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          const SizedBox(width: 10),
          Text('$label:',
              style: const TextStyle(color: Colors.grey, fontSize: 15)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: verdeUANL),
        title: const Text('Inventario Salones',
            style: TextStyle(
                color: verdeUANL, fontWeight: FontWeight.bold)),
        centerTitle: true,
        // Sin acciones — se quitó el ícono "+"
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.obtenerInventarioSalones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: verdeUANL));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.computer_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No hay salones registrados.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
                left: 16, right: 16, top: 16, bottom: 100),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index].data()
                  as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4)
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _mostrarDetalle(data),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: verdeUANL.withOpacity(0.1),
                        child: const Icon(Icons.computer,
                            color: verdeUANL),
                      ),
                      title: Text(
                        'Salón ${data['salon'] ?? 'N/A'}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      subtitle: Text(
                        'Alumnos: ${data['cant_alumnos'] ?? 0} • '
                        'Maestros: ${data['cant_maestros'] ?? 0} • '
                        '${data['software_asignado'] ?? 'Sin software'}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      // ── BOTÓN INFERIOR CENTRADO ESTILO "NUEVO TICKET" ────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _mostrarFormularioAgregar,
            icon: const Icon(Icons.add_circle_outline,
                color: Colors.white, size: 22),
            label: const Text(
              'Agregar Salón',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: verdeUANL,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }
}
