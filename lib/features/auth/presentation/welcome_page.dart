import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hair_connect/core/theme/app_colors.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _gradientAnim;

  // Pares de colores para el gradiente animado (azul → dorado)
  static const _gradientA = [Color(0xFF1a3a5c), Color(0xFF2a5173)];
  static const _gradientB = [Color(0xFF2a5173), Color(0xFFc8974a)];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _gradientAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientAnim,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    _gradientA[0],
                    _gradientB[0],
                    _gradientAnim.value,
                  )!,
                  Color.lerp(
                    _gradientA[1],
                    _gradientB[1],
                    _gradientAnim.value,
                  )!,
                ],
              ),
            ),
            child: Stack(
              children: [
                // ── Partículas flotantes ──
                ...List.generate(12, (i) => _FloatingParticle(i: i)),

                // ── Contenido principal ──
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icono tijera rotado
                          Transform.rotate(
                            angle: 1.5708,
                            child: const Icon(
                              Icons.content_cut,
                              color: AppColors.gold,
                              size: 64,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Bienvenido a HairConnect',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gestion integral para peluquerias',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context.go('/login/client'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: const Text('Cliente'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => context.go('/login/business'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: AppColors.gold,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Negocio'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Pequeño círculo decorativo que flota lentamente.
class _FloatingParticle extends StatefulWidget {
  final int i;
  const _FloatingParticle({required this.i});

  @override
  State<_FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _float;
  late final double _startX;
  late final double _startY;
  late final double _size;
  late final double _opacity;

  @override
  void initState() {
    super.initState();
    final rng = Random(widget.i * 99);
    _startX = rng.nextDouble() * 0.9 + 0.05;
    _startY = rng.nextDouble() * 0.9 + 0.05;
    _size = rng.nextDouble() * 6 + 3;
    _opacity = rng.nextDouble() * 0.2 + 0.05;

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: rng.nextInt(6) + 4),
    )..repeat(reverse: true);

    _float = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, _) {
        return Positioned(
          left: MediaQuery.of(context).size.width * _startX,
          top: MediaQuery.of(context).size.height * _startY +
              _float.value * 20,
          child: Opacity(
            opacity: _opacity,
            child: Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}