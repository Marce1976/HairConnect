import 'package:flutter/material.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _showStatusUpdateDialog(String bookingId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Confirmada'),
              leading: const Icon(Icons.check_circle, color: Colors.green),
              onTap: () async {
                await _db.collection('bookings').doc(bookingId).update({
                  'status': 'confirmed',
                });
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Pendiente'),
              leading: const Icon(Icons.pending, color: Colors.orange),
              onTap: () async {
                await _db.collection('bookings').doc(bookingId).update({
                  'status': 'pending',
                });
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Cancelada'),
              leading: const Icon(Icons.cancel, color: Colors.red),
              onTap: () async {
                await _db.collection('bookings').doc(bookingId).update({
                  'status': 'canceled',
                });
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('bookings')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar la agenda'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No hay reservas por el momento',
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
            return GestureDetector(
              onTap: () => _showStatusUpdateDialog(
                bookings[index].id,
                booking['status'] ?? 'pending',
              ),
              child: Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking['status'] ?? 'pending').withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      booking['status'] ?? 'Pendiente',
                      style: TextStyle(
                        color: _getStatusColor(booking['status'] ?? 'pending'),
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
