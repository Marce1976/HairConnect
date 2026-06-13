import 'package:flutter/material.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final BusinessRepository _repository = sl<BusinessRepository>();

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Servicio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Servicio',
                border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Precio (€)',
                border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: 'Duración (minutos)',
                border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty || priceController.text.trim().isEmpty || durationController.text.trim().isEmpty) return;
              await _repository.addService(
                nameController.text.trim(),
                priceController.text.trim(),
                durationController.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(String serviceId, String currentName, String currentPrice, String currentDuration) {
    final nameController = TextEditingController(text: currentName);
    final priceController = TextEditingController(text: currentPrice);
    final durationController = TextEditingController(text: currentDuration);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Servicio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Servicio',
                border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Precio (€)',
                border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: 'Duración (minutos)',
                border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty || priceController.text.trim().isEmpty || durationController.text.trim().isEmpty) return;
              await _repository.updateService(
                serviceId: serviceId,
                name: nameController.text.trim(),
                price: priceController.text.trim(),
                duration: durationController.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddServiceDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _repository.getServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay servicios disponibles',
                style: TextStyle(color: AppColors.textGrey),
              ),
            );
          }
          final services = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.local_hospital, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    service['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${service['duration'] ?? ''} minutos' ' - €${service['price'] ?? ''}',
                    style: const TextStyle(color: AppColors.textGrey),
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
              );
            },
          );
        },
      ),
    );
  }
}
