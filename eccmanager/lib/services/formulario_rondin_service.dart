import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http; // Para conectar con ImgBB
import 'dart:convert'; // Para leer la respuesta de ImgBB

class FormularioRondinService {
  Future<void> enviarReporte({
    required String salon,
    required int pcsAutoCad,
    required int pcsSinInternet,
    required int pcsNoEncienden,
    required int cablesDanados,
    required String observaciones,
    required String imagePath,
  }) async {
    // 1. Configuración de ImgBB
    // 🔴 IMPORTANTE: Reemplaza este texto por tu API Key real de ImgBB
    const String imgbbApiKey = '673e1e8677afae170560298bfef47f2b';
    const String expiracion6Meses = '15552000'; // 180 días en segundos

    var uri = Uri.parse(
      'https://api.imgbb.com/1/upload?key=$imgbbApiKey&expiration=$expiracion6Meses',
    );
    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('image', imagePath),
    );

    // 2. Subimos la foto a ImgBB
    var response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Error al subir imagen a ImgBB');
    }

    // 3. Extraemos el link público que nos devuelve ImgBB
    var responseData = await response.stream.bytesToString();
    var jsonResult = json.decode(responseData);
    String imageUrl = jsonResult['data']['url'];

    // 4. Guardar todo el ticket en Firestore
    await FirebaseFirestore.instance.collection('tickets').add({
      'tipo': 'rondin_software',
      'salon': salon,
      'fecha': FieldValue.serverTimestamp(),
      'pcs_autocad': pcsAutoCad,
      'pcs_sin_internet': pcsSinInternet,
      'pcs_no_encienden': pcsNoEncienden,
      'cables_danados': cablesDanados,
      'observaciones': observaciones,
      'evidencia_url': imageUrl,
      'estado': 'completado',
      'usuario': 'prueba1@gmail.com',
    });
  }
}