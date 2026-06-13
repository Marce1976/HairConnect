import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hair_connect/core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconAnim;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _iconAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
    ));

    _titleFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    ));

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
    ));

    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    ));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      context.go('/welcome');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _iconAnim,
              child: ScaleTransition(
                scale: _iconAnim,
                child: Transform.rotate(
                  angle: 1.5708,
                  child: const Icon(
                    Icons.content_cut,
                    color: AppColors.gold,
                    size: 72,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SlideTransition(
              position: _titleSlide,
              child: FadeTransition(
                opacity: _titleFade,
                child: const Text(
                  'HairConnect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SlideTransition(
              position: _subtitleSlide,
              child: FadeTransition(
                opacity: _subtitleFade,
                child: const Text(
                  'Gestion integral para peluquerias',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
