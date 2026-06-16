import 'package:flutter/material.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
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

  /// Muestra un diálogo para agregar imagen por URL
  void _showAddUrlDialog() {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Agregar imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pega la URL de una imagen:',
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: 'https://ejemplo.com/foto.jpg',
                border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            // Preview en vivo
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: urlController,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: Image.network(
                      value.text,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: Colors.red.withValues(alpha: 0.05),
                        child: const Center(
                          child: Text('URL no válida',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final url = urlController.text.trim();
                    if (url.isEmpty) return;
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await _repository.addGalleryImage(widget.salonId, url);
                      if (ctx.mounted) Navigator.pop(ctx);
                      _refreshSalon();
                    } catch (e) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Error al agregar imagen')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Agregar'),
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
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteImage(String imageUrl) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar imagen'),
        content: const Text('¿Estás seguro de eliminar esta imagen?'),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
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
                  child: const Text('Eliminar'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
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
      appBar: AppBar(
        title: const Text('Galería del Salón'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            tooltip: 'Agregar imagen por URL',
            onPressed: _showAddUrlDialog,
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _salonFuture,
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

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final galleryImages = data != null && data['galleryImages'] != null
              ? List<String>.from(data['galleryImages'] as List)
              : <String>[];

          if (galleryImages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined,
                      size: 64, color: AppColors.textGrey),
                  const SizedBox(height: 16),
                  Text(
                    'No hay imágenes en la galería',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddUrlDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar primera imagen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
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
                    // Imagen — tocar para ver en grande
                    GestureDetector(
                      onTap: () => _showFullImage(context, galleryImages[index]),
                      child: Image.network(
                        galleryImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.broken_image, size: 32),
                        ),
                      ),
                    ),
                    // Botón eliminar
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

  /// Muestra la imagen a pantalla completa
  void _showFullImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, _, _) => Scaffold(
          backgroundColor: Colors.black.withValues(alpha: 0.95),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text('Galería'),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
