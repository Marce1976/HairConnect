import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hair_connect/features/booking/presentation/bloc/booking_bloc.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  void _showCancelDialog(String bookingId, String businessId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta reserva?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<BookingBloc>().add(
                    CancelBooking(
                      bookingId: bookingId,
                      businessId: businessId,
                    ),
                  );
              Navigator.pop(context);
            },
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(
      String docId, Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'pending';
    final isActive = status == 'confirmed' || status == 'pending';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Detalle de la Reserva'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (booking['salonName'] != null &&
                (booking['salonName'] as String).isNotEmpty)
              _detailRow(Icons.store, booking['salonName']),
            const SizedBox(height: 8),
            _detailRow(Icons.content_cut, booking['service'] ?? ''),
            if (booking['services'] != null &&
                (booking['services'] as List).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Servicios: ${(booking['services'] as List).join(', ')}',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            _detailRow(
                Icons.person, 'Con ${booking['stylist'] ?? '—'}'),
            const SizedBox(height: 8),
            _detailRow(Icons.calendar_today, booking['date'] ?? ''),
            const SizedBox(height: 8),
            _detailRow(Icons.access_time, booking['time'] ?? ''),
            if (booking['price'] != null &&
                (booking['price'] as String).isNotEmpty) ...[
              const SizedBox(height: 8),
              _detailRow(Icons.euro, '€${booking['price']}'),
            ],
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(status),
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (isActive)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showCancelDialog(docId, booking['businessId'] ?? '');
              },
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text(
                'Cancelar reserva',
                style: TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
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
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reserva cancelada exitosamente.'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Historial de Reservas')),
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
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy,
                        size: 64, color: AppColors.textGrey),
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
                final isActive =
                    status == 'confirmed' || status == 'pending';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _showDetailDialog(doc.id, booking),
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
                              const Icon(Icons.calendar_today,
                                  size: 14, color: AppColors.textGrey),
                              const SizedBox(width: 4),
                              Text(
                                '${booking['date'] ?? ''} a las ${booking['time'] ?? ''}',
                                style: const TextStyle(
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
                              const Icon(Icons.person,
                                  size: 14, color: AppColors.textGrey),
                              const SizedBox(width: 4),
                              Text(
                                'Con ${booking['stylist'] ?? '—'}',
                                style: const TextStyle(
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
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],

                          // Price + cancel button
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (booking['price'] != null &&
                                  (booking['price'] as String).isNotEmpty)
                                Text(
                                  '€${booking['price']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                              if (isActive)
                                TextButton.icon(
                                  onPressed: () => _showCancelDialog(
                                    doc.id,
                                    booking['businessId'] ?? '',
                                  ),
                                  icon: const Icon(Icons.cancel,
                                      size: 16, color: Colors.red),
                                  label: const Text(
                                    'Cancelar',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 13),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
