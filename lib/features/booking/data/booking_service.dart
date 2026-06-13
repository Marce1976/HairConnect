import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  BookingService({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = firebaseAuth ?? FirebaseAuth.instance;

  Future<bool> saveBooking({
    required String service,
    required String date,
    required String time,
    required String stylist,
    required String businessId,
    String? lookId,
    String? salonName,
    List<String>? services,
    String? price,
    String? status,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final data = <String, dynamic>{
        'userId': user.uid,
        'businessId': businessId,
        'service': service,
        'date': date,
        'time': time,
        'stylist': stylist,
        'status': status ?? 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (lookId != null) data['lookId'] = lookId;
      if (salonName != null) data['salonName'] = salonName;
      if (services != null) data['services'] = services;
      if (price != null) data['price'] = price;

      await _db.collection('bookings').add(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateBookingWithLook(String bookingId, String lookId) async {
    try {
      await _db.collection('bookings').doc(bookingId).update({
        'lookId': lookId,
      });
    } catch (e) {
      throw Exception('Error al asociar look a la reserva: $e');
    }
  }
}