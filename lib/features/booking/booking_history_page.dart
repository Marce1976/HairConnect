import 'package:flutter/material.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Reservas'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db
            .collection('bookings')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No tienes reservas aún',
                style: TextStyle(color: AppColors.textGrey),
              ),
            );
          }
          final bookings = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.content_cut, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    booking['service'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${booking['date'] ?? ''} a las ${booking['time'] ?? ''} ${booking['stylist'] != null ? 'con ${booking['stylist']},' : ''}',
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: booking['status'] == 'completed'
                          ? Colors.green
                          : booking['status'] == 'canceled'
                              ? Colors.red
                              : Colors.orange,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      booking['status'] != null
                          ? booking['status'].toString().toUpperCase()
                          : 'PENDIENTE',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}