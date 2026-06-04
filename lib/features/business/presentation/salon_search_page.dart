import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';
import 'package:hair_connect/features/business/domain/salon.dart';

class SalonSearchPage extends StatefulWidget {
  const SalonSearchPage({super.key});

  @override
  State<SalonSearchPage> createState() => _SalonSearchPageState();
}

class _SalonSearchPageState extends State<SalonSearchPage> {
  final BusinessRepository _repository = sl<BusinessRepository>();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
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
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _repository.getSalons(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay salones disponibles',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  );
                }

                final List<Salon> allSalons = snapshot.data!.docs.map((doc) {
                  return Salon.fromMap(doc.id, doc.data() as Map<String, dynamic>);
                }).toList();

                final List<Salon> filteredSalons = _searchQuery.isEmpty
                    ? allSalons
                    : allSalons.where((salon) {
                        return salon.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase());
                      }).toList();

                if (filteredSalons.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron salones',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredSalons.length,
                  itemBuilder: (context, index) {
                    final salon = filteredSalons[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.0),
                        onTap: () => context.push('/salons/${salon.id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: AppColors.textGrey,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            salon.address,
                                            style: const TextStyle(
                                              color: AppColors.textGrey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
                              const Icon(
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
