import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class BuscarInventarioScreen extends StatefulWidget {
  const BuscarInventarioScreen({Key? key}) : super(key: key);

  @override
  State<BuscarInventarioScreen> createState() => _BuscarInventarioScreenState();
}

class _BuscarInventarioScreenState extends State<BuscarInventarioScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _resultados = [];
  bool _cargando = false;
  bool _buscado = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _buscar(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _cargando = true;
      _buscado = false;
    });

    final resultados = await _adminService.buscarInventario(query.trim());

    setState(() {
      _resultados = resultados;
      _cargando = false;
      _buscado = true;
    });
  }

  void _mostrarDetallesMaterial(
      BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          maxChildSize: 0.9,
          minChildSize: 0.35,
          builder: (_, scrollController) {
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
                controller: scrollController,
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
                            color: Color(0xFF1B5E20), size: 32),
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
                  _buildInfoRow(Icons.numbers, 'Cantidad Disponible',
                      '${data['cantidad'] ?? 0}'),
                  _buildInfoRow(Icons.category, 'Categoría',
                      data['categoria'] ?? 'N/A'),
                  _buildInfoRow(Icons.info_outline, 'Estado del Equipo',
                      data['estado'] ?? 'Desconocido'),
                  _buildInfoRow(Icons.shopping_cart_checkout,
                      'Artículos Solicitados',
                      '${data['solicitados'] ?? 0}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(width: 12),
          Text('$label:',
              style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
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
        iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
        title: const Text(
          'Buscar Inventario',
          style: TextStyle(
              color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Buscar artículo o categoría...',
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFF1B5E20)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: Colors.grey.shade200, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF1B5E20), width: 1.5),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onSubmitted: _buscar,
                    textInputAction: TextInputAction.search,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _buscar(_searchController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    elevation: 0,
                  ),
                  child: const Text('Buscar',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          // Resultados
          Expanded(
            child: _cargando
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1B5E20)))
                : !_buscado
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'Escribe para buscar en el inventario.',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 15),
                            ),
                          ],
                        ),
                      )
                    : _resultados.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 12),
                                Text(
                                  'No se encontraron artículos.',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 15),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            itemCount: _resultados.length,
                            itemBuilder: (context, index) {
                              final item = _resultados[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.02),
                                        blurRadius: 4)
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    onTap: () => _mostrarDetallesMaterial(
                                        context, item),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8),
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFF1B5E20)
                                                .withOpacity(0.1),
                                        child: const Icon(
                                            Icons.inventory_2,
                                            color: Color(0xFF1B5E20)),
                                      ),
                                      title: Text(
                                        item['articulo'] ?? 'Desconocido',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      subtitle: Text(
                                          'Cantidad: ${item['cantidad'] ?? 0} • Estado: ${item['estado'] ?? 'N/A'}'),
                                      trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: Colors.grey),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
