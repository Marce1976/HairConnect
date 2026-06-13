import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';

/// Pantalla de detalle de un estilista.
/// Muestra los servicios que sabe hacer y un contador de veces realizados.
class StylistDetailPage extends StatefulWidget {
  final String stylistId;
  final String stylistName;

  const StylistDetailPage({
    super.key,
    required this.stylistId,
    required this.stylistName,
  });

  @override
  State<StylistDetailPage> createState() => _StylistDetailPageState();
}

class _StylistDetailPageState extends State<StylistDetailPage> {
  final BusinessRepository _repository = sl<BusinessRepository>();
  Map<String, Map<String, dynamic>>? _services;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final services = await _repository.getStylistServices(widget.stylistId);
      if (!mounted) return;
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _assignService(String serviceId, String serviceName) async {
    try {
      await _repository.assignServiceToStylist(
        stylistId: widget.stylistId,
        serviceId: serviceId,
        serviceName: serviceName,
      );
      await _loadServices();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Servicio asignado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _incrementCount(String serviceId) async {
    try {
      await _repository.incrementServiceCount(
        stylistId: widget.stylistId,
        serviceId: serviceId,
      );
      await _loadServices();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _decrementCount(String serviceId) async {
    try {
      await _repository.decrementServiceCount(
        stylistId: widget.stylistId,
        serviceId: serviceId,
      );
      await _loadServices();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _removeService(String serviceId) async {
    try {
      await _repository.removeServiceFromStylist(
        stylistId: widget.stylistId,
        serviceId: serviceId,
      );
      await _loadServices();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showAddServiceDialog() {
    // Obtener los servicios globales disponibles
    showDialog(
      context: context,
      builder: (ctx) => StreamBuilder<QuerySnapshot>(
        stream: _repository.getServices(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const AlertDialog(
              content: CircularProgressIndicator(),
            );
          }
          final allServices = snapshot.data!.docs;
          // Filtrar los que ya están asignados
          final assignedIds = _services?.keys.toSet() ?? {};
          final available = allServices
              .where((doc) => !assignedIds.contains(doc.id))
              .toList();

          if (available.isEmpty) {
            return AlertDialog(
              title: const Text('Agregar Servicio'),
              content: const Text('No hay más servicios disponibles.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          }

          return AlertDialog(
            title: const Text('Agregar Servicio'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: available.length,
                itemBuilder: (context, index) {
                  final doc = available[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(Icons.content_cut,
                        color: AppColors.primary),
                    title: Text(data['name'] ?? ''),
                    subtitle: Text(
                      '${data['duration'] ?? ''} min — €${data['price'] ?? ''}',
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _assignService(doc.id, data['name'] ?? '');
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignedList = _services?.entries.toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stylistName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Resumen
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: AppColors.primary.withValues(alpha: 0.05),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.stylistName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '${assignedList.length} servicios asignados',
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Lista de servicios
                Expanded(
                  child: assignedList.isEmpty
                      ? const Center(
                          child: Text(
                            'Sin servicios asignados',
                            style: TextStyle(color: AppColors.textGrey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: assignedList.length,
                          itemBuilder: (context, index) {
                            final entry = assignedList[index];
                            final serviceId = entry.key;
                            final serviceData = entry.value;
                            final name = serviceData['name'] ?? '';
                            final count = serviceData['count'] ?? 0;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    // Controles de contador
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove,
                                                size: 18),
                                            onPressed: count > 0
                                                ? () => _decrementCount(
                                                    serviceId)
                                                : null,
                                            constraints:
                                                const BoxConstraints(
                                                    minWidth: 36,
                                                    minHeight: 36),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets
                                                .symmetric(horizontal: 8),
                                            child: Text(
                                              '$count',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add,
                                                size: 18),
                                            onPressed: () =>
                                                _incrementCount(serviceId),
                                            constraints:
                                                const BoxConstraints(
                                                    minWidth: 36,
                                                    minHeight: 36),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red, size: 20),
                                      onPressed: () =>
                                          _removeService(serviceId),
                                      constraints: const BoxConstraints(
                                          minWidth: 36, minHeight: 36),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showAddServiceDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Agregar Servicio',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
