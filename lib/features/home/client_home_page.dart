import 'package:flutter/material.dart';
import 'package:hair_connect/core/theme/app_colors.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

@override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido, Cliente'),
        automaticallyImplyLeading: false, // Evita mostrar el botón de retroceso
      ),
      body: const Center(
        child: Text(
          'Bienvenido a HairConnect, tu plataforma de gestión integral para peluquerías. Aquí podrás explorar los servicios disponibles, reservar citas y mantenerte al día con las últimas promociones de tu salón favorito.',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
