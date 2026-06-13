import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';

/// Pantalla para editar el perfil del salón asignado al usuario business.
///
/// El salón se busca automáticamente por el `ownerId` del usuario autenticado.
/// Si el administrador aún no le asignó un salón, muestra un mensaje informativo.
class SalonEditPage extends StatefulWidget {
  const SalonEditPage({super.key});

  @override
  State<SalonEditPage> createState() => _SalonEditPageState();
}

class _SalonEditPageState extends State<SalonEditPage> {
  final _repository = sl<BusinessRepository>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasSalon = false;
  bool _isCreating = false;
  String? _salonId;

  @override
  void initState() {
    super.initState();
    _loadSalon();
  }

  Future<void> _loadSalon() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no autenticado')),
          );
          Navigator.pop(context);
        }
        return;
      }

      final salon = await _repository.getSalonByOwnerId(user.uid);
      if (salon == null) {
        // No tiene salón asignado → mostrar mensaje
        if (mounted) setState(() => _hasSalon = false);
        return;
      }

      // Tiene salón → cargar datos para edición
      _salonId = salon.id;
      _nameController.text = salon.name;
      _addressController.text = salon.address;
      _phoneController.text = salon.phone ?? '';
      _cityController.text = salon.city ?? '';
      _descriptionController.text = salon.description ?? '';
      if (mounted) setState(() => _hasSalon = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await _repository.updateSalon(
        salonId: _salonId!,
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
      );
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _createSalon() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado')),
      );
      setState(() => _isSaving = false);
      return;
    }

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
        ownerId: user.uid,
      );
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('¡Salón creado correctamente!'),
            backgroundColor: Colors.green,
          ),
        );
        // Recargar datos del salón recién creado
        _isCreating = false;
        _loadSalon();
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error al crear salón: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Campo de formulario con estilo consistente
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  /// Pantalla cuando el usuario no tiene salón asignado
  Widget _buildNoSalonView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_mall_directory_outlined,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tu salón aún no está configurado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Completa los datos de tu salón\npara empezar a recibir reservas.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => setState(() => _isCreating = true),
              icon: const Icon(Icons.add_business),
              label: const Text('Crear mi salón'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formulario de edición del salón
  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera ilustrativa
            Center(
              child: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                radius: 48,
                child: const Icon(
                  Icons.store,
                  color: AppColors.primary,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tarjeta con sombra que contiene el formulario
            Card(
              elevation: 2,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _nameController,
                      label: 'Nombre del salón',
                      icon: Icons.store,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Obligatorio'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _addressController,
                      label: 'Dirección',
                      icon: Icons.location_on,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Obligatorio'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _cityController,
                      label: 'Ciudad',
                      icon: Icons.location_city,
                      hint: 'Ej: Vigo, Redondela, Pontevedra...',
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _phoneController,
                      label: 'Teléfono',
                      icon: Icons.phone,
                      hint: '+34 612 345 678',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _descriptionController,
                      label: 'Descripción',
                      icon: Icons.description,
                      hint: 'Cuéntanos sobre tu salón...',
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Vista previa
            if (_nameController.text.isNotEmpty) ...[
              const Text(
                'Vista previa',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameController.text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: AppColors.textGrey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _addressController.text,
                              style: const TextStyle(
                                  color: AppColors.textGrey),
                            ),
                          ),
                        ],
                      ),
                      if (_cityController.text.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_city,
                                size: 16, color: AppColors.textGrey),
                            const SizedBox(width: 4),
                            Text(_cityController.text,
                                style: const TextStyle(
                                    color: AppColors.textGrey)),
                          ],
                        ),
                      ],
                      if (_phoneController.text.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone,
                                size: 16, color: AppColors.textGrey),
                            const SizedBox(width: 4),
                            Text(_phoneController.text,
                                style: const TextStyle(
                                    color: AppColors.textGrey)),
                          ],
                        ),
                      ],
                      if (_descriptionController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _descriptionController.text,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Botón grande de confirmación (crear o guardar) al final del formulario
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving
            ? null
            : (_isCreating ? _createSalon : _save),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _isCreating ? 'Crear mi salón' : 'Guardar cambios',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isCreating ? 'Crear mi salón' : 'Mi Salón'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasSalon
              ? _buildEditForm()
              : _isCreating
                  ? _buildCreationForm()
                  : _buildNoSalonView(),
    );
  }

  /// Vista completa del formulario de creación con botón inferior
  Widget _buildCreationForm() {
    return Column(
      children: [
        Expanded(
          child: _buildEditForm(),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _buildSubmitButton(),
          ),
        ),
      ],
    );
  }
}
