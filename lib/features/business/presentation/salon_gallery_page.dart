import 'package:flutter/material.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/core/services/storage_service.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalonGalleryPage extends StatefulWidget {
  final String salonId;

  const SalonGalleryPage({super.key, required this.salonId});

  @override
  State<SalonGalleryPage> createState() => _SalonGalleryPageState();
}

class _SalonGalleryPageState extends State<SalonGalleryPage> {
  final BusinessRepository _repository = sl<BusinessRepository>();
  final StorageService _storageService = sl<StorageService>();

  Future<DocumentSnapshot>? _salonFuture;

  @override
  void initState() {
    super.initState();
    _salonFuture = _repository.getSalonById(widget.salonId);
  }

  void _refreshSalon() {
    setState(() {
      _salonFuture = _repository.getSalonById(widget.salonId);
    });
  }

  Future<void> _addImage() async {
    try {
      final url = await _storageService.uploadImage(
        salonId: widget.salonId,
        fileName: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      if (url != null) {
        await _repository.addGalleryImage(widget.salonId, url);
        _refreshSalon();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al añadir imagen')),
        );
      }
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar imagen'),
        content: const Text('¿Estás seguro de eliminar esta imagen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.deleteImage(imageUrl);
        await _repository.removeGalleryImage(widget.salonId, imageUrl);
        _refreshSalon();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar imagen')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galería del Salón')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _addImage,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _salonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Salón no encontrado',
                style: TextStyle(color: AppColors.textGrey),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final galleryImages = data != null && data['galleryImages'] != null
              ? List<String>.from(data['galleryImages'] as List)
              : <String>[];

          if (galleryImages.isEmpty) {
            return const Center(
              child: Text(
                'No hay imágenes en la galería',
                style: TextStyle(color: AppColors.textGrey),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: galleryImages.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      galleryImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(Icons.broken_image, size: 32),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _deleteImage(galleryImages[index]),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
