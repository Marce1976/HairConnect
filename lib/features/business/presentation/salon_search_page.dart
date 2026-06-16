import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';
import 'package:hair_connect/features/business/domain/salon.dart';

class SalonSearchPage extends StatefulWidget {
  final String? initialCity;

  const SalonSearchPage({super.key, this.initialCity});

  @override
  State<SalonSearchPage> createState() => _SalonSearchPageState();
}

class _SalonSearchPageState extends State<SalonSearchPage> {
  final BusinessRepository _repository = sl<BusinessRepository>();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedCity;

  /// Lista de ciudades disponibles (se carga al iniciar)
  List<String> _cities = [];

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.initialCity;
    _loadCities();
  }

  Future<void> _loadCities() async {
    final cities = await _repository.getAvailableCities();
    if (mounted) setState(() => _cities = cities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Salones'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Buscador por nombre
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Buscar por nombre...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
              ],
              onChanged: (value) => setState(() => _searchQuery = value),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Filtro de ciudad
          if (_cities.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.location_city,
                      size: 18, color: AppColors.textGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _CityChip(
                            label: 'Todas',
                            selected: _selectedCity == null,
                            onTap: () => setState(() => _selectedCity = null),
                          ),
                          ..._cities.map(
                            (city) => _CityChip(
                              label: city,
                              selected: _selectedCity == city,
                              onTap: () =>
                                  setState(() => _selectedCity = city),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Resultados
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedCity != null
                  ? _repository.getSalonsByCity(_selectedCity!)
                  : _repository.getSalons(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay salones disponibles',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  );
                }

                final List<Salon> allSalons = snapshot.data!.docs.map((doc) {
                  return Salon.fromMap(
                      doc.id, doc.data() as Map<String, dynamic>);
                }).toList();

                final List<Salon> filteredSalons = _searchQuery.isEmpty
                    ? allSalons
                    : allSalons.where((salon) {
                        return salon.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase());
                      }).toList();

                if (filteredSalons.isEmpty) {
                  return Center(
                    child: Text(
                      'No se encontraron salones',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredSalons.length,
                  itemBuilder: (context, index) {
                    final salon = filteredSalons[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.textGrey.withValues(alpha: 0.15)),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () =>
                            context.push('/salons/${salon.id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary,
                                radius: 24,
                                child: const Icon(
                                  Icons.store,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      salon.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: AppColors.textGrey,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            salon.address,
                                            style: TextStyle(
                                              color: AppColors.textGrey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (salon.city != null &&
                                        salon.city!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_city,
                                            size: 14,
                                            color: AppColors.textGrey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            salon.city!,
                                            style: TextStyle(
                                              color: AppColors.textGrey,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (salon.rating != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 16,
                                            color: AppColors.gold,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            salon.rating!.toStringAsFixed(1),
                                            style: const TextStyle(
                                              color: AppColors.gold,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.textGrey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Chip de filtro de ciudad
// ────────────────────────────────────────────────────────────
class _CityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primary,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
