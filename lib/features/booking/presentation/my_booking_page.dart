import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyBookingPage extends StatefulWidget {
  const MyBookingPage({super.key});

  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  bool _isCancelling = false;

  Future<void> _cancelBooking(String bookingId) async {
    setState(() => _isCancelling = true);
    try {
      // Usar set con merge: más robusto que update (crea el campo si no existe)
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .set({'status': 'canceled'}, SetOptions(merge: true));

      if (!mounted) return;

      // Leer el documento para verificar que el cambio se aplicó
      final doc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();
      if (!mounted) return;
      final status = doc.data()?['status'] as String?;

      if (status == 'canceled') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva cancelada exitosamente.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error: el estado sigue siendo "$status". Inténtalo de nuevo.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  void _showCancelDialog(String bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar Reserva'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta reserva?',
        ),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _cancelBooking(bookingId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Sí, cancelar'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('No'),
                ),
              ),
            ],
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
          child: Text(text, style: const TextStyle(fontSize: 14)),
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

  bool _isDateTodayOrFuture(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) return false;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final bookingDate = DateTime(year, month, day);
      final today = DateTime.now();
      return bookingDate.isAfter(today.subtract(const Duration(days: 1)));
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Cita'), automaticallyImplyLeading: false),
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
                'Error al cargar: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // Filtrar: activas = futuras y no canceladas
          final activeBookings = (snapshot.data?.docs ?? []).where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] as String? ?? '';
            if (status == 'canceled') return false;
            final date = data['date'] as String? ?? '';
            return _isDateTodayOrFuture(date);
          }).toList();

          if (activeBookings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy,
                        size: 80, color: AppColors.textGrey),
                    const SizedBox(height: 24),
                    Text(
                      'No tienes citas próximas',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explora looks y reserva tu primera cita',
                      style: TextStyle(
                          color: AppColors.textGrey, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/lookbook'),
                        icon: const Icon(Icons.image),
                        label: const Text('Buscar looks'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Ordenar por fecha (más próxima primero)
          activeBookings.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aDateStr = aData['date'] as String? ?? '';
            final bDateStr = bData['date'] as String? ?? '';
            return aDateStr.split('/').reversed.join().compareTo(
                bDateStr.split('/').reversed.join());
          });

          final booking = activeBookings.first;
          final data = booking.data() as Map<String, dynamic>;
          final status = data['status'] as String? ?? 'pending';
          final isActive = status == 'confirmed' || status == 'pending';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge de estado
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(status)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _statusLabel(status),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Información detallada
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data['salonName'] != null &&
                            (data['salonName'] as String).isNotEmpty) ...[
                          _detailRow(
                              Icons.store, data['salonName'] as String),
                          const SizedBox(height: 16),
                        ],
                        _detailRow(
                            Icons.content_cut, data['service'] ?? ''),
                        const SizedBox(height: 16),
                        if (data['services'] != null &&
                            (data['services'] as List).isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Servicios: ${(data['services'] as List).join(', ')}',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                        _detailRow(Icons.person,
                            'Con ${data['stylist'] ?? '—'}'),
                        const SizedBox(height: 16),
                        _detailRow(
                            Icons.calendar_today, data['date'] ?? ''),
                        const SizedBox(height: 16),
                        _detailRow(
                            Icons.access_time, data['time'] ?? ''),
                        if (data['price'] != null &&
                            (data['price'] as String).isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.euro,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                '€${double.tryParse(data['price'] as String)?.toStringAsFixed(2) ?? data['price']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón cancelar
                if (isActive)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isCancelling
                          ? null
                          : () =>
                              _showCancelDialog(booking.id),
                      icon: _isCancelling
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : const Icon(Icons.cancel, color: Colors.red),
                      label: Text(
                        _isCancelling
                            ? 'Cancelando...'
                            : 'Cancelar reserva',
                        style: const TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
