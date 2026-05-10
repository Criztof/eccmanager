import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/becario_service.dart';

class BecarioInventarioMaterialScreen extends StatefulWidget {
  const BecarioInventarioMaterialScreen({Key? key}) : super(key: key);

  @override
  State<BecarioInventarioMaterialScreen> createState() =>
      _BecarioInventarioMaterialScreenState();
}

class _BecarioInventarioMaterialScreenState
    extends State<BecarioInventarioMaterialScreen> {
  final BecarioService _service = BecarioService();

  static const Color verdeUANL = Color(0xFF1B5E20);

  // ── MODAL: DETALLE DE ARTÍCULO ───────────────────────────────────────────────
  void _mostrarDetalle(Map<String, dynamic> data) {
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
                        child: const Icon(Icons.inventory_2,
                            color: verdeUANL, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          data['articulo'] ?? 'Sin nombre',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _infoRow(Icons.numbers, 'Cantidad',
                      '${data['cantidad'] ?? 0}'),
                  _infoRow(Icons.category, 'Categoría',
                      data['categoria'] ?? 'N/A'),
                  _infoRow(Icons.info_outline, 'Estado',
                      data['estado'] ?? 'N/A'),
                  _infoRow(Icons.shopping_cart_checkout, 'Solicitados',
                      '${data['solicitados'] ?? 0}'),
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

  // ── MODAL: AGREGAR ARTÍCULO ──────────────────────────────────────────────────
  void _mostrarFormularioAgregar() {
    final formKey = GlobalKey<FormState>();
    final articuloCtrl = TextEditingController();
    final cantidadCtrl = TextEditingController(text: '1');
    final nuevaCatCtrl = TextEditingController();

    String? categoriaSeleccionada;
    String estadoSeleccionado = 'Normal';
    bool agregandoNuevaCat = false;
    bool guardando = false;

    final List<String> estadoOpciones = [
      'Normal',
      'Bueno',
      'Regular',
      'Dañado',
      'En reparación',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FutureBuilder<List<String>>(
              future: _service.obtenerCategoriasInventario(),
              builder: (context, snap) {
                final categorias = snap.data ?? [];

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
                              'Agregar Artículo',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: verdeUANL,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Nombre del artículo
                            TextFormField(
                              controller: articuloCtrl,
                              decoration: InputDecoration(
                                labelText: 'Nombre del Artículo',
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                              validator: (v) =>
                                  v!.trim().isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 14),

                            // Categoría — dropdown + opción nueva
                            if (!agregandoNuevaCat) ...[
                              DropdownButtonFormField<String>(
                                value: categoriaSeleccionada,
                                decoration: InputDecoration(
                                  labelText: 'Categoría',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                items: [
                                  ...categorias.map((c) =>
                                      DropdownMenuItem(
                                          value: c, child: Text(c))),
                                  const DropdownMenuItem(
                                    value: '__nueva__',
                                    child: Text('+ Nueva categoría',
                                        style: TextStyle(
                                            color: verdeUANL,
                                            fontWeight:
                                                FontWeight.bold)),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v == '__nueva__') {
                                    setModalState(() {
                                      agregandoNuevaCat = true;
                                      categoriaSeleccionada = null;
                                    });
                                  } else {
                                    setModalState(
                                        () => categoriaSeleccionada = v);
                                  }
                                },
                                validator: (v) =>
                                    (v == null || v == '__nueva__')
                                        ? 'Selecciona una categoría'
                                        : null,
                              ),
                            ] else ...[
                              TextFormField(
                                controller: nuevaCatCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Nueva categoría',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => setModalState(() {
                                      agregandoNuevaCat = false;
                                      nuevaCatCtrl.clear();
                                    }),
                                  ),
                                ),
                                validator: (v) => (agregandoNuevaCat &&
                                        v!.trim().isEmpty)
                                    ? 'Ingresa la categoría'
                                    : null,
                              ),
                            ],
                            const SizedBox(height: 14),

                            // Estado
                            DropdownButtonFormField<String>(
                              value: estadoSeleccionado,
                              decoration: InputDecoration(
                                labelText: 'Estado',
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                              items: estadoOpciones
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setModalState(
                                  () => estadoSeleccionado = v!),
                            ),
                            const SizedBox(height: 14),

                            // Cantidad
                            TextFormField(
                              controller: cantidadCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Cantidad',
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                              validator: (v) {
                                if (v!.trim().isEmpty) return 'Requerido';
                                if (int.tryParse(v.trim()) == null)
                                  return 'Número inválido';
                                return null;
                              },
                            ),
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

                                        final catFinal = agregandoNuevaCat
                                            ? nuevaCatCtrl.text.trim()
                                            : categoriaSeleccionada!;

                                        setModalState(
                                            () => guardando = true);

                                        await _service
                                            .agregarArticuloInventario(
                                          articulo:
                                              articuloCtrl.text.trim(),
                                          categoria: catFinal,
                                          estado: estadoSeleccionado,
                                          cantidad: int.parse(
                                              cantidadCtrl.text.trim()),
                                        );

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  '✅ Artículo agregado'),
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
                                    : const Text('Guardar Artículo',
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
        title: const Text('Inventario Material',
            style: TextStyle(
                color: verdeUANL, fontWeight: FontWeight.bold)),
        centerTitle: true,
        // Sin acciones — se quitó el ícono "+"
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.obtenerInventarioMaterial(),
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
                  const Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('No hay artículos registrados.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
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
                        child: const Icon(Icons.inventory_2,
                            color: verdeUANL),
                      ),
                      title: Text(
                        data['articulo'] ?? 'Desconocido',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      subtitle: Text(
                        'Cantidad: ${data['cantidad'] ?? 0} • ${data['categoria'] ?? ''} • ${data['estado'] ?? 'N/A'}',
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
              'Agregar Artículo',
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
