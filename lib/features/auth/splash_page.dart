import 'package:flutter/material.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: 1.5708,
              child: const FaIcon(
                FontAwesomeIcons.scissors,
                color: AppColors.gold,
                size: 72,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'HairConnect',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gestion integral para peluquerias',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
