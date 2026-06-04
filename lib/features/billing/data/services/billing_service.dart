import 'package:cloud_firestore/cloud_firestore.dart';

class BillingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createInvoice(Map<String, dynamic> invoice) async {
    await _firestore.collection('invoices').add(invoice);
  }

  Future<List<Map<String, dynamic>>> getInvoices() async {
    return _firestore.collection('invoices').get().then((querySnapshot) {
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> updateInvoice(Map<String, dynamic> invoice) async {
    await _firestore.collection('invoices').doc(invoice['id']).update(invoice);
  }

  Future<void> deleteInvoice(String id) async {
    await _firestore.collection('invoices').doc(id).delete();
  }
}
