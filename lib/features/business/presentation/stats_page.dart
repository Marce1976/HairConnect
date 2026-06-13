import 'package:flutter/material.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = sl<BusinessRepository>();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Text(
              'Resumen',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Estadísticas generales de tu negocio',
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // ---- Fila: 3 cards de totales ----
            Row(
              children: [
                Expanded(
                  child: _buildBookingTotalCard(repository),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStylistTotalCard(repository),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildServiceTotalCard(repository),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ---- Ingresos e indicadores por estado ----
            StreamBuilder<QuerySnapshot>(
              stream: repository.getAllBookings(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                final confirmed =
                    docs.where((d) => (d.data() as Map)['status'] == 'confirmed').length;
                final pending =
                    docs.where((d) => (d.data() as Map)['status'] == 'pending').length;
                final canceled =
                    docs.where((d) => (d.data() as Map)['status'] == 'canceled').length;

                double totalRevenue = 0;
                for (final doc in docs) {
                  final price = (doc.data() as Map)['price'] as String?;
                  if (price != null && price.isNotEmpty) {
                    totalRevenue += int.tryParse(price) ?? 0;
                  }
                }

                return Column(
                  children: [
                    _StatCard(
                      icon: Icons.euro,
                      title: 'Ingresos estimados',
                      value: '€${totalRevenue.toStringAsFixed(0)}',
                      color: Colors.green,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Reservas por estado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatusBadge(
                          label: 'Confirmadas',
                          count: confirmed,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        _StatusBadge(
                          label: 'Pendientes',
                          count: pending,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _StatusBadge(
                          label: 'Canceladas',
                          count: canceled,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // ---- Próximas citas ----
            const Text(
              'Próximas citas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildUpcomingBookings(repository),
          ],
        ),
      ),
    );
  }

  // ── Tarjeta de total de reservas ──
  Widget _buildBookingTotalCard(BusinessRepository repository) {
    return StreamBuilder<QuerySnapshot>(
      stream: repository.getAllBookings(),
      builder: (context, snapshot) {
        final total = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return _StatCard(
          icon: Icons.calendar_today,
          title: 'Reservas',
          value: total.toString(),
          color: AppColors.primary,
        );
      },
    );
  }

  // ── Tarjeta de total de estilistas ──
  Widget _buildStylistTotalCard(BusinessRepository repository) {
    return StreamBuilder<QuerySnapshot>(
      stream: repository.getStylists(),
      builder: (context, snapshot) {
        final total = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return _StatCard(
          icon: Icons.people,
          title: 'Estilistas',
          value: total.toString(),
          color: Colors.teal,
        );
      },
    );
  }

  // ── Tarjeta de total de servicios ──
  Widget _buildServiceTotalCard(BusinessRepository repository) {
    return StreamBuilder<QuerySnapshot>(
      stream: repository.getServices(),
      builder: (context, snapshot) {
        final total = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return _StatCard(
          icon: Icons.content_cut,
          title: 'Servicios',
          value: total.toString(),
          color: Colors.indigo,
        );
      },
    );
  }

  // ── Lista de próximas citas ──
  Widget _buildUpcomingBookings(BusinessRepository repository) {
    return StreamBuilder<QuerySnapshot>(
      stream: repository.getBookings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Cargando...')),
            ),
          );
        }

        final now = DateTime.now();
        final todayStr = '${now.day}/${now.month}/${now.year}';
        final upcoming = snapshot.data!.docs
            .where((doc) {
              final data = doc.data() as Map;
              final date = data['date'] as String? ?? '';
              final status = data['status'] as String? ?? '';
              return status != 'canceled' && date.compareTo(todayStr) >= 0;
            })
            .take(5)
            .toList();

        if (upcoming.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No hay próximas citas',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
            ),
          );
        }

        return Column(
          children: upcoming.map((doc) {
            final data = doc.data() as Map;
            final status = data['status'] as String? ?? 'pending';
            final isConfirmed = status == 'confirmed';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                title: Text(
                  data['service'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${data['date'] ?? ''} a las ${data['time'] ?? ''} — ${data['stylist'] ?? '—'}',
                  style: const TextStyle(color: AppColors.textGrey),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isConfirmed ? Colors.green : Colors.orange)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isConfirmed ? 'Confirmada' : 'Pendiente',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isConfirmed ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Tarjeta de estadística individual
// ──────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              radius: 22,
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Badge pequeño para desglose por estado
// ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
