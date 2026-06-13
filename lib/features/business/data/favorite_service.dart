import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hair_connect/features/business/domain/favorite.dart';

class FavoriteService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FavoriteService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<bool> toggleFavorite(String lookId, String salonId) async {
    final userId = _auth.currentUser!.uid;
    final docId = '${userId}_$lookId';
    final doc = await _firestore.collection('favorites').doc(docId).get();

    if (doc.exists) {
      await _firestore.collection('favorites').doc(docId).delete();
      return false;
    } else {
      await _firestore.collection('favorites').doc(docId).set({
        'userId': userId,
        'lookId': lookId,
        'salonId': salonId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    }
  }

  Future<bool> isFavorite(String lookId) async {
    final userId = _auth.currentUser!.uid;
    final doc = await _firestore.collection('favorites').doc('${userId}_$lookId').get();
    return doc.exists;
  }

  Stream<QuerySnapshot> getFavoritesStream() {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .snapshots();
  }

  Future<List<Favorite>> getFavorites() async {
    final userId = _auth.currentUser!.uid;
    final snapshot = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      return Favorite.fromMap(doc.id, doc.data());
    }).toList();
  }
}
