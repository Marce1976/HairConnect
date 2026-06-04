import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/booking/presentation/bloc/booking_bloc.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(LoadBookingData());
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
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Reserva tu cita')),
        body: BlocBuilder<BookingBloc, BookingState>(
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
        ),
      ),
    );
  }

  Widget _buildStepper(BookingDataLoaded state) {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: () {
        if (_currentStep < 3) {
          setState(() => _currentStep++);
        } else {
          context.read<BookingBloc>().add(ConfirmBooking());
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
