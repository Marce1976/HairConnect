import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  Future<void> _confirmLogout() async {
    final authBloc = context.read<AuthBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesion'),
        content: const Text('Estas seguro de que quieres cerrar sesion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      authBloc.add(LogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthInitial && previous is! AuthInitial,
      listener: (context, state) {
        if (state is AuthInitial) {
          context.go('/welcome');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Area Cliente'),
          automaticallyImplyLeading: false,
          actions: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .where('read', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        context.push('/notifications');
                      },
                    ),
                    if (count > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.push('/client/profile'),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _confirmLogout,
            ),
          ],
        ),
        body: userId == null
            ? const Center(child: Text('Usuario no autenticado'))
            : _buildBody(userId),
      ),
    );
  }

  Widget _buildBody(String userId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final userName = data?['name'] as String? ?? 'Cliente';

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Saludo ──
              Text(
                '¡Bienvenido!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              // ── Cuadrícula de acciones ──
              _ClientGrid(),

              // ── Próxima cita ──
              _NextBookingCard(userId: userId),
            ],
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Cuadrícula de tarjetas de cliente
// ──────────────────────────────────────────────────────────────
class _ClientGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = _items(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  List<Widget> _items(BuildContext context) {
    return [
      _ClientCard(
        icon: Icons.store,
        title: 'Buscar Salones',
        subtitle: 'Encuentra tu salón ideal',
        color: const Color(0xFF4A90D9),
        onTap: () => context.push('/salons'),
      ),
      _ClientCard(
        icon: Icons.image,
        title: 'Look & Book',
        subtitle: 'Inspírate y reserva',
        color: const Color(0xFFE91E63),
        onTap: () => context.push('/lookbook'),
      ),
      _ClientCard(
        icon: Icons.calendar_month,
        title: 'Mis Reservas',
        subtitle: 'Gestiona tus citas',
        color: const Color(0xFF009688),
        onTap: () => context.push('/my-bookings'),
      ),
      _ClientCard(
        icon: Icons.favorite,
        title: 'Mis Favoritos',
        subtitle: 'Tus looks guardados',
        color: const Color(0xFFFF9800),
        onTap: () => context.push('/favorites'),
      ),
    ];
  }
}

// ──────────────────────────────────────────────────────────────
// Tarjeta de próxima cita
// ──────────────────────────────────────────────────────────────
class _NextBookingCard extends StatelessWidget {
  final String userId;

  const _NextBookingCard({required this.userId});

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

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'canceled':
        return Colors.red;
      default:
        return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        // Filtrar próximas (fecha futura y no canceladas)
        final upcoming = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] as String? ?? '';
          final date = data['date'] as String? ?? '';
          return status != 'canceled' && _isDateTodayOrFuture(date);
        }).toList();

        // Ordenar por fecha ascendente
        upcoming.sort((a, b) {
          final aDate = (a.data() as Map)['date'] as String? ?? '';
          final bDate = (b.data() as Map)['date'] as String? ?? '';
          return aDate.compareTo(bDate);
        });

        final nextBooking = upcoming.isNotEmpty ? upcoming.first.data() as Map<String, dynamic> : null;

        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: AppColors.textGrey.withValues(alpha: 0.15),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: nextBooking != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            const Text(
                              'Tu próxima cita',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Salón
                        _infoRow(Icons.store,
                            nextBooking['salonName'] as String? ?? 'Salón'),
                        const SizedBox(height: 8),

                        // Fecha y hora
                        _infoRow(
                          Icons.schedule,
                          '${nextBooking['date'] ?? ''} a las ${nextBooking['time'] ?? ''}',
                        ),
                        const SizedBox(height: 8),

                        // Servicio
                        if (nextBooking['service'] != null)
                          _infoRow(Icons.content_cut,
                              nextBooking['service'] as String),
                        if (nextBooking['service'] != null)
                          const SizedBox(height: 8),

                        // Estado
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(
                                        nextBooking['status'] as String? ?? '')
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _statusColor(
                                          nextBooking['status'] as String? ?? '')
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                _statusLabel(
                                    nextBooking['status'] as String? ?? ''),
                                style: TextStyle(
                                  color: _statusColor(
                                      nextBooking['status'] as String? ?? ''),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Icon(Icons.event_busy,
                            size: 48, color: AppColors.textGrey),
                        const SizedBox(height: 12),
                        const Text(
                          'No tienes próximas citas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Explora looks y reserva tu primera cita',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/lookbook'),
                          icon: const Icon(Icons.image, size: 18),
                          label: const Text('Ver looks'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Tarjeta de acción para cliente (mismo estilo que _DashboardCard)
// ──────────────────────────────────────────────────────────────
class _ClientCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ClientCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.textGrey.withValues(alpha: 0.15),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
