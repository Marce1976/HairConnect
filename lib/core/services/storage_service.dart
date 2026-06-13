import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage;
  final ImagePicker _picker;

  StorageService({
    FirebaseStorage? storage,
    ImagePicker? picker,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker();

  /// Abre la galería y devuelve la URL de la imagen subida.
  Future<String?> uploadImage({
    required String salonId,
    required String fileName,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image == null) return null;

      return uploadFromFile(
        filePath: image.path,
        salonId: salonId,
        fileName: fileName,
      );
    } catch (e) {
      debugPrint('Error al subir imagen: $e');
      return null;
    }
  }

  /// Sube una imagen ya seleccionada (por su ruta) a Firebase Storage.
  /// Lanza una excepción con el detalle si falla.
  Future<String> uploadFromFile({
    required String filePath,
    required String salonId,
    required String fileName,
  }) async {
    final ref = _storage
        .ref()
        .child('salons')
        .child(salonId)
        .child('gallery')
        .child('$fileName.jpg');

    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }

  Future<void> deleteImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('Error al eliminar imagen: $e');
    }
  }
}
