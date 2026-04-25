import 'package:flutter/material.dart';
import 'package:hair_connect/core/theme/app_colors.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {

  int _currentStep = 0;
  String? _selectedService;
  String? _selectedDate;
  String? _selectedTime;
  String? _selectedStylist;

  final List<String> _services = [
    'Corte de Pelo',
    'Coloración',
    'Peinado',
    'Tratamiento Capilar',
    'Alisado',
    'Mechas',
  ];

  final List<String> _stylists = [
    'Juan Pérez',
    'María Gómez',
    'Carlos Rodríguez',
    'Ana Martínez',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserva tu cita'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() {
              _currentStep++;
            });
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
        steps: [
          Step(
            title: const Text('Seleccionar Servicio'),
            isActive: _currentStep >= 0,
            content: Column(
              children: _services.map((service) {
            return RadioListTile<String>(
              title: Text(service),
              value: service,
              groupValue: _selectedService,
              activeColor: AppColors.primary,
              onChanged: (String? value) {
                setState(() {
                  _selectedService = value;
                });
              },
            );
          }).toList(),
        ),
      ),
        Step(
            title: const Text('Estilista'),
            isActive: _currentStep >= 1,
            content: Column(
              children: _stylists.map((stylist) {
                return RadioListTile<String>(
                  title: Text(stylist),
                  value: stylist,
                  groupValue: _selectedStylist,
                  activeColor: AppColors.primary,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedStylist = value;
                    });
                  },
                );
              }).toList(),
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
                  setState(() {
                    _selectedDate = '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                  });
                }
              },
              controller: TextEditingController(text: _selectedDate),
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
                  selected: _selectedTime == time,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTime = selected ? time : null;
                    });
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}


          

