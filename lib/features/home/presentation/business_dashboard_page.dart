import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hair_connect/core/theme/app_colors.dart';

/// Pantalla de inicio del propietario del negocio.
/// Muestra el nombre del salón y tarjetas de acceso rápido a cada función.
class BusinessDashboardPage extends StatefulWidget {
  const BusinessDashboardPage({super.key});

  @override
  State<BusinessDashboardPage> createState() => _BusinessDashboardPageState();
}

class _BusinessDashboardPageState extends State<BusinessDashboardPage> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;
      if (user == null) {
        context.go('/welcome');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('Usuario no autenticado'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('salons')
          .where('ownerId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        final salonData = docs.isNotEmpty
            ? docs.first.data() as Map<String, dynamic>?
            : null;
        final salonName = salonData?['name'] as String? ?? 'Mi Negocio';

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
                salonName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              // ── Cuadrícula de gestión ──
              _DashboardGrid(),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardGrid extends StatelessWidget {
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
      _DashboardCard(
        icon: Icons.calendar_today,
        title: 'Mi Agenda',
        subtitle: 'Citas y horarios',
        color: const Color(0xFF4A90D9),
        onTap: () => context.push('/business/home/agenda'),
      ),
      _DashboardCard(
        icon: Icons.people,
        title: 'Estilistas',
        subtitle: 'Gestiona tu equipo',
        color: const Color(0xFF7C4DFF),
        onTap: () => context.push('/business/home/stylists'),
      ),
      _DashboardCard(
        icon: Icons.content_cut,
        title: 'Servicios',
        subtitle: 'Precios e inventario',
        color: const Color(0xFFE91E63),
        onTap: () => context.push('/business/home/services'),
      ),
      _DashboardCard(
        icon: Icons.image,
        title: 'Looks',
        subtitle: 'Galería de trabajos',
        color: const Color(0xFFFF9800),
        onTap: () => context.push('/business/home/looks'),
      ),
      _DashboardCard(
        icon: Icons.store,
        title: 'Mi Salón',
        subtitle: 'Editar perfil',
        color: const Color(0xFF009688),
        onTap: () => context.push('/business/home/salon'),
      ),
      _DashboardCard(
        icon: Icons.bar_chart,
        title: 'Estadísticas',
        subtitle: 'Rendimiento',
        color: AppColors.primary,
        onTap: () => context.push('/business/home/stats'),
      ),
    ];
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
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
