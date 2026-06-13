import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/business/data/look_repository.dart';
import 'package:hair_connect/features/business/domain/look.dart';
import 'package:hair_connect/features/booking/presentation/bloc/booking_bloc.dart';

class BookingPage extends StatefulWidget {
  final String? lookId;

  const BookingPage({super.key, this.lookId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int _currentStep = 0;

  // Estado para el flujo desde Look
  Look? _look;
  bool _lookLoading = true;
  String? _selectedDate;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.lookId != null) {
      _loadLook();
    } else {
      context.read<BookingBloc>().add(LoadBookingData());
    }
  }

  Future<void> _loadLook() async {
    try {
      final lookRepository = sl<LookRepository>();
      final snapshot = await lookRepository.getLookById(widget.lookId!);
      if (!mounted) return;
      if (snapshot != null && snapshot.exists) {
        final look = Look.fromMap(
          snapshot.id,
          snapshot.data() as Map<String, dynamic>,
        );
        setState(() {
          _look = look;
          _lookLoading = false;
        });
      } else {
        setState(() => _lookLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _lookLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingConfirmed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reserva confirmada exitosamente.')),
          );
          context.pop();
        } else if (state is BookingLookConfirmed) {
          _showSuccessOverlay(state);
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.lookId != null ? 'Confirmar reserva' : 'Reserva tu cita')),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // Flujo desde un Look
    if (widget.lookId != null) {
      if (_lookLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_look == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.textGrey),
              const SizedBox(height: 16),
              const Text(
                'No se pudo cargar el look',
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        );
      }
      return _buildLookBookingForm(_look!);
    }

    // Flujo normal (stepper)
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingInitial || state is BookingLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is BookingDataLoaded) {
          return _buildStepper(state);
        }
        if (state is BookingError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textGrey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<BookingBloc>().add(LoadBookingData());
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // ──────── Formulario rápido desde Look ────────

  Widget _buildLookBookingForm(Look look) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del look
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: 150,
              child: Image.network(
                look.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.broken_image, color: AppColors.textGrey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Salón
          Row(
            children: [
              const Icon(Icons.store, size: 18, color: AppColors.textGrey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  look.salonName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Estilista
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: AppColors.textGrey),
              const SizedBox(width: 8),
              Text(
                look.stylistName ?? 'Sin asignar',
                style: const TextStyle(fontSize: 15, color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Servicios
          if (look.services != null && look.services!.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: look.services!
                  .map((s) => Chip(
                        label: Text(s),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
          if (look.services != null && look.services!.isNotEmpty)
            const SizedBox(height: 12),

          // Precio
          if (look.price != null && look.price!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: look.onSale
                    ? Colors.red.withValues(alpha: 0.05)
                    : AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: look.onSale
                      ? Colors.red.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.euro, color: look.onSale ? Colors.red : AppColors.primary, size: 24),
                  const SizedBox(width: 4),
                  if (look.onSale) ...[
                    Text(
                      '€${look.price!}',
                      style: const TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '€${look.salePrice!}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ] else
                    Text(
                      look.price!,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                ],
              ),
            ),
          if (look.price != null && look.price!.isNotEmpty)
            const SizedBox(height: 12),

          const Divider(),
          const SizedBox(height: 8),

          // Fecha
          const Text('Fecha', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            readOnly: true,
            decoration: const InputDecoration(
              hintText: 'Selecciona una fecha',
              suffixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
            ),
            controller: TextEditingController(text: _selectedDate ?? ''),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null && mounted) {
                setState(() {
                  _selectedDate = '${picked.day}/${picked.month}/${picked.year}';
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Hora
          const Text('Hora', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(8, (index) {
              final time = '${9 + index}:00';
              return ChoiceChip(
                label: Text(time),
                selected: _selectedTime == time,
                onSelected: (selected) {
                  setState(() => _selectedTime = selected ? time : '');
                },
              );
            }),
          ),
          const SizedBox(height: 24),

          // Botón confirmar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedDate != null && _selectedTime != null && _selectedTime!.isNotEmpty
                  ? () => _confirmLookBooking(look)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Confirmar reserva',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLookBooking(Look look) {
    final finalPrice = look.onSale ? look.salePrice! : (look.price ?? '');
    context.read<BookingBloc>().add(ConfirmLookBooking(
          lookId: look.id,
          salonId: look.salonId,
          salonName: look.salonName,
          stylistName: look.stylistName ?? 'Sin asignar',
          services: look.services ?? [],
          price: finalPrice,
          date: _selectedDate!,
          time: _selectedTime!,
        ));
  }

  void _showSuccessOverlay(BookingLookConfirmed state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              '¡Reserva confirmada!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 16),
            _detailRow(Icons.store, state.salonName),
            _detailRow(Icons.person, state.stylistName),
            _detailRow(Icons.calendar_today, state.date),
            _detailRow(Icons.access_time, state.time),
            _detailRow(Icons.attach_money, state.price),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/lookbook');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Volver al inicio', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 15, color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }

  // ──────── Stepper original (sin lookId) ────────

  Widget _buildStepper(BookingDataLoaded state) {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: () {
        if (_currentStep < 3) {
          setState(() => _currentStep++);
        } else {
          context.read<BookingBloc>().add(ConfirmBooking(lookId: widget.lookId));
        }
      },
      onStepCancel: () {
        if (_currentStep > 0) {
          setState(() => _currentStep--);
        }
      },
      steps: [
        Step(
          title: const Text('Seleccionar Servicio'),
          isActive: _currentStep >= 0,
          content: RadioGroup<String>(
            groupValue: state.selectedService,
            onChanged: (String? value) {
              if (value != null) {
                context.read<BookingBloc>().add(SelectService(value));
              }
            },
            child: Column(
              children: state.services.map((service) {
                return RadioListTile<String>(
                  title: Text(service),
                  value: service,
                  activeColor: AppColors.primary,
                );
              }).toList(),
            ),
          ),
        ),
        Step(
          title: const Text('Estilista'),
          isActive: _currentStep >= 1,
          content: RadioGroup<String>(
            groupValue: state.selectedStylist,
            onChanged: (String? value) {
              if (value != null) {
                context.read<BookingBloc>().add(SelectStylist(value));
              }
            },
            child: Column(
              children: state.stylists.map((stylist) {
                return RadioListTile<String>(
                  title: Text(stylist),
                  value: stylist,
                  activeColor: AppColors.primary,
                );
              }).toList(),
            ),
          ),
        ),
        Step(
          title: const Text('Seleccionar Fecha'),
          isActive: _currentStep >= 2,
          content: TextField(
            readOnly: true,
            decoration: const InputDecoration(
              hintText: 'Selecciona una fecha',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (pickedDate != null && mounted) {
                context.read<BookingBloc>().add(
                  SelectDate(
                    '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}',
                  ),
                );
              }
            },
            controller: TextEditingController(text: state.selectedDate),
          ),
        ),
        Step(
          title: const Text('Seleccionar Hora'),
          isActive: _currentStep >= 3,
          content: Wrap(
            spacing: 8.0,
            children: List.generate(8, (index) {
              final time = '${9 + index}:00';
              return ChoiceChip(
                label: Text(time),
                selected: state.selectedTime == time,
                onSelected: (selected) {
                  context.read<BookingBloc>().add(
                    SelectTime(selected ? time : ''),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}
