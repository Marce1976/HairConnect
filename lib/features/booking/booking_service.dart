import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> saveBooking({
    required String service,
    required String date,
    required String time,
    required String stylist,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _db.collection('bookings').add({
        'userId': user.uid,
        'service': service,
        'date': date,
        'time': time,
        'stylist': stylist,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}