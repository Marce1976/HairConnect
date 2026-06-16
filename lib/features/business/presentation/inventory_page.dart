import 'package:flutter/material.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';
import 'package:hair_connect/features/business/domain/product.dart';

class InventoryPage extends StatefulWidget {
  final String? salonId;

  const InventoryPage({super.key, this.salonId});

  @override
  InventoryPageState createState() => InventoryPageState();
}

class InventoryPageState extends State<InventoryPage> {
  final BusinessRepository _repository = sl<BusinessRepository>();
  final User? _user = FirebaseAuth.instance.currentUser;
  final TextEditingController _searchController = TextEditingController();
  String? _salonId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _resolveSalonId();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _resolveSalonId() async {
    if (widget.salonId != null) {
      _salonId = widget.salonId;
      return;
    }
    if (_user == null) return;
    final salon = await _repository.getSalonByOwnerId(_user.uid);
    if (salon != null) {
      setState(() => _salonId = salon.id);
    }
  }

  /// Expuesto para que ServicesPage pueda abrir el diálogo desde su FAB.
  Future<void> showAddProductDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final qtyController = TextEditingController(text: '0');
    final minStockController = TextEditingController(text: '5');
    final unitController = TextEditingController(text: 'unidad');
    final priceController = TextEditingController(text: '0');

