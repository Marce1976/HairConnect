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
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _db.collection('bookings').add({
        'userId': user.uid,
        'businessId': businessId,
        'service': service,
        'date': date,
        'time': time,
        'stylist': stylist,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}