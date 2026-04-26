import 'package:flutter/material.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/auth/auth_service.dart';
import 'package:hair_connect/features/auth/welcome_page.dart';
import 'package:hair_connect/features/booking/booking_page.dart';
import 'package:hair_connect/features/booking/booking_history_page.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

@override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
        title: const Text('Area del Cliente'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomePage()),
                (route) => false, // Elimina todas las rutas anteriores
              );
            },
          ),   
        ], // Evita mostrar el botón de retroceso
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            const Text(
              'Bienvenido a HairConnect',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingPage()),
                  );
                },
              child: const Text('Reservar Cita'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingHistoryPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text('Ver Historial de Reservas'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
