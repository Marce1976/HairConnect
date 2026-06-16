import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/business/data/look_repository.dart';
import 'package:hair_connect/features/business/domain/look.dart';

class BusinessLooksPage extends StatefulWidget {
  const BusinessLooksPage({super.key});

  @override
  State<BusinessLooksPage> createState() => _BusinessLooksPageState();
}

class _BusinessLooksPageState extends State<BusinessLooksPage> {
  final LookRepository _lookRepository = sl<LookRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _lookRepository.getLooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.textGrey),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}',
                      style: TextStyle(color: AppColors.textGrey)),
                ],
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final looks = docs
              .map((doc) => Look.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          if (looks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, size: 64, color: AppColors.textGrey),
                  const SizedBox(height: 16),
                  Text('No hay looks todavía',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 16)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/upload-look'),
                    icon: const Icon(Icons.add),
                    label: const Text('Subir primer look'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: looks.length,
              itemBuilder: (context, index) => _buildLookCard(looks[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/upload-look'),
        tooltip: 'Subir nuevo look',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLookCard(Look look) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/lookbook/${look.id}'),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  Image.network(
                    look.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.broken_image, color: AppColors.textGrey),
                    ),
                  ),
                  if (look.onSale)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OFERTA',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      look.salonName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (look.stylistName != null)
                      Text(
                        look.stylistName!,
                        style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                      ),
                    const SizedBox(height: 4),
                    if (look.price != null && look.price!.isNotEmpty)
                      look.onSale
                          ? Row(
                              children: [
                                Text(
                                  '€${look.price!}',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.textGrey,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '€${look.salePrice!}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              '€${look.price!}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 15,
                              ),
                            ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: AppColors.textGrey, size: 20),
                  onPressed: () => _showEditLookDialog(look),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  onPressed: () => _confirmDeleteLook(context, look),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLookDialog(Look look) {
    final imageUrlController = TextEditingController(text: look.imageUrl);
    final descriptionController = TextEditingController(text: look.description ?? '');
    final servicesController = TextEditingController(
      text: look.services?.join(', ') ?? '',
    );
    final priceController = TextEditingController(text: look.price ?? '');
    final saleController = TextEditingController(text: look.salePrice ?? '');
    final videoUrlController = TextEditingController(text: look.videoUrl ?? '');
    final afterImageUrlController = TextEditingController(
      text: look.afterImageUrl ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Editar Look'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Previsualización de la imagen actual
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: Image.network(
                    imageUrlController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.broken_image, color: AppColors.textGrey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la imagen',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: servicesController,
                decoration: const InputDecoration(
                  labelText: 'Servicios',
                  hintText: 'Ej: Corte, Color, Peinado',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio normal (€)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: saleController,
                decoration: const InputDecoration(
                  labelText: 'Precio oferta (€) — dejar vacío si no hay',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL del vídeo (opcional)',
                  hintText: 'https://ejemplo.com/video.mp4',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.videocam),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: afterImageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL del "después" (opcional)',
                  hintText: 'https://ejemplo.com/despues.jpg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.compare),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final servicesText = servicesController.text.trim();
                  final services = servicesText.isNotEmpty
                      ? servicesText
                          .split(',')
                          .map((s) => s.trim())
                          .where((s) => s.isNotEmpty)
                          .toList()
                      : [];

                  final description = descriptionController.text.trim();
                  final videoUrl = videoUrlController.text.trim();
                  final afterImageUrl = afterImageUrlController.text.trim();

                  await _lookRepository.updateLook(look.id, {
                    'imageUrl': imageUrlController.text.trim().isNotEmpty
                        ? imageUrlController.text.trim()
                        : look.imageUrl,
                    'description': description.isNotEmpty ? description : null,
                    'services': services.isNotEmpty ? services : [],
                    'price': priceController.text.trim().isNotEmpty
                        ? priceController.text.trim()
                        : null,
                    'salePrice': saleController.text.trim().isNotEmpty
                        ? saleController.text.trim()
                        : null,
                    'videoUrl': videoUrl.isNotEmpty ? videoUrl : null,
                    'afterImageUrl': afterImageUrl.isNotEmpty ? afterImageUrl : null,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
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
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Guardar'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _confirmDeleteLook(BuildContext context, Look look) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar look'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('¿Estás seguro de eliminar "${look.salonName}"?'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
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
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Eliminar'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await _lookRepository.deleteLook(look.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Look eliminado')),
        );
      }
    }
  }
}
