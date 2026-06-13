import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hair_connect/core/services/notification_service.dart';
import 'package:hair_connect/features/business/domain/salon.dart';

class BusinessRepository {
  final FirebaseFirestore _db;
  final NotificationService _notificationService;

  BusinessRepository(
      {FirebaseFirestore? firestore, NotificationService? notificationService})
      : _db = firestore ?? FirebaseFirestore.instance,
        _notificationService =
            notificationService ?? NotificationService();

  Stream<QuerySnapshot> getBookings() {
    return _db
        .collection('bookings')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllBookings() {
    return _db.collection('bookings').snapshots();
  }

  Stream<QuerySnapshot> getStylists() {
    return _db.collection('stylists').snapshots();
  }

  Stream<QuerySnapshot> getServices() {
    return _db.collection('services').snapshots();
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
    required String userId,
  }) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': status,
    });

    if (status == 'confirmed') {
      await _notificationService.sendNotification(
        userId: userId,
        title: 'Reserva confirmada',
        message: 'Tu reserva ha sido confirmada.',
      );
    } else if (status == 'canceled') {
      await _notificationService.sendNotification(
        userId: userId,
        title: 'Reserva cancelada',
        message: 'Tu reserva ha sido cancelada.',
      );
    }
  }

  Future<void> addStylist(String name) async {
    try {
      await _db.collection('stylists').add({
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al añadir estilista: $e');
    }
  }

  Future<void> deleteStylist(String stylistId) async {
    try {
      await _db.collection('stylists').doc(stylistId).delete();
    } catch (e) {
      throw Exception('Error al eliminar estilista: $e');
    }
  }

  Future<void> addService(
    String name,
    String price,
    String duration,
  ) async {
    try {
      await _db.collection('services').add({
        'name': name,
        'price': price,
        'duration': duration,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al añadir servicio: $e');
    }
  }

  Future<void> updateService({
    required String serviceId,
    required String name,
    required String price,
    required String duration,
  }) async {
    try {
      await _db.collection('services').doc(serviceId).update({
        'name': name,
        'price': price,
        'duration': duration,
      });
    } catch (e) {
      throw Exception('Error al actualizar servicio: $e');
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _db.collection('services').doc(serviceId).delete();
    } catch (e) {
      throw Exception('Error al eliminar servicio: $e');
    }
  }

  Stream<QuerySnapshot> getSalons() {
    return _db.collection('salons').snapshots();
  }

  /// Devuelve todos los salones de una ciudad específica.
  Stream<QuerySnapshot> getSalonsByCity(String city) {
    return _db
        .collection('salons')
        .where('city', isEqualTo: city)
        .snapshots();
  }

  /// Devuelve una lista de ciudades disponibles (única por salón).
  Future<List<String>> getAvailableCities() async {
    final snapshot = await _db.collection('salons').get();
    final cities = snapshot.docs
        .map((doc) => (doc.data()['city'] as String?) ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    cities.sort();
    return cities;
  }

  Future<DocumentSnapshot> getSalonById(String salonId) async {
    try {
      return await _db.collection('salons').doc(salonId).get();
    } catch (e) {
      throw Exception('Error al obtener salón: $e');
    }
  }

  Future<String> createSalon({
    required String name,
    required String address,
    String? city,
    String? phone,
    String? description,
  }) async {
    try {
      final doc = await _db.collection('salons').add({
        'name': name,
        'address': address,
        '?city': city,
        '?phone': phone,
        '?description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      throw Exception('Error al crear salón: $e');
    }
  }

  Future<void> updateSalon({
    required String salonId,
    required String name,
    required String address,
    String? city,
    String? phone,
    String? description,
  }) async {
    try {
      await _db.collection('salons').doc(salonId).update({
        'name': name,
        'address': address,
        '?city': city,
        '?phone': phone,
        '?description': description,
      });
    } catch (e) {
      throw Exception('Error al actualizar salón: $e');
    }
  }

  Future<List<Salon>> searchSalons({String? query}) async {
    try {
      final collection = _db.collection('salons');

      if (query != null && query.isNotEmpty) {
        final snapshot = await collection
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: '$query\uf8ff')
            .get();
        return snapshot.docs
            .map((doc) =>
                Salon.fromMap(doc.id, doc.data()))
            .toList();
      }

      final snapshot = await collection.get();
      return snapshot.docs
          .map((doc) =>
              Salon.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar salones: $e');
    }
  }

  Future<void> addGalleryImage(String salonId, String imageUrl) async {
    try {
      final doc = await _db.collection('salons').doc(salonId).get();
      final data = doc.data();
      final List<String> images = data != null && data['galleryImages'] != null
          ? List<String>.from(data['galleryImages'])
          : [];
      images.add(imageUrl);
      await _db.collection('salons').doc(salonId).update({
        'galleryImages': images,
      });
    } catch (e) {
      throw Exception('Error al añadir imagen a la galería: $e');
    }
  }

  Future<void> removeGalleryImage(String salonId, String imageUrl) async {
    try {
      final doc = await _db.collection('salons').doc(salonId).get();
      final data = doc.data();
      if (data == null || data['galleryImages'] == null) return;
      final images = List<String>.from(data['galleryImages']);
      images.remove(imageUrl);
      await _db.collection('salons').doc(salonId).update({
        'galleryImages': images,
      });
    } catch (e) {
      throw Exception('Error al eliminar imagen de la galería: $e');
    }
  }
}