import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';
import 'package:hair_connect/features/business/data/favorite_service.dart';
import 'package:hair_connect/features/business/data/look_repository.dart';
import 'package:hair_connect/features/business/domain/look.dart';

class LookBookPage extends StatefulWidget {
  const LookBookPage({super.key});

  @override
  State<LookBookPage> createState() => _LookBookPageState();
}

class _LookBookPageState extends State<LookBookPage> {
  final LookRepository _lookRepository = sl<LookRepository>();
  final BusinessRepository _businessRepository = sl<BusinessRepository>();
  late final Stream<QuerySnapshot> _looksStream;
  late final Stream<QuerySnapshot> _salonsStream;

  String? _selectedSalonId;
  String? _selectedStylistName;
  String? _selectedCity;

  /// Mapa: ciudad -> lista de salonIds
  Map<String, List<String>> _salonsByCity = {};
  List<String> _cities = [];

  @override
  void initState() {
    super.initState();
    _looksStream = _lookRepository.getLooks();
    _salonsStream = _businessRepository.getSalons();
    _loadCities();
  }

  Future<void> _loadCities() async {
    final snapshot = await _businessRepository.getSalons().first;
    final map = <String, List<String>>{};
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final city = data['city'] as String?;
      if (city != null && city.isNotEmpty) {
        map.putIfAbsent(city, () => []);
        map[city]!.add(doc.id);
      }
    }
    if (mounted) {
      setState(() {
        _salonsByCity = map;
        _cities = map.keys.toList()..sort();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Look & Book'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/seed'),
        tooltip: 'Poblar datos de ejemplo',
        child: const Icon(Icons.storage, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _looksStream,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final looks = snapshot.data?.docs ?? [];

          final stylistNames = looks
              .map((doc) => doc['stylistName'] as String?)
              .where((name) => name != null && name.isNotEmpty)
              .map((name) => name!)
              .toSet()
              .toList()
            ..sort();

          final allLooks = looks
              .map((doc) =>
                  Look.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          // Obtener los salonIds de la ciudad seleccionada
          final salonIdsInCity = _selectedCity != null
              ? (_salonsByCity[_selectedCity] ?? [])
              : null;

          final filteredLooks = allLooks.where((look) {
            if (salonIdsInCity != null &&
                !salonIdsInCity.contains(look.salonId)) {
              return false;
            }
            if (_selectedSalonId != null &&
                look.salonId != _selectedSalonId) {
              return false;
            }
            if (_selectedStylistName != null &&
                look.stylistName != _selectedStylistName) {
              return false;
            }
            return true;
          }).toList();

          return Column(
            children: [
              _buildFilters(stylistNames),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredLooks.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay looks disponibles',
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                          )
                        : _buildGrid(filteredLooks),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(List<String> stylistNames) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filtro de ciudad
          if (_cities.isNotEmpty)
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CityChipLook(
                    label: 'Todas',
                    selected: _selectedCity == null,
                    onTap: () => setState(() {
                      _selectedCity = null;
                      _selectedSalonId = null;
                    }),
                  ),
                  ..._cities.map(
                    (city) => _CityChipLook(
                      label: city,
                      selected: _selectedCity == city,
                      onTap: () => setState(() {
                        _selectedCity = city;
                        _selectedSalonId = null;
                      }),
                    ),
                  ),
                ],
              ),
            ),
          if (_cities.isNotEmpty) const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _salonsStream,
                  builder: (context, snapshot) {
                    final salons = snapshot.data?.docs ?? [];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: _selectedSalonId,
                          isExpanded: true,
                          isDense: true,
                          hint: const Text('Salón',
                              style: TextStyle(fontSize: 14)),
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text('Todos',
                                  style:
                                      TextStyle(color: AppColors.textGrey)),
                            ),
                            ...salons.map((doc) {
                              final data =
                                  doc.data() as Map<String, dynamic>;
                              return DropdownMenuItem(
                                value: doc.id,
                                child: Text(
                                  data['name'] as String? ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedSalonId = value),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedStylistName,
                      isExpanded: true,
                      isDense: true,
                      hint: const Text('Estilista',
                              style: TextStyle(fontSize: 14)),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Todos',
                              style: TextStyle(color: AppColors.textGrey)),
                        ),
                        ...stylistNames.map((name) => DropdownMenuItem(
                              value: name,
                              child: Text(
                                name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedStylistName = value),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Look> looks) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: looks.length,
      itemBuilder: (context, index) => _buildLookCard(looks[index]),
    );
  }

  Widget _buildLookCard(Look look) {
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
                  if (look.onSale)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OFERTA',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _LookCardFavoriteButton(
                      lookId: look.id,
                      salonId: look.salonId,
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
                  if (look.services != null && look.services!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      look.services!.join(', '),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (look.price != null && look.price!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    look.onSale
                        ? Row(
                            children: [
                              Text(
                                '€${look.price}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.textGrey,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '€${look.salePrice}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'OFERTA',
                                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '€${look.price}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 13,
                            ),
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

// ────────────────────────────────────────────────────────────
// Chip de filtro de ciudad en LookBook
// ────────────────────────────────────────────────────────────
class _CityChipLook extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CityChipLook({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 13)),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        side: BorderSide(
          color: selected ? AppColors.primary : Colors.grey.shade300,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

/// Widget independiente para el botón de favorito en tarjetas de look.
/// Al tener su propio estado, al marcarlo solo se reconstruye este icono,
/// no toda la página.
class _LookCardFavoriteButton extends StatefulWidget {
  final String lookId;
  final String salonId;

  const _LookCardFavoriteButton({
    required this.lookId,
    required this.salonId,
  });

  @override
  State<_LookCardFavoriteButton> createState() =>
      _LookCardFavoriteButtonState();
}

class _LookCardFavoriteButtonState extends State<_LookCardFavoriteButton> {
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
      final newState = await _favoriteService.toggleFavorite(
        widget.lookId,
        widget.salonId,
      );
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
        borderRadius: BorderRadius.circular(20),
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
