import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';
import 'package:hair_connect/features/business/domain/salon.dart';

class LookBookPage extends StatelessWidget {
  const LookBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = sl<BusinessRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Look & Book')),
      body: StreamBuilder<QuerySnapshot>(
        stream: repository.getSalons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Recopilar todas las imágenes de todos los salones
          final allImages = <MapEntry<Salon, String>>[];
          for (final doc in snapshot.data?.docs ?? []) {
            final data = doc.data() as Map<String, dynamic>;
            final salon = Salon.fromMap(doc.id, data);
            if (salon.galleryImages != null) {
              for (final url in salon.galleryImages!) {
                allImages.add(MapEntry(salon, url));
              }
            }
          }

          if (allImages.isEmpty) {
            return const Center(
              child: Text('No hay imágenes disponibles aún'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: allImages.length,
            itemBuilder: (context, index) {
              final entry = allImages[index];
              return GestureDetector(
                onTap: () =>
                    _showBookingDialog(context, entry.key, entry.value),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.network(
                          entry.value,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(Icons.broken_image, size: 48),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          entry.key.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
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

  void _showBookingDialog(
      BuildContext outerContext, Salon salon, String imageUrl) {
    showDialog(
      context: outerContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(salon.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(imageUrl, height: 200, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            const Text('¿Quieres reservar una cita en este salón?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              outerContext.push('/booking');
            },
            child: const Text('Reservar ahora'),
          ),
        ],
      ),
    );
  }
}
