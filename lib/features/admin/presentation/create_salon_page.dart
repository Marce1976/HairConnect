import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/auth/data/user_service.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';

/// Pantalla de administración para crear un salón y asignarlo a un usuario
/// business por su email.
///
/// Solo accesible para usuarios con `isAdmin: true` en su documento Firestore.
/// Acceso: ruta `/admin/create-salon`
class CreateSalonPage extends StatefulWidget {
  const CreateSalonPage({super.key});

  @override
  State<CreateSalonPage> createState() => _CreateSalonPageState();
}

class _CreateSalonPageState extends State<CreateSalonPage> {
  final _repository = BusinessRepository();
  final _firestore = FirebaseFirestore.instance;
  final _userService = UserService();

  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = true;
  bool _isAdmin = false;
  bool _isLookingUp = false;
  bool _isCreating = false;
  String? _foundUserId;
  String? _foundUserName;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _isAdmin = false;
        });
        return;
      }
      final admin = await _userService.isAdmin(user.uid);
      setState(() {
        _isAdmin = admin;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isAdmin = false;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _lookupUser() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _isLookingUp = true;
      _foundUserId = null;
      _foundUserName = null;
      _errorText = null;
    });

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _errorText = 'No se encontró ningún usuario con ese email.\n'
              'Posibles causas:\n'
              '• El usuario aún no se registró en la app.\n'
              '• El email está escrito con mayúsculas/minúsculas diferentes.\n'
              '• Revisá en Firebase Console → Firestore → colección "users" '
              'para verificar.';
        });
        return;
      }

      final doc = snapshot.docs.first;
      final data = doc.data();
      setState(() {
        _foundUserId = doc.id;
        _foundUserName = data['name'] as String? ?? '—';
      });
    } catch (e) {
      setState(() {
        _errorText = 'Error al buscar usuario: $e';
      });
    } finally {
      setState(() => _isLookingUp = false);
    }
  }

  Future<void> _createSalon() async {
    if (_foundUserId == null) return;
    if (_nameController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nombre y dirección son obligatorios'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      await _repository.createSalon(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        ownerId: _foundUserId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Salón creado y asignado correctamente!'),
            backgroundColor: Colors.green,
          ),
        );
        // Limpiar formulario
        _emailController.clear();
        _nameController.clear();
        _addressController.clear();
        _cityController.clear();
        _phoneController.clear();
        _descriptionController.clear();
        setState(() {
          _foundUserId = null;
          _foundUserName = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear salón: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 24),
            const Text(
              'Acceso denegado',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No tienes permisos de administrador.\n'
              'Esta sección es solo para el administrador de la app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/business/home/agenda'),
        ),
        title: const Text('Admin — Crear Salón'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isAdmin
              ? _buildAccessDenied()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sección 1: buscar usuario por email
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '1. Buscar usuario business',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputField(
                                      controller: _emailController,
                                      label: 'Email del usuario',
                                      icon: Icons.email,
                                      hint: 'usuario@ejemplo.com',
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed:
                                        _isLookingUp ? null : _lookupUser,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 16),
                                    ),
                                    child: _isLookingUp
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Buscar'),
                                  ),
                                ],
                              ),
                              if (_errorText != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _errorText!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 13),
                                ),
                              ],
                              if (_foundUserId != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.green.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Colors.green, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Usuario encontrado: $_foundUserName ($_foundUserId)',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sección 2: datos del salón
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '2. Datos del salón',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildInputField(
                                controller: _nameController,
                                label: 'Nombre del salón *',
                                icon: Icons.store,
                              ),
                              const SizedBox(height: 12),
                              _buildInputField(
                                controller: _addressController,
                                label: 'Dirección *',
                                icon: Icons.location_on,
                              ),
                              const SizedBox(height: 12),
                              _buildInputField(
                                controller: _cityController,
                                label: 'Ciudad',
                                icon: Icons.location_city,
                                hint: 'Ej: Vigo, Redondela...',
                              ),
                              const SizedBox(height: 12),
                              _buildInputField(
                                controller: _phoneController,
                                label: 'Teléfono',
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 12),
                              _buildInputField(
                                controller: _descriptionController,
                                label: 'Descripción',
                                icon: Icons.description,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed:
                                      _isCreating || _foundUserId == null
                                          ? null
                                          : _createSalon,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isCreating
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Crear Salón y Asignar',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                              if (_foundUserId == null)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Primero busca un usuario business en el paso 1',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