    List<Map<String, dynamic>> allServices;
    try {
      allServices = await _repository.getServicesList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar servicios: $e')),
        );
      }
      allServices = [];
    }
    final selectedServices = <String>{};

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Producto',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qtyController,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: minStockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock mínimo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unidad',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Precio (€)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                if (allServices.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Servicios relacionados',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ...allServices.map((service) {
                    final serviceId = service['id'] as String;
                    final serviceName = service['name'] as String? ?? '';
                    final servicePrice = service['price'] as String? ?? '';
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(serviceName, style: const TextStyle(fontSize: 14)),
                      subtitle: servicePrice.isNotEmpty
                          ? Text('€$servicePrice',
                              style: TextStyle(fontSize: 12, color: AppColors.textGrey))
                          : null,
                      value: selectedServices.contains(serviceId),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            selectedServices.add(serviceId);
                          } else {
                            selectedServices.remove(serviceId);
                          }
                        });
                      },
                    );
                  }),
                ],
              ],
            ),
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
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('El nombre es obligatorio')),
                        );
                        return;
                      }
                      if (_salonId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'No tienes un salón asignado. Contacta al administrador.')),
                        );
                        return;
                      }
                      try {
                        final productId = await _repository.addProduct(
                          name: nameController.text.trim(),
                          description: descController.text.trim(),
                          quantity: int.tryParse(qtyController.text.trim()) ?? 0,
                          minStock: int.tryParse(minStockController.text.trim()) ?? 5,
                          unit: unitController.text.trim().isEmpty
                              ? 'unidad'
                              : unitController.text.trim(),
                          price: double.tryParse(priceController.text.trim()) ?? 0,
                          salonId: _salonId!,
                          serviceIds: selectedServices.toList(),
                        );
                        final qty = int.tryParse(qtyController.text.trim()) ?? 0;
                        await _repository.recordStockChange(
                          productId: productId,
                          productName: nameController.text.trim(),
                          previousQuantity: 0,
                          newQuantity: qty,
                          note: 'Stock inicial',
                        );
                        final minStk =
                            int.tryParse(minStockController.text.trim()) ?? 5;
                        if (qty <= minStk) {
                          await _repository.notifyLowStock(
                              _salonId!, nameController.text.trim());
                        }
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al guardar: $e')),
                          );
                        }
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
                    onPressed: () => Navigator.pop(context),
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
      ),
    );
  }

  Future<void> _showEditProductDialog(Product product) async {
    final nameController = TextEditingController(text: product.name);
    final descController = TextEditingController(text: product.description);
    final qtyController =
        TextEditingController(text: product.quantity.toString());
    final minStockController =
        TextEditingController(text: product.minStock.toString());
    final unitController = TextEditingController(text: product.unit);
    final priceController =
        TextEditingController(text: product.price.toStringAsFixed(2));

    final allServices = await _repository.getServicesList();
    final selectedServices = Set<String>.from(product.serviceIds);
    bool didSave = false;

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qtyController,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: minStockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock mín',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unidad',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Precio (€)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                if (allServices.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Servicios relacionados',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ...allServices.map((service) {
                    final serviceId = service['id'] as String;
                    final serviceName = service['name'] as String? ?? '';
                    final servicePrice = service['price'] as String? ?? '';
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(serviceName,
                          style: const TextStyle(fontSize: 14)),
                      subtitle: servicePrice.isNotEmpty
                          ? Text('€$servicePrice',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textGrey))
                          : null,
                      value: selectedServices.contains(serviceId),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            selectedServices.add(serviceId);
                          } else {
                            selectedServices.remove(serviceId);
                          }
                        });
                      },
                    );
                  }),
                ],
              ],
            ),
          ),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      didSave = true;
                      Navigator.pop(context);
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
                    child: const Text('Guardar'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
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
      ),
    );

    if (didSave && mounted) {
      try {
        await _repository.updateProduct(
          productId: product.id,
          name: nameController.text.trim(),
          description: descController.text.trim(),
          quantity: int.tryParse(qtyController.text.trim()) ?? product.quantity,
          minStock:
              int.tryParse(minStockController.text.trim()) ?? product.minStock,
          unit: unitController.text.trim(),
          price: double.tryParse(priceController.text.trim()) ?? product.price,
          serviceIds: selectedServices.toList(),
        );
        final newQty = int.tryParse(qtyController.text.trim()) ?? product.quantity;
        // Registrar cambio en historial si la cantidad cambió
        if (newQty != product.quantity) {
          await _repository.recordStockChange(
            productId: product.id,
            productName: nameController.text.trim(),
            previousQuantity: product.quantity,
            newQuantity: newQty,
          );
        }
        // Notificar si el stock actualizado está bajo
        final minStk =
            int.tryParse(minStockController.text.trim()) ?? product.minStock;
        if (newQty <= minStk && _salonId != null) {
          await _repository.notifyLowStock(
              _salonId!, nameController.text.trim());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Producto'),
        content:
            Text('¿Estás seguro de eliminar "${product.name}"?'),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
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
                  onPressed: () => Navigator.pop(context, false),
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
      await _repository.deleteProduct(product.id);
    }
  }

  void _showStockHistory(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Historial: ${product.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: _repository.getStockHistory(product.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Sin historial de cambios',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                );
              }
              // Ordenar por fecha descendente (los más recientes primero)
              final entries = docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data;
              }).toList();
              entries.sort((a, b) {
                final ta = a['createdAt'] as Timestamp?;
                final tb = b['createdAt'] as Timestamp?;
                if (ta == null && tb == null) return 0;
                if (ta == null) return 1;
                if (tb == null) return -1;
                return tb.compareTo(ta);
              });

              return ListView.builder(
                shrinkWrap: true,
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final prev = entry['previousQuantity'] as int? ?? 0;
                  final newQty = entry['newQuantity'] as int? ?? 0;
                  final change = entry['change'] as int? ?? (newQty - prev);
                  final note = entry['note'] as String? ?? '';
                  final timestamp = entry['createdAt'] as Timestamp?;
                  final changeStr = change >= 0 ? '+$change' : '$change';

                  return ListTile(
                    dense: true,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: change >= 0
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          changeStr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: change >= 0 ? Colors.green : Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    title: Text('$prev → $newQty ${product.unit}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (note.isNotEmpty)
                          Text(note,
                              style: const TextStyle(fontSize: 12)),
                        if (timestamp != null)
                          Text(
                            _formatTime(timestamp),
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textGrey),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cerrar'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(Timestamp ts) {
    final date = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_salonId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 64, color: AppColors.textGrey),
            const SizedBox(height: 16),
            Text(
              'Cargando inventario...',
              style: TextStyle(color: AppColors.textGrey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
        children: [
          // Barra de búsqueda (fuera del StreamBuilder para no perder foco)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          // Lista de productos (dentro de StreamBuilder)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _repository.getProducts(_salonId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty && _searchQuery.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2, size: 64,
                            color: AppColors.textGrey),
                        SizedBox(height: 16),
                        Text(
                          'No hay productos',
                          style: TextStyle(
                              color: AppColors.textGrey, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Añade tu primer producto',
                          style: TextStyle(
                              color: AppColors.textGrey, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                var products = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Product.fromMap(doc.id, data);
                }).toList();

                // Filtrar por búsqueda
                if (_searchQuery.isNotEmpty) {
                  products = products
                      .where((p) => p.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                // Ordenar: stock bajo primero
                products.sort((a, b) {
                  if (a.isLowStock && !b.isLowStock) return -1;
                  if (!a.isLowStock && b.isLowStock) return 1;
                  return a.name.compareTo(b.name);
                });

                return products.isEmpty
                    ? Center(
                        child: Text(
                          'Sin resultados',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _ProductCard(
                            product: product,
                            onEdit: () => _showEditProductDialog(product),
                            onDelete: () => _deleteProduct(product),
                            onHistory: () => _showStockHistory(product),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      );
    }
  }

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onHistory;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onHistory,
  });

  Color _stockColor() {
    if (product.quantity <= 0) return Colors.red;
    if (product.isLowStock) return Colors.orange;
    return Colors.green;
  }

  String _stockLabel() {
    if (product.quantity <= 0) return 'Sin stock';
    if (product.isLowStock) return 'Stock bajo';
    return 'En stock';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.textGrey.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre + acciones
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.history, size: 18),
                    onPressed: onHistory,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: AppColors.textGrey,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              if (product.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Cantidad + stock
              Row(
                children: [
                  // Indicador de stock
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _stockColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _stockColor().withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          product.quantity <= 0
                              ? Icons.error_outline
                              : product.isLowStock
                                  ? Icons.warning_amber
                                  : Icons.check_circle_outline,
                          size: 14,
                          color: _stockColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _stockLabel(),
                          style: TextStyle(
                            color: _stockColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Cantidad
                  Text(
                    '${product.quantity} ${product.unit}${product.quantity != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),

                  // Precio
                  if (product.price > 0)
                    Text(
                      '€${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
