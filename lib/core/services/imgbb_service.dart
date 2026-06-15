import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Servicio para subir imágenes a ImgBB (https://imgbb.com).
///
/// La API Key se pasa vía `--dart-define=IMGBB_API_KEY=xxx`
/// o se puede inicializar directamente con [ImgbbService.init].
class ImgbbService {
  ImgbbService._();

  /// Instancia global única.
  static final ImgbbService instance = ImgbbService._();

  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  /// API Key obtenida de imgbb.
  String _apiKey = '';

  /// Inicializa el servicio con la API Key.
  /// Se puede llamar desde main.dart al arrancar la app.
  void init(String apiKey) {
    _apiKey = apiKey;
  }

  /// `true` si se ha configurado una API Key.
  bool get isConfigured => _apiKey.isNotEmpty;

  /// Sube una imagen a ImgBB y devuelve su URL directa.
  ///
  /// [filePath] es la ruta local del archivo a subir.
  ///
  /// Lanza [Exception] si no hay API Key o si el upload falla.
  Future<String> uploadImage(String filePath) async {
    if (!isConfigured) {
      throw Exception(
        'ImgBB no configurado. '
        'Llama a ImgbbService.instance.init(tuApiKey) al iniciar la app.',
      );
    }

    final uri = Uri.parse('$_uploadUrl?key=$_apiKey');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', filePath));

      final streamedResponse = await request.send();
      final body = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final json = jsonDecode(body) as Map<String, dynamic>;

        if (json['success'] == true) {
          final data = json['data'] as Map<String, dynamic>;
          // Devuelve la URL directa de la imagen
          return data['url'] as String;
        } else {
          final error = json['error']?['message'] ??
              json['status'] ??
              'Error desconocido';
          throw Exception('ImgBB: $error');
        }
      } else {
        throw Exception(
          'Error ImgBB (${streamedResponse.statusCode}): $body',
        );
      }
    } catch (e) {
      debugPrint('ImgbbService.uploadImage error: $e');
      rethrow;
    }
  }
}
