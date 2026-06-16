import 'package:flutter/material.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  // Sin popup de detalle: el estado se ve directamente en la tarjeta

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

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmada';
      case 'pending':
        return 'Pendiente';
      case 'canceled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Reservas'), automaticallyImplyLeading: false),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar reservas: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: AppColors.textGrey),
                  SizedBox(height: 16),
                  Text(
                    'No tienes reservas aún',
                    style:
                        TextStyle(color: AppColors.textGrey, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explora looks y reserva tu primera cita',
                    style:
                        TextStyle(color: AppColors.textGrey, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          final bookings = snapshot.data!.docs;
          // Ordenar por fecha de creación (más reciente primero)
          bookings.sort((a, b) {
            final aDate =
                ((a.data() as Map)['createdAt'] as Timestamp?)?.toDate() ??
                    DateTime(2000);
            final bDate =
                ((b.data() as Map)['createdAt'] as Timestamp?)?.toDate() ??
                    DateTime(2000);
            return bDate.compareTo(aDate);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final doc = bookings[index];
              final booking = doc.data() as Map<String, dynamic>;
              final status = booking['status'] ?? 'pending';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: salon name + status
                        Row(
                          children: [
                            if (booking['salonName'] != null &&
                                (booking['salonName'] as String).isNotEmpty)
                              Expanded(
                                child: Text(
                                  booking['salonName'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: Text(
                                  booking['service'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _statusLabel(status),
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Date + time
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 14, color: AppColors.textGrey),
                            const SizedBox(width: 4),
                            Text(
                              '${booking['date'] ?? ''} a las ${booking['time'] ?? ''}',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Stylist
                        Row(
                          children: [
                            Icon(Icons.person,
                                size: 14, color: AppColors.textGrey),
                            const SizedBox(width: 4),
                            Text(
                              'Con ${booking['stylist'] ?? '—'}',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                        // Services list
                        if (booking['services'] != null &&
                            (booking['services'] as List).isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            (booking['services'] as List).join(', '),
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],

                        // Price
                        if (booking['price'] != null &&
                            (booking['price'] as String).isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '€${booking['price']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
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
