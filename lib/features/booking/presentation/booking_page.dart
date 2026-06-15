import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/business/data/look_repository.dart';
import 'package:hair_connect/features/business/domain/look.dart';
import 'package:hair_connect/features/booking/presentation/bloc/booking_bloc.dart';

/// Pantalla de confirmación de reserva desde un Look.
///
/// Muestra los detalles del look (imagen, salón, estilista, servicios, precio)
/// y permite al cliente seleccionar fecha y hora para confirmar.
class BookingPage extends StatefulWidget {
  final String? lookId;

  const BookingPage({super.key, this.lookId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  Look? _look;
  bool _lookLoading = true;
  bool _isBooking = false;
  String? _selectedDate;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.lookId != null) {
      _loadLook();
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
        if (state is BookingLookConfirmed) {
          setState(() => _isBooking = false);
          _showSuccessOverlay(state);
        } else if (state is BookingError) {
          setState(() => _isBooking = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Confirmar reserva'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (widget.lookId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.textGrey),
            SizedBox(height: 16),
            Text(
              'Selecciona un look desde el catálogo\npara hacer una reserva',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 15),
            ),
          ],
        ),
      );
    }

    if (_lookLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_look == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: AppColors.textGrey),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar el look',
              style: TextStyle(color: AppColors.textGrey, fontSize: 16),
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

    return _buildBookingForm(_look!);
  }

  Widget _buildBookingForm(Look look) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Imagen del look ───
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: 200,
              child: Image.network(
                look.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.broken_image,
                      color: AppColors.textGrey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ─── Salón y estilista ───
          Row(
            children: [
              const Icon(Icons.store, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  look.salonName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (look.stylistName != null)
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: AppColors.textGrey),
                const SizedBox(width: 8),
                Text(
                  look.stylistName!,
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.textGrey),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // ─── Servicios ───
          if (look.services != null && look.services!.isNotEmpty) ...[
            const Text(
              'Servicios incluidos',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: look.services!
                  .map((s) => Chip(
                        label: Text(s),
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // ─── Precio ───
          if (look.price != null && look.price!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
                  Icon(Icons.euro,
                      color:
                          look.onSale ? Colors.red : AppColors.primary,
                      size: 28),
                  const SizedBox(width: 8),
                  if (look.onSale) ...[
                    Text(
                      '€${look.price!}',
                      style: const TextStyle(
                        fontSize: 18,
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '€${look.salePrice!}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'OFERTA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else
                    Text(
                      '€${look.price!}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ─── Fecha y hora ───
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Elige fecha y hora',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),

          // Fecha
          _buildDatePicker(),
          const SizedBox(height: 16),

          // Hora
          _buildTimePicker(),
          const SizedBox(height: 32),

          // ─── Botón confirmar ───
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  _selectedDate != null &&
                          _selectedTime != null &&
                          _selectedTime!.isNotEmpty &&
                          !_isBooking
                      ? () => _confirmBooking(look)
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isBooking
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Confirmar reserva',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null && mounted) {
          setState(() {
            _selectedDate =
                '${picked.day}/${picked.month}/${picked.year}';
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate ?? 'Selecciona una fecha',
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedDate != null
                      ? AppColors.textDark
                      : AppColors.textGrey,
                ),
              ),
            ),
            if (_selectedDate != null)
              GestureDetector(
                onTap: () => setState(() => _selectedDate = null),
                child: const Icon(Icons.close,
                    size: 18, color: AppColors.textGrey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(10, (index) {
        final time = '${9 + index}:00';
        final isSelected = _selectedTime == time;
        return ChoiceChip(
          label: SizedBox(
            width: 60,
            child: Center(
              child: Text(
                time,
                style: TextStyle(
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ),
          selected: isSelected,
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.background,
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (selected) {
            setState(() => _selectedTime = selected ? time : '');
          },
        );
      }),
    );
  }

  void _confirmBooking(Look look) {
    setState(() => _isBooking = true);
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              '¡Reserva confirmada!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            _detailRow(Icons.store, state.salonName),
            _detailRow(Icons.person, state.stylistName),
            _detailRow(Icons.calendar_today, state.date),
            _detailRow(Icons.access_time, state.time),
            _detailRow(Icons.attach_money, '€${state.price}'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.replace('/lookbook');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Volver al catálogo',
                    style: TextStyle(fontSize: 16)),
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
            child: Text(text,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }
}
