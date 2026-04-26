import 'package:flutter/material.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24.0),
            StreamBuilder<QuerySnapshot>(
              stream: db.collection('bookings').snapshots(),
              builder: (context, snapshot) {
                final totalBookings = snapshot.hasData
                    ? snapshot.data!.docs.length
                    : 0;
                return _StatCard(
                  icon: Icons.calendar_today,
                  title: 'Total de Reservas',
                  value: totalBookings.toString(),
                  color: AppColors.primary,
                );
              },
            ),
            const SizedBox(height: 16.0),
            StreamBuilder<QuerySnapshot>(
              stream: db.collection('stylists').snapshots(),
              builder: (context, snapshot) {
                final totalStylists = snapshot.hasData
                    ? snapshot.data!.docs.length
                    : 0;
                return _StatCard(
                  icon: Icons.people,
                  title: 'Total de Estilistas',
                  value: totalStylists.toString(),
                  color: AppColors.primary,
                );
              },
            ),
            const SizedBox(height: 16.0),
            StreamBuilder<QuerySnapshot>(
              stream: db.collection('services').snapshots(),
              builder: (context, snapshot) {
                final totalServices = snapshot.hasData
                    ? snapshot.data!.docs.length
                    : 0;
                return _StatCard(
                  icon: Icons.content_cut,
                  title: 'Total de Servicios',
                  value: totalServices.toString(),
                  color: AppColors.primary,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textGrey,
          ),
        ),
      ),
    );
  }
}
