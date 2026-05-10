import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormularioRondinService {
  // Sube la imagen a ImgBB y devuelve la URL pública
  Future<String> subirImagen(String imagePath) async {
    const String imgbbApiKey = '673e1e8677afae170560298bfef47f2b';
    const String expiracion6Meses = '15552000';

    final uri = Uri.parse(
      'https://api.imgbb.com/1/upload?key=$imgbbApiKey&expiration=$expiracion6Meses',
    );
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('image', imagePath),
    );

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Error al subir imagen a ImgBB');
    }

    final responseData = await response.stream.bytesToString();
    final jsonResult = json.decode(responseData);
    return jsonResult['data']['url'] as String;
  }

  /// Completa un ticket existente que el admin asignó al becario.
  /// Actualiza los campos y cambia el estado a 'completado'.
  Future<void> completarTicket({
    required String ticketId,
    required int pcsAutoCad,
    required int pcsSinInternet,
    required int pcsNoEncienden,
    required int cablesDanados,
    required String observaciones,
    required String imagePath,
  }) async {
    // 1. Subir imagen
    String imageUrl = '';
    if (imagePath.isNotEmpty) {
      imageUrl = await subirImagen(imagePath);
    }

    // 2. Actualizar el documento del ticket en Firestore
    await FirebaseFirestore.instance
        .collection('tickets')
        .doc(ticketId)
        .update({
      'estado': 'completado',
      'fecha_completado': FieldValue.serverTimestamp(),
      'pcs_autocad': pcsAutoCad,
      'pcs_sin_internet': pcsSinInternet,
      'pcs_no_encienden': pcsNoEncienden,
      'cables_danados': cablesDanados,
      'observaciones': observaciones,
      'evidencia_url': imageUrl,
    });
  }
}
