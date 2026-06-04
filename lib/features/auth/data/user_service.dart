import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db;

  UserService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  Future<void> saveUser(User user, String name, bool isClient) async {
    await _db.collection('users').doc(user.uid).set({
      'uid':user.uid,
      'name': name,
      'email': user.email,
      'isClient': isClient,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
