import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

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
  final BusinessRepository _businessRepository = sl<BusinessRepository>();

  Look? _look;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLook();
  }

  Future<void> _loadLook() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final snapshot = await _lookRepository.getLookById(widget.lookId);
      if (!mounted) return;
      if (snapshot == null || !snapshot.exists) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Look no encontrado';
        });
        return;
      }
      setState(() {
        _look = Look.fromMap(
          snapshot.id,
          snapshot.data() as Map<String, dynamic>,
        );
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar el look';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Look'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorView(
        message: _errorMessage!,
        onRetry: _loadLook,
      );
    }

    if (_look == null) {
      return _buildErrorView(
        message: 'Look no encontrado',
        onRetry: _loadLook,
      );
    }

    return _buildContent(_look!);
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
          GestureDetector(
            onTap: () => _showMediaViewer(look),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.network(
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
            ),
          ),
          if (look.hasMediaExtra)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      look.videoUrl != null
                          ? Icons.play_circle_outline
                          : Icons.compare,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      look.videoUrl != null
                          ? 'Toca para ver más'
                          : 'Toca para ampliar',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: _FavoriteButton(lookId: look.id, salonId: look.salonId),
          ),
        ],
      ),
    );
  }

  void _showMediaViewer(Look look) {
    // Si hay video, mostrar reproductor de video
    if (look.videoUrl != null) {
      _showVideoPlayer(look.videoUrl!);
      return;
    }
    // Si hay afterImageUrl, mostrar antes/después
    if (look.afterImageUrl != null) {
      _showBeforeAfter(look.imageUrl, look.afterImageUrl!);
      return;
    }
    // Por defecto, mostrar zoom de imagen
    _showImageZoom(look.imageUrl);
  }

  void _showImageZoom(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (ctx) {
        final size = MediaQuery.of(ctx).size;
        return Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: size.width - 32,
              height: size.height - 32,
              child: Stack(
                children: [
                  // Capa base: imagen con zoom
                  Positioned.fill(
                    child: InteractiveViewer(
                      clipBehavior: Clip.none,
                      minScale: 1.0,
                      maxScale: 5.0,
                      child: Center(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Máscara que pinta las 4 esquinas de negro
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _CornerOverlayPainter(radius: 40),
                      ),
                    ),
                  ),
                  // Botón cerrar
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(ctx).pop(),
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

  void _showBeforeAfter(String beforeImageUrl, String afterImageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (ctx) => _BeforeAfterDialog(
        beforeImageUrl: beforeImageUrl,
        afterImageUrl: afterImageUrl,
      ),
    );
  }

  void _showVideoPlayer(String videoUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (ctx) => _VideoPlayerDialog(videoUrl: videoUrl),
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

/// Diálogo para comparar antes/después con toggle chips.
class _BeforeAfterDialog extends StatefulWidget {
  final String beforeImageUrl;
  final String afterImageUrl;

  const _BeforeAfterDialog({
    required this.beforeImageUrl,
    required this.afterImageUrl,
  });

  @override
  State<_BeforeAfterDialog> createState() => _BeforeAfterDialogState();
}

class _BeforeAfterDialogState extends State<_BeforeAfterDialog> {
  bool _showAfter = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              child: Image.network(
                _showAfter ? widget.afterImageUrl : widget.beforeImageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildChip('Antes', !_showAfter),
                    const SizedBox(width: 4),
                    _buildChip('Después', _showAfter),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _showAfter = label == 'Después'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// Widget stateful para reproducir video dentro del diálogo.
class _VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerDialog({required this.videoUrl});

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  late VideoPlayerController _controller;
  late Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    _initializeFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: FutureBuilder(
        future: _initializeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (snapshot.hasError) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: Colors.white54),
                const SizedBox(height: 8),
                const Text('Error al cargar el vídeo',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${snapshot.error}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          }
          return Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Widget independiente para el botón de favorito.
/// Al tener su propio estado, al marcarlo solo se reconstruye este icono,
/// no toda la página.
class _FavoriteButton extends StatefulWidget {
  final String lookId;
  final String salonId;

  const _FavoriteButton({
    required this.lookId,
    required this.salonId,
  });

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  final FavoriteService _favoriteService = sl<FavoriteService>();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final isFav = await _favoriteService.isFavorite(widget.lookId);
      if (!mounted) return;
      setState(() => _isFavorite = isFav);
    } catch (e) {
      debugPrint('Error al cargar favorito: $e');
    }
  }

  Future<void> _toggle() async {
    try {
      final newState =
          await _favoriteService.toggleFavorite(widget.lookId, widget.salonId);
      if (!mounted) return;
      setState(() => _isFavorite = newState);
    } catch (e) {
      debugPrint('Error al toggle favorito: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar favorito'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(24),
      ),
      child: IconButton(
        icon: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? AppColors.gold : Colors.white,
        ),
        onPressed: _toggle,
      ),
    );
  }
}

class _CornerOverlayPainter extends CustomPainter {
  final double radius;

  _CornerOverlayPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;

    final fullRect = Path()..addRect(Offset.zero & size);
    final innerRRect = Path()..addRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(radius),
      ),
    );

    // fullRect - innerRRect = las 4 esquinas fuera del área redondeada
    final corners = Path.combine(
      PathOperation.difference,
      fullRect,
      innerRRect,
    );

    canvas.drawPath(corners, paint);
  }

  @override
  bool shouldRepaint(_CornerOverlayPainter old) => old.radius != radius;
}
