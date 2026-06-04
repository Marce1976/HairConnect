import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> create(Map<String, dynamic> order) async {
    await _firestore.collection('orders').add(order);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final querySnapshot = await _firestore.collection('orders').get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> update(String id, Map<String, dynamic> order) async {
    await _firestore.collection('orders').doc(id).update(order);
  }

  Future<void> delete(String id) async {
    await _firestore.collection('orders').doc(id).delete();
  }
}
