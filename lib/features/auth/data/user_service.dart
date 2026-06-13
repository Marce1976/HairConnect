import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db;

  UserService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  Future<void> saveUser(User user, String name, bool isClient) async {
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': user.email?.toLowerCase(),
      'isClient': isClient,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Verifica si el usuario autenticado tiene rol de administrador.
  /// Se considera admin si su documento en `users/{uid}` tiene `isAdmin: true`.
  Future<bool> isAdmin(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return false;
      return (doc.data()?['isAdmin'] as bool?) ?? false;
    } catch (_) {
      return false;
    }
  }
}
