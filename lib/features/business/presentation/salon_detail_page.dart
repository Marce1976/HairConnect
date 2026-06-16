import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';
import 'package:hair_connect/features/business/domain/salon.dart';

class SalonDetailPage extends StatelessWidget {
  final String salonId;

  const SalonDetailPage({super.key, required this.salonId});

  @override
  Widget build(BuildContext context) {
    final BusinessRepository repository = sl<BusinessRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Salón'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: repository.getSalonById(salonId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Salón no encontrado',
                style: TextStyle(color: AppColors.textGrey),
              ),
            );
          }

          final salon = Salon.fromMap(
            snapshot.data!.id,
            snapshot.data!.data() as Map<String, dynamic>,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSalonHeader(salon),
                const SizedBox(height: 24),
                if (salon.description != null && salon.description!.isNotEmpty)
                  _buildSection(
                    title: 'Descripción',
                    child: Text(
                      salon.description!,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textDark,
                        height: 1.5,
                      ),
                    ),
                  ),
                if (salon.description != null && salon.description!.isNotEmpty)
                  const SizedBox(height: 24),
                _buildSection(
                  title: 'Información de Contacto',
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'Dirección',
                        salon.address,
                      ),
                      if (salon.phone != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.phone_outlined,
                          'Teléfono',
                          salon.phone!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildGalleryLink(context, salon),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Servicios',
                  child: _buildServicesList(context),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Estilistas',
                  child: _buildStylistsList(context),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/booking'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text(
                      'Reservar Cita',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSalonHeader(Salon salon) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: AppColors.textGrey.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 40,
              child: const Icon(
                Icons.store,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              salon.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (salon.rating != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: AppColors.gold, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    salon.rating!.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryLink(BuildContext context, Salon salon) {
    return InkWell(
      onTap: () => context.push('/salons/${salon.id}/gallery'),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.textGrey.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.photo_library,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Galería',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${salon.galleryImages?.length ?? 0} imágenes',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textGrey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList(BuildContext context) {
    final BusinessRepository repository = sl<BusinessRepository>();

    return StreamBuilder<QuerySnapshot>(
      stream: repository.getServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              side: BorderSide(color: AppColors.textGrey.withValues(alpha: 0.15)),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No hay servicios disponibles',
                style: TextStyle(color: AppColors.textGrey),
              ),
            ),
          );
        }

        final services = snapshot.data!.docs;
        return Column(
          children: services.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(color: AppColors.textGrey.withValues(alpha: 0.15)),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.content_cut,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  data['name'] as String? ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${data['duration'] as String? ?? ''} min - €${data['price'] as String? ?? ''}',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStylistsList(BuildContext context) {
    final BusinessRepository repository = sl<BusinessRepository>();

    return StreamBuilder<QuerySnapshot>(
      stream: repository.getStylists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              side: BorderSide(color: AppColors.textGrey.withValues(alpha: 0.15)),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No hay estilistas disponibles',
                style: TextStyle(color: AppColors.textGrey),
              ),
            ),
          );
        }

        final stylists = snapshot.data!.docs;
        return Column(
          children: stylists.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(color: AppColors.textGrey.withValues(alpha: 0.15)),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  data['name'] as String? ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
