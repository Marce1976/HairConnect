import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hair_connect/features/business/domain/look.dart';

class LookRepository {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  LookRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _db = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Stream<QuerySnapshot> getLooks() {
    return _db
        .collection('looks')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getLooksBySalon(String salonId) {
    return _db
        .collection('looks')
        .where('salonId', isEqualTo: salonId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getLooksByStylist(String stylistId) {
    return _db
        .collection('looks')
        .where('stylistId', isEqualTo: stylistId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot?> getLookById(String lookId) async {
    try {
      return await _db.collection('looks').doc(lookId).get();
    } catch (e) {
      throw Exception('Error al obtener look: $e');
    }
  }

  Future<void> addLook(Look look) async {
    try {
      await _db.collection('looks').add(look.toMap());
    } catch (e) {
      throw Exception('Error al añadir look: $e');
    }
  }

  Future<void> deleteLook(String lookId) async {
    try {
      final snapshot = await _db.collection('looks').doc(lookId).get();
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          final imageUrl = data['imageUrl'] as String?;
          if (imageUrl != null && imageUrl.isNotEmpty) {
            try {
              await _storage.refFromURL(imageUrl).delete();
            } catch (_) {
              // Si falla la eliminación de Storage, continuamos
            }
          }
        }
      }
      await _db.collection('looks').doc(lookId).delete();
    } catch (e) {
      throw Exception('Error al eliminar look: $e');
    }
  }

  Future<void> updateLook(String lookId, Map<String, dynamic> updates) async {
    try {
      await _db.collection('looks').doc(lookId).update(updates);
    } catch (e) {
      throw Exception('Error al actualizar look: $e');
    }
  }
}
