import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hair_connect/core/services/notification_service.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Página unificada "Mis Reservas" para clientes.
///
/// Muestra todas las reservas del usuario agrupadas en:
/// - **Próximas**: activas (confirmed/pending) con fecha futura.
/// - **Anteriores**: pasadas o canceladas.
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  String? _cancellingId;

  // ── Helpers de fecha ────────────────────────────────────────

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

  String _formatDateShort(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) return dateStr;
      final months = [
        '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
      ];
      final month = int.parse(parts[1]);
      return '${parts[0]} ${months[month]} ${parts[2]}';
    } catch (_) {
      return dateStr;
    }
  }

  // ── Cancelar reserva ─────────────────────────────────────────

  Future<void> _cancelBooking(String bookingId) async {
    setState(() => _cancellingId = bookingId);
    try {
      // Leer datos de la reserva antes de cancelar
      final bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();
      final bookingData = bookingDoc.data();

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .set({'status': 'canceled'}, SetOptions(merge: true));

      // Notificar al salón si existe
      if (bookingData != null) {
        final salonId = bookingData['salonId'] as String?;
        if (salonId != null) {
          final salonDoc = await FirebaseFirestore.instance
              .collection('salons')
              .doc(salonId)
              .get();
          final ownerId = salonDoc.data()?['ownerId'] as String?;
          if (ownerId != null) {
            final notificationService = NotificationService();
            await notificationService.sendNotification(
              userId: ownerId,
              title: 'Reserva cancelada',
              message:
                  'Un cliente canceló su reserva en ${bookingData['salonName'] ?? 'el salón'}',
            );
          }
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva cancelada'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _cancellingId = null);
    }
  }

  void _showCancelDialog(String bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar reserva'),
        content: const Text('¿Estás seguro de que deseas cancelar esta reserva?'),
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

  // ── Helpers de estado ────────────────────────────────────────

  Color _statusColor(String status) {
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

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis Reservas'), automaticallyImplyLeading: false),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: AppColors.textGrey),
              const SizedBox(height: 16),
              Text(
                'Inicia sesión para ver tus reservas',
                style: TextStyle(color: AppColors.textGrey, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/login/client'),
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Reservas'), automaticallyImplyLeading: false),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          // Clasificar reservas
          final upcoming = <QueryDocumentSnapshot>[];
          final past = <QueryDocumentSnapshot>[];

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] as String? ?? '';
            final date = data['date'] as String? ?? '';

            if (status == 'canceled') {
              past.add(doc);
            } else if (_isDateTodayOrFuture(date)) {
              upcoming.add(doc);
            } else {
              past.add(doc);
            }
          }

          // Ordenar próximas por fecha ascendente (más próxima primero)
          upcoming.sort((a, b) => _compareDate(a, b, asc: true));
          // Ordenar anteriores por fecha descendente (más reciente primero)
          past.sort((a, b) => _compareDate(a, b, asc: false));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (upcoming.isNotEmpty) ...[
                _sectionHeader('Próximas', upcoming.length),
                ...upcoming.map((doc) => _buildBookingCard(doc, isUpcoming: true)),
                const SizedBox(height: 24),
              ],
              if (past.isNotEmpty) ...[
                _sectionHeader('Anteriores', past.length),
                ...past.map((doc) => _buildBookingCard(doc, isUpcoming: false)),
              ],
            ],
          );
        },
      ),
    );
  }

  int _compareDate(QueryDocumentSnapshot a, QueryDocumentSnapshot b,
      {required bool asc}) {
    final aDate =
        ((a.data() as Map)['createdAt'] as Timestamp?)?.toDate() ??
            DateTime(2000);
    final bDate =
        ((b.data() as Map)['createdAt'] as Timestamp?)?.toDate() ??
            DateTime(2000);
    return asc ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: AppColors.textGrey),
            const SizedBox(height: 24),
            Text(
              'No tienes reservas aún',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explora looks y reserva tu primera cita',
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
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

  Widget _sectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(QueryDocumentSnapshot doc,
      {required bool isUpcoming}) {
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'pending';
    final bookingId = doc.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.textGrey.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: salón + estado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    data['salonName'] as String? ?? data['service'] as String? ?? 'Reserva',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _statusColor(status).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      color: _statusColor(status),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Fecha
            _infoRow(Icons.calendar_today,
                '${_formatDateShort(data['date'] ?? '')} a las ${data['time'] ?? '—'}'),
            const SizedBox(height: 6),

            // Estilista
            _infoRow(Icons.person, 'Con ${data['stylist'] ?? '—'}'),
            const SizedBox(height: 6),

            // Servicios
            if (data['services'] != null &&
                (data['services'] as List).isNotEmpty)
              _infoRow(Icons.content_cut,
                  (data['services'] as List).join(', ')),

            // Precio
            if (data['price'] != null &&
                (data['price'] as String).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '€${double.tryParse(data['price'] as String)?.toStringAsFixed(2) ?? data['price']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.primary,
                ),
              ),
            ],

            // Botón cancelar (solo próximas activas)
            if (isUpcoming && (status == 'confirmed' || status == 'pending')) ...[
              const Divider(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _cancellingId == bookingId
                      ? null
                      : () => _showCancelDialog(bookingId),
                  icon: _cancellingId == bookingId
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cancel, color: Colors.red, size: 18),
                  label: Text(
                    _cancellingId == bookingId
                        ? 'Cancelando...'
                        : 'Cancelar reserva',
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textGrey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
