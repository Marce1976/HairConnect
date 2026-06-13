import 'package:flutter/material.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';
import 'package:hair_connect/features/business/domain/salon.dart';

/// Pantalla para crear o editar el perfil del salón.
///
/// Si [salonId] es `null` y no hay ningún salón en la base de datos,
/// se muestra el formulario vacío para crear uno nuevo.
class SalonEditPage extends StatefulWidget {
  final String? salonId;

  const SalonEditPage({super.key, this.salonId});

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
  String? _salonId;

  /// `true` si estamos creando un salón nuevo (no existe aún)
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadSalon();
  }

  Future<void> _loadSalon() async {
    try {
      String? id = widget.salonId;

      // Si no se pasó un ID, buscar el primer salón disponible
      if (id == null) {
        final salons = await _repository.getSalons().first;
        if (salons.docs.isEmpty) {
          // No hay salones → modo creación
          if (mounted) setState(() => _isCreating = true);
          return;
        }
        id = salons.docs.first.id;
      }

      // Modo edición: cargar datos existentes
      _salonId = id;
      final doc = await _repository.getSalonById(id);
      if (!doc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Salón no encontrado')),
          );
          Navigator.pop(context);
        }
        return;
      }
      final salon = Salon.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      _nameController.text = salon.name;
      _addressController.text = salon.address;
      _phoneController.text = salon.phone ?? '';
      _cityController.text = salon.city ?? '';
      _descriptionController.text = salon.description ?? '';
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
      if (_isCreating) {
        // Crear nuevo salón
        final newId = await _repository.createSalon(
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
          setState(() {
            _salonId = newId;
            _isCreating = false;
          });
          messenger.showSnackBar(
            const SnackBar(
              content: Text('¡Salón creado correctamente!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Actualizar salón existente
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isCreating ? 'Crear Salón' : 'Mi Salón'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _isCreating ? 'Crear' : 'Guardar',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabecera ilustrativa
                    Center(
                      child: CircleAvatar(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        radius: 48,
                        child: Icon(
                          _isCreating ? Icons.add_business : Icons.store,
                          color: AppColors.primary,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isCreating)
                      const Center(
                        child: Text(
                          'Registra tu salón para que los clientes\npuedan encontrarte',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.textGrey, fontSize: 13),
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

                    // Vista previa (solo en modo edición)
                    if (!_isCreating && _nameController.text.isNotEmpty) ...[
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
            ),
    );
  }
}
