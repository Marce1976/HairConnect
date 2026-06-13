import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';
import 'package:hair_connect/features/business/data/favorite_service.dart';
import 'package:hair_connect/features/business/data/look_repository.dart';
import 'package:hair_connect/features/business/domain/look.dart';
import 'package:hair_connect/features/business/domain/salon.dart';

class LookDetailPage extends StatefulWidget {
  final String lookId;

  const LookDetailPage({super.key, required this.lookId});

  @override
  State<LookDetailPage> createState() => _LookDetailPageState();
}

class _LookDetailPageState extends State<LookDetailPage> {
  final LookRepository _lookRepository = sl<LookRepository>();
  final FavoriteService _favoriteService = sl<FavoriteService>();
  final BusinessRepository _businessRepository = sl<BusinessRepository>();

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final isFav = await _favoriteService.isFavorite(widget.lookId);
    if (!mounted) return;
    setState(() => _isFavorite = isFav);
  }

  Future<void> _toggleFavorite(Look look) async {
    final newState =
        await _favoriteService.toggleFavorite(look.id, look.salonId);
    if (!mounted) return;
    setState(() => _isFavorite = newState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Look'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot?>(
        future: _lookRepository.getLookById(widget.lookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildErrorView(
              message: 'Look no encontrado',
              onRetry: () => setState(() {}),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorView(
              message: 'Error al cargar el look',
              onRetry: () => setState(() {}),
            );
          }

          final look = Look.fromMap(
            snapshot.data!.id,
            snapshot.data!.data() as Map<String, dynamic>,
          );

          return _buildContent(look);
        },
      ),
    );
  }

  Widget _buildErrorView({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.textGrey),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Look look) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(look),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSalonInfo(look),
                      const SizedBox(height: 16),
                      if (look.description != null &&
                          look.description!.isNotEmpty)
                        _buildDescription(look.description!),
                      if (look.description != null &&
                          look.description!.isNotEmpty)
                        const SizedBox(height: 16),
                      if (look.services != null && look.services!.isNotEmpty)
                        _buildServices(look.services!),
                      if (look.services != null && look.services!.isNotEmpty)
                        const SizedBox(height: 16),
                      if (look.price != null && look.price!.isNotEmpty)
                        _buildPrice(look),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildBottomButton(look),
      ],
    );
  }

  Widget _buildImageSection(Look look) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            look.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, _, _) => Container(
              color: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(
                Icons.broken_image,
                size: 64,
                color: AppColors.textGrey,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? AppColors.gold : Colors.white,
                ),
                onPressed: () => _toggleFavorite(look),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalonInfo(Look look) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => context.push('/salons/${look.salonId}'),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  look.salonName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.primary),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (look.stylistName != null)
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: AppColors.textGrey),
              const SizedBox(width: 6),
              Text(
                look.stylistName!,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        if (look.services != null && look.services!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.content_cut, size: 18, color: AppColors.textGrey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  look.services!.join(', '),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        _buildSalonRating(look),
        const SizedBox(height: 8),
        _buildSalonAddress(look),
      ],
    );
  }

  Widget _buildSalonRating(Look look) {
    return FutureBuilder<DocumentSnapshot>(
      future: _businessRepository.getSalonById(look.salonId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }
        final salon = Salon.fromMap(
          snapshot.data!.id,
          snapshot.data!.data() as Map<String, dynamic>,
        );
        if (salon.rating == null) return const SizedBox.shrink();
        return Row(
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
        );
      },
    );
  }

  Widget _buildSalonAddress(Look look) {
    return FutureBuilder<DocumentSnapshot>(
      future: _businessRepository.getSalonById(look.salonId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }
        final salon = Salon.fromMap(
          snapshot.data!.id,
          snapshot.data!.data() as Map<String, dynamic>,
        );
        return Row(
          children: [
            const Icon(Icons.location_on_outlined,
                size: 18, color: AppColors.textGrey),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                salon.address,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDescription(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textDark,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildServices(List<String> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servicios',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: services
              .map((service) => Chip(
                    label: Text(service),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    side: BorderSide.none,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPrice(Look look) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: look.onSale
            ? Colors.red.withValues(alpha: 0.05)
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: look.onSale
              ? Colors.red.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.euro,
            color: look.onSale ? Colors.red : AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: 8),
          if (look.onSale) ...[
            Text(
              '€${look.price!}',
              style: const TextStyle(
                fontSize: 18,
                decoration: TextDecoration.lineThrough,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '€${look.salePrice!}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'OFERTA',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ] else
            Text(
              '€${look.price!}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(Look look) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () =>
                context.push('/booking?lookId=${look.id}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Reservar este look',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
