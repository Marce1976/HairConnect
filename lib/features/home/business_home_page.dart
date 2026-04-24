import 'package:flutter/material.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/auth/auth_service.dart';
import 'package:hair_connect/features/auth/welcome_page.dart';

class BusinessHomePage extends StatelessWidget {
  const BusinessHomePage({super.key});

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Gestión para Negocios'),
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
        ],
      ),
      body: const Center(
        child: Text(
          'Bienvenido, Negocio',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}