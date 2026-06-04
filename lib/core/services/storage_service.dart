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

      final ref = _storage
          .ref()
          .child('salons')
          .child(salonId)
          .child('gallery')
          .child('$fileName.jpg');

      await ref.putFile(File(image.path));
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error al subir imagen: $e');
      return null;
    }
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
