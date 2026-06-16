import 'package:flutter/material.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';
import 'package:hair_connect/features/business/domain/product.dart';
import 'package:hair_connect/features/business/presentation/inventory_page.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage>
    with SingleTickerProviderStateMixin {
  final BusinessRepository _repository = sl<BusinessRepository>();
  final User? _user = FirebaseAuth.instance.currentUser;
  late final TabController _tabController;
  final GlobalKey<InventoryPageState> _inventoryKey = GlobalKey();
  String? _salonId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _resolveSalonId();
  }

  Future<void> _resolveSalonId() async {
    if (_user == null) return;
    final salon = await _repository.getSalonByOwnerId(_user.uid);
    if (salon != null && mounted) {
      setState(() => _salonId = salon.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Agregar Servicio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Servicio',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio (€)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duración (minutos)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty || priceController.text.trim().isEmpty || durationController.text.trim().isEmpty) return;
                      await _repository.addService(
                        nameController.text.trim(),
                        priceController.text.trim(),
                        durationController.text.trim(),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditServiceDialog(String serviceId, String currentName, String currentPrice, String currentDuration) {
    final nameController = TextEditingController(text: currentName);
    final priceController = TextEditingController(text: currentPrice);
    final durationController = TextEditingController(text: currentDuration);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Editar Servicio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Servicio',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio (€)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duración (minutos)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty || priceController.text.trim().isEmpty || durationController.text.trim().isEmpty) return;
                      await _repository.updateService(
                        serviceId: serviceId,
                        name: nameController.text.trim(),
                        price: priceController.text.trim(),
                        duration: durationController.text.trim(),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Guardar'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.content_cut), text: 'Servicios'),
          Tab(icon: Icon(Icons.inventory_2), text: 'Inventario'),
        ],
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textGrey,
        indicatorColor: AppColors.primary,
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: _showAddServiceDialog,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () =>
                  _inventoryKey.currentState?.showAddProductDialog(),
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab Servicios ──
          _buildServicesTab(),
          // Tab Inventario
          InventoryPage(key: _inventoryKey, salonId: _salonId),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _repository.getServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No hay servicios disponibles',
              style: TextStyle(color: AppColors.textGrey),
            ),
          );
        }

        final services = snapshot.data!.docs;

        // Si no tenemos salonId, mostrar solo servicios sin productos
        if (_salonId == null) {
          return _buildServicesList(services, null);
        }

        // Cargar productos para vincularlos
        return StreamBuilder<QuerySnapshot>(
          stream: _repository.getProducts(_salonId!),
          builder: (context, productsSnapshot) {
            List<Product> products = [];
            if (productsSnapshot.hasData) {
              products = productsSnapshot.data!.docs.map((doc) {
                return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
              }).toList();
            }
            return _buildServicesList(services, products);
          },
        );
      },
    );
  }

  Widget _buildServicesList(
    List<QueryDocumentSnapshot> services,
    List<Product>? products,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index].data() as Map<String, dynamic>;
        final serviceId = services[index].id;

        // Filtrar productos vinculados a este servicio
        final linkedProducts = products != null
            ? products.where((p) => p.serviceIds.contains(serviceId)).toList()
            : <Product>[];

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.content_cut, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    service['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${service['duration'] ?? ''} min - €${service['price'] ?? ''}',
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary),
                        onPressed: () => _showEditServiceDialog(
                          services[index].id,
                          service['name'] as String? ?? '',
                          service['price'] as String? ?? '',
                          service['duration'] as String? ?? '',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _repository.deleteService(services[index].id);
                        },
                      ),
                    ],
                  ),
                ),
                // Productos vinculados
                if (linkedProducts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Icon(Icons.inventory_2,
                            size: 14, color: AppColors.textGrey),
                        const SizedBox(width: 4),
                        ...linkedProducts.map((p) => Chip(
                          label: Text(
                            p.name,
                            style: const TextStyle(fontSize: 11),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.08),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        )),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
