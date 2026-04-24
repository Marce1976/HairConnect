import 'package:flutter/material.dart';
import 'package:hair_connect/core/theme/app_colors.dart';

class BusinessHomePage extends StatelessWidget {
  const BusinessHomePage({super.key});

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Gestión para Negocios'),
        automaticallyImplyLeading: false, 
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