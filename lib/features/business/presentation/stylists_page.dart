import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';

class StylistsPage extends StatefulWidget {
  const StylistsPage({super.key});

  @override
  State<StylistsPage> createState() => _StylistsPageState();
}

class _StylistsPageState extends State<StylistsPage> {
  final BusinessRepository _repository = sl<BusinessRepository>();

  void _showAddStylistDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Estilista'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del Estilista',
            border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              await _repository.addStylist(nameController.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Agregar'),
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
        onPressed: _showAddStylistDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _repository.getStylists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay estilistas disponibles',
                style: TextStyle(color: AppColors.textGrey),
              ),
            );
          }
          final stylists = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: stylists.length,
            itemBuilder: (context, index) {
              final stylist = stylists[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    stylist['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_right,
                            color: AppColors.primary),
                        onPressed: () => context.push(
                          '/business/home/stylist/${stylists[index].id}?name=${Uri.encodeComponent(stylist['name'] ?? '')}',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _repository.deleteStylist(stylists[index].id);
                        },
                      ),
                    ],
                  ),
                  onTap: () => context.push(
                    '/business/home/stylist/${stylists[index].id}?name=${Uri.encodeComponent(stylist['name'] ?? '')}',
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
