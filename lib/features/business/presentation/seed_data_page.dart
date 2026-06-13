import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hair_connect/core/theme/app_colors.dart';

class SeedDataPage extends StatefulWidget {
  const SeedDataPage({super.key});

  @override
  State<SeedDataPage> createState() => _SeedDataPageState();
}

class _SeedDataPageState extends State<SeedDataPage> {
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String _statusText = '';

  Future<void> _seedData() async {
    setState(() {
      _isLoading = true;
      _statusText = '';
    });

    try {
      final salon1Id = await _seedSalons();
      final salon2Id = await _seedSalon2();
      await _seedLooksForSalons(salon1Id, salon2Id);
      await _seedStylists();
      await _seedServices();

      if (!mounted) return;
      setState(() {
        _statusText = '✅ Datos de ejemplo creados exitosamente';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusText = '❌ Error: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String> _seedSalon(
      String name, String address, String phone, String description,
      double rating) async {
    final snapshot = await _firestore
        .collection('salons')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    }

    final ref = await _firestore.collection('salons').add({
      'name': name,
      'address': address,
      'phone': phone,
      'description': description,
      'rating': rating,
      'galleryImages': [],
    });
    return ref.id;
  }

  Future<String> _seedSalons() async {
    setState(() => _statusText = 'Creando salones...');

    final id = await _seedSalon(
      'Salón Bella Vista',
      'Av. Principal 123',
      '+54 11 1234-5678',
      'Salón de belleza con los mejores profesionales',
      4.5,
    );

    setState(() => _statusText = '✓ Salón Bella Vista listo');
    return id;
  }

  Future<String> _seedSalon2() async {
    final id = await _seedSalon(
      'Studio Moderno',
      'Calle Secundaria 456',
      '+54 11 8765-4321',
      'Estilo y vanguardia en cada corte',
      4.2,
    );

    setState(() => _statusText = '✓ Studio Moderno listo');
    return id;
  }

  Future<void> _seedLooksForSalons(String salon1Id, String salon2Id) async {
    setState(() => _statusText = 'Creando looks...');

    // Eliminar looks existentes para poder regenerarlos
    final existing = await _firestore.collection('looks').get();
    for (final doc in existing.docs) {
      await doc.reference.delete();
    }

    final now = Timestamp.now();
    final looks = [
      {
        'salonId': salon1Id,
        'salonName': 'Salón Bella Vista',
        'stylistName': 'María García',
        'imageUrl':
            'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
        'services': ['Corte de dama', 'Peinado de fiesta'],
        'price': '6000',
        'createdAt': now,
      },
      {
        'salonId': salon1Id,
        'salonName': 'Salón Bella Vista',
        'stylistName': 'Carlos López',
        'imageUrl':
            'https://images.unsplash.com/photo-1521590832167-161ace11c8b4?w=400',
        'services': ['Corte de caballero'],
        'price': '1500',
        'createdAt': now,
      },
      {
        'salonId': salon1Id,
        'salonName': 'Salón Bella Vista',
        'stylistName': 'Ana Martínez',
        'imageUrl':
            'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
        'services': ['Coloración completa', 'Peinado de fiesta'],
        'price': '8500',
        'createdAt': now,
      },
      {
        'salonId': salon2Id,
        'salonName': 'Studio Moderno',
        'stylistName': 'María García',
        'imageUrl':
            'https://images.unsplash.com/photo-1567894340315-735d7c361db7?w=400',
        'services': ['Corte de dama'],
        'price': '2500',
        'createdAt': now,
      },
      {
        'salonId': salon2Id,
        'salonName': 'Studio Moderno',
        'stylistName': 'Carlos López',
        'imageUrl':
            'https://images.unsplash.com/photo-1596728325488-58c87691e9af?w=400',
        'services': ['Corte de caballero'],
        'price': '1500',
        'createdAt': now,
      },
      {
        'salonId': salon2Id,
        'salonName': 'Studio Moderno',
        'stylistName': 'Ana Martínez',
        'imageUrl':
            'https://images.unsplash.com/photo-1559136555-9303baea8ebd?w=400',
        'services': ['Coloración completa'],
        'price': '5000',
        'createdAt': now,
      },
    ];

    for (final look in looks) {
      await _firestore.collection('looks').add(look);
    }

    setState(() => _statusText = '✓ Looks creados');
  }

  Future<void> _seedStylists() async {
    setState(() => _statusText = 'Creando estilistas...');

    final snapshot = await _firestore.collection('stylists').limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      setState(() => _statusText = '✓ Estilistas ya existen, saltando...');
      return;
    }

    final stylists = ['María García', 'Carlos López', 'Ana Martínez'];
    for (final name in stylists) {
      await _firestore.collection('stylists').add({'name': name});
    }

    setState(() => _statusText = '✓ Estilistas creados');
  }

  Future<void> _seedServices() async {
    setState(() => _statusText = 'Creando servicios...');

    final snapshot = await _firestore.collection('services').limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      setState(() => _statusText = '✓ Servicios ya existen, saltando...');
      return;
    }

    final services = [
      {'name': 'Corte de dama', 'price': '2500', 'duration': '45'},
      {'name': 'Corte de caballero', 'price': '1500', 'duration': '30'},
      {'name': 'Coloración completa', 'price': '5000', 'duration': '120'},
      {'name': 'Peinado de fiesta', 'price': '3500', 'duration': '60'},
    ];
    for (final service in services) {
      await _firestore.collection('services').add(service);
    }

    setState(() => _statusText = '✓ Servicios creados');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seed Data')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _seedData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Poblar datos de ejemplo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.go('/admin/create-salon'),
                icon: const Icon(Icons.admin_panel_settings, size: 18),
                label: const Text('Admin: Crear salón para usuario'),
                style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
