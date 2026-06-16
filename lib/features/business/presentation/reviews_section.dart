import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hair_connect/core/theme/app_colors.dart';

/// Sección de valoraciones y reseñas para un look.
class ReviewsSection extends StatelessWidget {
  final String lookId;

  const ReviewsSection({super.key, required this.lookId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('lookId', isEqualTo: lookId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return _ReviewsBody(lookId: lookId, reviews: docs);
      },
    );
  }
}

class _ReviewsBody extends StatelessWidget {
  final String lookId;
  final List<QueryDocumentSnapshot> reviews;

  const _ReviewsBody({required this.lookId, required this.reviews});

  double _averageRating() {
    if (reviews.isEmpty) return 0;
    double sum = 0;
    for (final doc in reviews) {
      final data = doc.data() as Map<String, dynamic>;
      sum += (data['rating'] as num?)?.toDouble() ?? 0;
    }
    return sum / reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final avg = _averageRating();
    final totalReviews = reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),

        // ── Título ──
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              'Reseñas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showWriteReviewSheet(context),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Escribir'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),

        // ── Promedio ──
        if (totalReviews > 0) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              _StarRatingDisplay(rating: avg, size: 20),
              const SizedBox(width: 8),
              Text(
                avg.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '($totalReviews ${totalReviews == 1 ? 'reseña' : 'reseñas'})',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textGrey.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // ── Lista de reseñas ──
        if (reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.rate_review,
                      size: 40, color: AppColors.textGrey.withValues(alpha: 0.4)),
                  const SizedBox(height: 8),
                  Text(
                    'Sin reseñas aún',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sé el primero en opinar',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...reviews.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _ReviewCard(review: data);
          }),
      ],
    );
  }

  void _showWriteReviewSheet(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para reseñar')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WriteReviewSheet(
        lookId: lookId,
        userId: userId,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Estrellas interactivas (para escribir reseña)
// ──────────────────────────────────────────────────────────────
class _StarRatingInput extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;

  const _StarRatingInput({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final star = index + 1;
        return IconButton(
          icon: Icon(
            star <= rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 36,
          ),
          onPressed: () => onChanged(star),
          splashRadius: 20,
        );
      }),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Estrellas de visualización (solo lectura)
// ──────────────────────────────────────────────────────────────
class _StarRatingDisplay extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRatingDisplay({required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        double fill;
        if (rating >= starValue) {
          fill = 1.0;
        } else if (rating > starValue - 1) {
          fill = rating - (starValue - 1);
        } else {
          fill = 0.0;
        }
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Icon(Icons.star_border, color: Colors.amber, size: size),
              if (fill > 0)
                ClipRect(
                  clipper: _StarClipper(fill),
                  child: Icon(Icons.star, color: Colors.amber, size: size),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _StarClipper extends CustomClipper<Rect> {
  final double fill;
  _StarClipper(this.fill);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * fill, size.height);

  @override
  bool shouldReclip(_StarClipper old) => old.fill != fill;
}

// ──────────────────────────────────────────────────────────────
// Tarjeta de reseña individual
// ──────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;

  const _ReviewCard({required this.review});

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    if (diff.inDays < 30) return 'Hace ${(diff.inDays / 7).floor()} semanas';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final rating = (review['rating'] as num?)?.toInt() ?? 0;
    final comment = review['comment'] as String? ?? '';
    final userName = review['userName'] as String? ?? 'Anónimo';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Fila: nombre + fecha ──
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      userName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(review['createdAt'] as Timestamp?),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ── Estrellas ──
              _StarRatingDisplay(rating: rating.toDouble(), size: 16),

              // ── Comentario ──
              if (comment.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  comment,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Bottom sheet para escribir una reseña
// ──────────────────────────────────────────────────────────────
class _WriteReviewSheet extends StatefulWidget {
  final String lookId;
  final String userId;

  const _WriteReviewSheet({required this.lookId, required this.userId});

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una puntuación')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      final userName = (userDoc.data()?['name'] as String?) ?? 'Cliente';

      await FirebaseFirestore.instance.collection('reviews').add({
        'lookId': widget.lookId,
        'userId': widget.userId,
        'userName': userName,
        'rating': _rating,
        'comment': _commentCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Reseña publicada!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al publicar reseña: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Título ──
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Valorar este look',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),

          // ── Estrellas ──
          Center(
            child: _StarRatingInput(
              rating: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
          ),
          const SizedBox(height: 16),

          // ── Comentario ──
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Cuenta tu experiencia...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.textGrey.withValues(alpha: 0.05),
            ),
          ),
          const SizedBox(height: 16),

          // ── Botón ──
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Publicar reseña',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
