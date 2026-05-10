import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/formulario_rondin_service.dart';

class FormularioRondinScreen extends StatefulWidget {
  final String ticketId;
  final String salon;
  final String titulo;
  final String descripcion;
  final String tipo;

  const FormularioRondinScreen({
    super.key,
    required this.ticketId,
    required this.salon,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
  });

  @override
  State<FormularioRondinScreen> createState() =>
      _FormularioRondinScreenState();
}

class _FormularioRondinScreenState extends State<FormularioRondinScreen> {
  // Contadores — empiezan en 0 (el becario los rellena)
  int pcsAutoCad = 0;
  int pcsSinInternet = 0;
  int pcsNoEncienden = 0;
  int cablesDanados = 0;

  final TextEditingController _obsController = TextEditingController();
  String? _imagePath;
  bool _isUploading = false;

  final FormularioRondinService _rondinService = FormularioRondinService();

  final Color verdeUANL = const Color(0xFF1B5E20);
  final Color fondoGrisaceo = const Color(0xFFF5F9F5);

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  Future<void> _enviarReporte() async {
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ La foto de evidencia es obligatoria'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await _rondinService.completarTicket(
        ticketId: widget.ticketId,
        pcsAutoCad: pcsAutoCad,
        pcsSinInternet: pcsSinInternet,
        pcsNoEncienden: pcsNoEncienden,
        cablesDanados: cablesDanados,
        observaciones: _obsController.text.trim(),
        imagePath: _imagePath!,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reporte enviado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoGrisaceo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tipo.toUpperCase(),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Salón ${widget.salon} — ${widget.titulo}',
              style: TextStyle(
                color: verdeUANL,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Descripción del ticket
            if (widget.descripcion.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: verdeUANL.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        color: verdeUANL, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.descripcion,
                        style: TextStyle(
                            color: verdeUANL, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 1. TARJETA DE CONTADORES
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildContador(
                    'PCs con AutoCad',
                    pcsAutoCad == 0 ? 'Sin registros' : '$pcsAutoCad equipos',
                    pcsAutoCad,
                    (val) => setState(() => pcsAutoCad = val),
                    pcsAutoCad == 0 ? Colors.grey : verdeUANL,
                  ),
                  const Divider(height: 30),
                  _buildContador(
                    'PCs sin Internet',
                    pcsSinInternet == 0
                        ? 'Perfecto'
                        : '$pcsSinInternet equipos',
                    pcsSinInternet,
                    (val) => setState(() => pcsSinInternet = val),
                    pcsSinInternet == 0
                        ? const Color(0xFFEF9E4E)
                        : Colors.red,
                  ),
                  const Divider(height: 30),
                  _buildContador(
                    'No encienden',
                    pcsNoEncienden == 0
                        ? 'Perfecto'
                        : '$pcsNoEncienden equipos',
                    pcsNoEncienden,
                    (val) => setState(() => pcsNoEncienden = val),
                    pcsNoEncienden == 0
                        ? const Color(0xFFEF9E4E)
                        : Colors.red,
                  ),
                  const Divider(height: 30),
                  _buildContador(
                    'Cables sueltos/dañados',
                    cablesDanados == 0
                        ? 'Perfecto'
                        : '$cablesDanados cables',
                    cablesDanados,
                    (val) => setState(() => cablesDanados = val),
                    cablesDanados == 0
                        ? const Color(0xFFEF9E4E)
                        : Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 2. EVIDENCIA FOTOGRÁFICA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'EVIDENCIA FOTOGRÁFICA',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '* Obligatoria',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _imagePath == null
                ? InkWell(
                    onTap: _takePhoto,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: verdeUANL.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: verdeUANL.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.camera_alt_outlined,
                                color: verdeUANL, size: 30),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Tomar Foto de Evidencia',
                            style: TextStyle(
                                color: verdeUANL,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Toque para abrir la cámara',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _imagePath = null),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.clear,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 30),

            // 3. OBSERVACIONES
            const Text(
              'OBSERVACIONES (OPCIONAL)',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _obsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Añade detalles adicionales aquí...',
                hintStyle: const TextStyle(color: Colors.black38),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 4. BOTÓN ENVIAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _enviarReporte,
                style: ElevatedButton.styleFrom(
                  backgroundColor: verdeUANL,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                  disabledBackgroundColor:
                      verdeUANL.withOpacity(0.5),
                ),
                child: _isUploading
                    ? const SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined,
                              color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Enviar Reporte',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildContador(
    String titulo,
    String subtitulo,
    int valorActual,
    Function(int) onChanged,
    Color colorSubtitulo,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(subtitulo,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: colorSubtitulo)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Row(
          children: [
            _buildBotonCircular(Icons.remove, () {
              if (valorActual > 0) onChanged(valorActual - 1);
            }),
            SizedBox(
              width: 40,
              child: Center(
                child: Text('$valorActual',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            _buildBotonCircular(
                Icons.add, () => onChanged(valorActual + 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildBotonCircular(IconData icono, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icono, size: 20, color: Colors.black54),
      ),
    );
  }
}
