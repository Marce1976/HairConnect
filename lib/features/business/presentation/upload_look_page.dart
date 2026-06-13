import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/services/storage_service.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';
import 'package:hair_connect/features/business/data/look_repository.dart';
import 'package:hair_connect/features/business/domain/look.dart';

class UploadLookPage extends StatefulWidget {
  const UploadLookPage({super.key});

  @override
  State<UploadLookPage> createState() => _UploadLookPageState();
}

class _UploadLookPageState extends State<UploadLookPage> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = sl<StorageService>();
  final _businessRepository = sl<BusinessRepository>();
  final _lookRepository = sl<LookRepository>();

  XFile? _image;
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servicesController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedSalonId;
  String? _selectedSalonName;
  String? _selectedStylistId;
  String? _selectedStylistName;
  bool _isLoading = false;
  bool _useUrl = true; // Por defecto usa URL (no requiere Storage)

  @override
  void dispose() {
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _servicesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
        _useUrl = false;
        _imageUrlController.clear();
      });
    }
  }

  String? _getImagePreview() {
    if (_imageUrlController.text.isNotEmpty) return _imageUrlController.text;
    if (_image != null) return _image!.path;
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final imagePreview = _getImagePreview();
    if (imagePreview == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una imagen o pega una URL')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Obtener la URL final de la imagen
      String imageUrl;
      if (_useUrl) {
        // Usar la URL directamente
        imageUrl = _imageUrlController.text.trim();
      } else if (_image != null) {
        // Intentar subir a Storage
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final uploaded = await _storageService.uploadFromFile(
          filePath: _image!.path,
          salonId: _selectedSalonId!,
          fileName: fileName,
        );
        imageUrl = uploaded;
      } else {
        throw Exception('No hay imagen disponible');
      }

      final servicesText = _servicesController.text.trim();
      final services = servicesText.isNotEmpty
          ? servicesText
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList()
          : null;

      final description = _descriptionController.text.trim();
      final price = _priceController.text.trim();

      final look = Look(
        id: '',
        salonId: _selectedSalonId!,
        salonName: _selectedSalonName ?? '',
        stylistId: _selectedStylistId,
        stylistName: _selectedStylistName,
        imageUrl: imageUrl,
        description: description.isNotEmpty ? description : null,
        services: services,
        price: price.isNotEmpty ? price : null,
        createdAt: DateTime.now(),
      );

      await _lookRepository.addLook(look);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Look subido correctamente')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subir Look')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSection(),
              const SizedBox(height: 16),
              _buildSalonDropdown(),
              const SizedBox(height: 16),
              _buildStylistDropdown(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildServicesField(),
              const SizedBox(height: 16),
              _buildPriceField(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final preview = _getImagePreview();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Previsualización
        if (preview != null)
          Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _useUrl
                  ? Image.network(
                      preview,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => const Center(
                        child: Text('URL inválida', style: TextStyle(color: AppColors.textGrey)),
                      ),
                    )
                  : Image.file(
                      File(preview),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
          ),

        // Campo de URL
        TextFormField(
          controller: _imageUrlController,
          decoration: const InputDecoration(
            labelText: 'URL de la imagen',
            hintText: 'https://ejemplo.com/foto.jpg',
            border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
            prefixIcon: Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),

        // Botón para seleccionar archivo
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('O elegir desde galería'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_image != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => setState(() {
                    _image = null;
                    _useUrl = true;
                  }),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalonDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: _businessRepository.getSalons(),
      builder: (context, snapshot) {
        final salons = snapshot.data?.docs ?? [];
        return DropdownButtonFormField<String>(
          initialValue: _selectedSalonId,
          decoration: const InputDecoration(
            labelText: 'Salón *',
            border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
          ),
          hint: const Text('Selecciona un salón'),
          isExpanded: true,
          items: salons.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return DropdownMenuItem(
              value: doc.id,
              child: Text(data['name'] as String? ?? ''),
            );
          }).toList(),
          onChanged: _isLoading
              ? null
              : (value) {
                  final doc = salons.firstWhere((d) => d.id == value);
                  final data = doc.data() as Map<String, dynamic>;
                  setState(() {
                    _selectedSalonId = value;
                    _selectedSalonName = data['name'] as String?;
                  });
                },
          validator: (value) => value == null ? 'Selecciona un salón' : null,
        );
      },
    );
  }

  Widget _buildStylistDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: _businessRepository.getStylists(),
      builder: (context, snapshot) {
        final stylists = snapshot.data?.docs ?? [];
        return DropdownButtonFormField<String>(
          initialValue: _selectedStylistId,
          decoration: const InputDecoration(
            labelText: 'Estilista (opcional)',
            border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
          ),
          hint: const Text('Selecciona un estilista'),
          isExpanded: true,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Ninguno'),
            ),
            ...stylists.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return DropdownMenuItem(
                value: doc.id,
                child: Text(data['name'] as String? ?? ''),
              );
            }),
          ],
          onChanged: _isLoading
              ? null
              : (value) {
                  if (value == null) {
                    setState(() {
                      _selectedStylistId = null;
                      _selectedStylistName = null;
                    });
                    return;
                  }
                  final doc = stylists.firstWhere((d) => d.id == value);
                  final data = doc.data() as Map<String, dynamic>;
                  setState(() {
                    _selectedStylistId = value;
                    _selectedStylistName = data['name'] as String?;
                  });
                },
        );
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Descripción (opcional)',
        border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
      ),
      maxLines: 3,
    );
  }

  Widget _buildServicesField() {
    return TextFormField(
      controller: _servicesController,
      decoration: const InputDecoration(
        labelText: 'Servicios (opcional)',
        hintText: 'Ej: Corte, Color, Peinado',
        border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
      ),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: const InputDecoration(
        labelText: 'Precio (opcional)',
        border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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
                'Subir Look',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
