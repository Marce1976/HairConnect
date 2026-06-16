import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/services/imgbb_service.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';

/// Pantalla para editar el perfil del salón asignado al usuario business.
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
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _websiteController = TextEditingController();
  final _scheduleController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasSalon = false;
  bool _isCreating = false;
  bool _isUploading = false;
  String? _salonId;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadSalon();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _websiteController.dispose();
    _scheduleController.dispose();
    super.dispose();
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
        if (mounted) setState(() => _hasSalon = false);
        return;
      }

      _salonId = salon.id;
      _nameController.text = salon.name;
      _addressController.text = salon.address;
      _cityController.text = salon.city ?? '';
      _phoneController.text = salon.phone ?? '';
      _descriptionController.text = salon.description ?? '';
      _instagramController.text = salon.instagram ?? '';
      _facebookController.text = salon.facebook ?? '';
      _websiteController.text = salon.website ?? '';
      _scheduleController.text = salon.schedule ?? '';
      _photoUrl = salon.photoUrl;
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
    if (_salonId == null) return;

    setState(() => _isSaving = true);
    try {
      await _repository.updateSalon(
        salonId: _salonId!,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        phone: _phoneController.text.trim(),
        description: _descriptionController.text.trim(),
        photoUrl: _photoUrl,
        instagram: _instagramController.text.trim(),
        facebook: _facebookController.text.trim(),
        website: _websiteController.text.trim(),
        schedule: _scheduleController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salón actualizado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Foto ─────────────────────────────────────────────────────

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Foto del salón',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Pegar URL'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showUrlDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Subir desde galería'),
                subtitle: Text(
                  ImgbbService.instance.isConfigured
                      ? 'Subir a ImgBB'
                      : 'Requiere API Key de ImgBB',
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadPhoto();
                },
              ),
              if (_photoUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Eliminar foto',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _photoUrl = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showUrlDialog() async {
    final controller = TextEditingController(text: _photoUrl ?? '');
    final url = await showDialog<String>(
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
                const Text(
                  'URL de la foto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'https://...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  keyboardType: TextInputType.url,
                  autofocus: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, controller.text.trim()),
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
                    onPressed: () => Navigator.pop(ctx),
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
          ),
        ),
      ),
    );
    if (url != null && url.isNotEmpty) {
      setState(() => _photoUrl = url);
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image == null) return;

    setState(() => _isUploading = true);
    try {
      final url = await ImgbbService.instance.uploadImage(image.path);
      setState(() => _photoUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ── Builders ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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

  Widget _buildNoSalonView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store, size: 64, color: AppColors.textGrey),
          const SizedBox(height: 16),
          Text('Aún no tienes un salón asignado',
              style: TextStyle(color: AppColors.textGrey, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Contacta al administrador',
              style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCreationForm() {
    return Column(
      children: [
        Expanded(child: _buildEditForm()),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _buildSubmitButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Foto ──
            Center(
              child: GestureDetector(
                onTap: _isUploading ? null : _showPhotoOptions,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: _photoUrl != null
                          ? NetworkImage(_photoUrl!)
                          : null,
                      child: _photoUrl == null
                          ? const Icon(Icons.store,
                              size: 48, color: AppColors.primary)
                          : null,
                    ),
                    if (_isUploading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(56),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Información básica ──
            _sectionTitle('Información básica'),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: AppColors.textGrey.withValues(alpha: 0.15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildField(
                      controller: _nameController,
                      label: 'Nombre del salón',
                      icon: Icons.store,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _addressController,
                      label: 'Dirección',
                      icon: Icons.location_on,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _cityController,
                      label: 'Ciudad',
                      icon: Icons.location_city,
                      hint: 'Ej: Vigo, Redondela...',
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _phoneController,
                      label: 'Teléfono',
                      icon: Icons.phone,
                      hint: '+34 612 345 678',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _descriptionController,
                      label: 'Descripción',
                      icon: Icons.description,
                      hint: 'Cuéntanos sobre tu salón...',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Redes sociales ──
            _sectionTitle('Redes sociales'),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: AppColors.textGrey.withValues(alpha: 0.15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildField(
                      controller: _instagramController,
                      label: 'Instagram',
                      icon: Icons.camera_alt,
                      hint: '@usuario o url',
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _facebookController,
                      label: 'Facebook',
                      icon: Icons.facebook,
                      hint: 'url o página',
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _websiteController,
                      label: 'Sitio web',
                      icon: Icons.language,
                      hint: 'https://...',
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Horarios ──
            _sectionTitle('Horarios'),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: AppColors.textGrey.withValues(alpha: 0.15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildField(
                  controller: _scheduleController,
                  label: 'Horario de apertura',
                  icon: Icons.access_time,
                  hint: 'Ej: Lun-Vie 9:00-20:00, Sáb 9:00-14:00',
                  maxLines: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Vista previa ──
            if (_nameController.text.isNotEmpty) ...[
              _sectionTitle('Vista previa'),
              const SizedBox(height: 12),
              _buildPreview(),
            ],
            const SizedBox(height: 24),

            // ── Botón guardar ──
            if (!_isCreating) _buildSubmitButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildField({
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
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPreview() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            BorderSide(color: AppColors.textGrey.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_photoUrl != null)
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(_photoUrl!),
                  )
                else
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.store,
                        size: 24, color: AppColors.primary),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_nameController.text,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      if (_cityController.text.isNotEmpty)
                        Text(_cityController.text,
                            style: TextStyle(
                                color: AppColors.textGrey, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _previewRow(Icons.location_on, _addressController.text),
            if (_phoneController.text.isNotEmpty)
              _previewRow(Icons.phone, _phoneController.text),
            if (_scheduleController.text.isNotEmpty)
              _previewRow(Icons.access_time, _scheduleController.text),
            if (_descriptionController.text.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(_descriptionController.text,
                  style: TextStyle(
                      color: AppColors.textGrey, fontSize: 13),
                  maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
            if (_instagramController.text.isNotEmpty ||
                _facebookController.text.isNotEmpty ||
                _websiteController.text.isNotEmpty) ...[
              const Divider(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  if (_instagramController.text.isNotEmpty)
                    _socialChip(Icons.camera_alt, _instagramController.text),
                  if (_facebookController.text.isNotEmpty)
                    _socialChip(Icons.facebook, _facebookController.text),
                  if (_websiteController.text.isNotEmpty)
                    _socialChip(Icons.language, _websiteController.text),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _previewRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textGrey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _socialChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(text, style: const TextStyle(fontSize: 11)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : (_isCreating ? _createSalon : _save),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(
                _isCreating ? 'Crear mi salón' : 'Guardar cambios',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
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
}
