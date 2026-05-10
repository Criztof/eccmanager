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

  // ── MODAL: DETALLE DE SALÓN ──────────────────────────────────────────────────
  void _mostrarDetalle(Map<String, dynamic> data) {
    final equipos = data['equipos'] as Map<String, dynamic>? ?? {};
    final int alumnos = equipos['alumnos'] ?? 0;
    final int maestro = equipos['maestro'] ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
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
                      width: 40, height: 5,
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
                          'Salón ${data['numero_sala'] ?? data['salon'] ?? 'N/A'}',
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
                  _infoRow(Icons.meeting_room_outlined, 'Número de sala',
                      data['numero_sala'] ?? data['salon'] ?? 'N/A'),
                  _infoRow(Icons.school_outlined, 'Equipos de alumnos',
                      '$alumnos'),
                  _infoRow(Icons.person_outline, 'Equipo del maestro',
                      '$maestro'),
                  _infoRow(Icons.apps, 'Software asignado',
                      data['software_asignado'] ?? 'N/A'),
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
    final _formKey = GlobalKey<FormState>();
    final numeroSalaCtrl = TextEditingController();
    final alumnosCtrl = TextEditingController(text: '0');
    final maestroCtrl = TextEditingController(text: '1');
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
                    bottom:
                        MediaQuery.of(context).viewInsets.bottom,
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
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40, height: 5,
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

                            // Número de sala
                            TextFormField(
                              controller: numeroSalaCtrl,
                              decoration: InputDecoration(
                                labelText: 'Número de salón',
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

                            // Equipos de alumnos y maestro lado a lado
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: alumnosCtrl,
                                    keyboardType:
                                        TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Equipos Alumnos',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  12)),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Requerido';
                                      if (int.tryParse(v) == null)
                                        return 'Número';
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: maestroCtrl,
                                    keyboardType:
                                        TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Equipo Maestro',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  12)),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Requerido';
                                      if (int.tryParse(v) == null)
                                        return 'Número';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Software — dropdown + opción nueva
                            if (!agregandoNuevoSoftware) ...[
                              DropdownButtonFormField<String>(
                                value: softwareSeleccionado,
                                decoration: InputDecoration(
                                  labelText: 'Software Asignado',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                items: [
                                  ...softwares.map((s) =>
                                      DropdownMenuItem(
                                          value: s,
                                          child: Text(s))),
                                  const DropdownMenuItem(
                                    value: '__nuevo__',
                                    child: Text(
                                      '+ Nuevo software',
                                      style: TextStyle(
                                          color: verdeUANL,
                                          fontWeight:
                                              FontWeight.bold),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val == '__nuevo__') {
                                    setModalState(() {
                                      agregandoNuevoSoftware = true;
                                      softwareSeleccionado = null;
                                    });
                                  } else {
                                    setModalState(() =>
                                        softwareSeleccionado = val);
                                  }
                                },
                                validator: (val) => val == null
                                    ? 'Selecciona un software'
                                    : null,
                              ),
                            ] else ...[
                              TextFormField(
                                controller: nuevoSoftwareCtrl,
                                autofocus: true,
                                decoration: InputDecoration(
                                  labelText: 'Nombre del Software',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.grey),
                                    onPressed: () {
                                      setModalState(() {
                                        agregandoNuevoSoftware =
                                            false;
                                        nuevoSoftwareCtrl.clear();
                                      });
                                    },
                                  ),
                                ),
                                validator: (v) => v!.trim().isEmpty
                                    ? 'Requerido'
                                    : null,
                              ),
                            ],
                            const SizedBox(height: 24),

                            // Botón guardar
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: verdeUANL,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                onPressed: guardando
                                    ? null
                                    : () async {
                                        if (!_formKey.currentState!
                                            .validate()) return;

                                        final String swFinal =
                                            agregandoNuevoSoftware
                                                ? nuevoSoftwareCtrl
                                                    .text
                                                    .trim()
                                                : softwareSeleccionado!;

                                        setModalState(
                                            () => guardando = true);

                                        await _service.agregarSalon(
                                          numeroSala: numeroSalaCtrl
                                              .text
                                              .trim(),
                                          alumnos: int.parse(
                                              alumnosCtrl.text
                                                  .trim()),
                                          maestro: int.parse(
                                              maestroCtrl.text
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
        actions: [
          IconButton(
            icon:
                const Icon(Icons.add_circle_outline, color: verdeUANL),
            tooltip: 'Agregar salón',
            onPressed: _mostrarFormularioAgregar,
          ),
        ],
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
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.computer_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('No hay salones registrados.',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _mostrarFormularioAgregar,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar salón'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: verdeUANL,
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index].data()
                  as Map<String, dynamic>;
              final equipos =
                  data['equipos'] as Map<String, dynamic>? ?? {};
              final int alumnos = equipos['alumnos'] ?? 0;
              final int maestro = equipos['maestro'] ?? 0;

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
                        'Salón ${data['numero_sala'] ?? data['salon'] ?? 'N/A'}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      subtitle: Text(
                        'Alumnos: $alumnos • Maestro: $maestro • ${data['software_asignado'] ?? 'Sin software'}',
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
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormularioAgregar,
        backgroundColor: verdeUANL,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
