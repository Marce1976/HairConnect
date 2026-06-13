import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/business/data/favorite_service.dart';
import 'package:hair_connect/features/business/data/look_repository.dart';
import 'package:hair_connect/features/business/domain/favorite.dart';
import 'package:hair_connect/features/business/domain/look.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteService = sl<FavoriteService>();
    final lookRepository = sl<LookRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Favoritos')),
      body: StreamBuilder<QuerySnapshot>(
        stream: favoriteService.getFavoritesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteDocs = snapshot.data?.docs ?? [];

          if (favoriteDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: AppColors.textGrey),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes looks favoritos aún',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final favorites = favoriteDocs
              .map((doc) =>
                  Favorite.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          final lookIds = favorites.map((f) => f.lookId).toList();

          return FutureBuilder<List<Look?>>(
            future: Future.wait(
              lookIds.map((id) async {
                final doc = await lookRepository.getLookById(id);
                if (doc == null || !doc.exists) return null;
                return Look.fromMap(doc.id, doc.data() as Map<String, dynamic>);
              }),
            ),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final looks = futureSnapshot.data ?? [];
              final validLooks =
                  looks.where((l) => l != null).cast<Look>().toList();

              if (validLooks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_border,
                          size: 64, color: AppColors.textGrey),
                      const SizedBox(height: 16),
                      const Text(
                        'No tienes looks favoritos aún',
                        style:
                            TextStyle(color: AppColors.textGrey, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: validLooks.length,
                itemBuilder: (context, index) =>
                    _buildLookCard(context, validLooks[index], favoriteService),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLookCard(
      BuildContext context, Look look, FavoriteService favoriteService) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.push('/lookbook/${look.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    look.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.favorite,
                            color: AppColors.gold),
                        onPressed: () =>
                            favoriteService.toggleFavorite(look.id, look.salonId),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    look.salonName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (look.stylistName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      look.stylistName!,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
