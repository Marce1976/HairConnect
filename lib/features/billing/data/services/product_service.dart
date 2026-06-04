import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> create(String id, String name, double price, int stock) async {
    await _firestore.collection('products').doc(id).set({
      'name': name,
      'price': price,
      'stock': stock,
    });
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final querySnapshot = await _firestore.collection('products').get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> update(String id, String name, double price, int stock) async {
    await _firestore.collection('products').doc(id).update({
      'name': name,
      'price': price,
      'stock': stock,
    });
  }

  Future<void> delete(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }
}
