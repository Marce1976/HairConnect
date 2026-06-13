import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/auth/presentation/bloc/auth_bloc.dart';

/// Shell widget used by GoRouter's ShellRoute.
/// Provides the shared AppBar, logout action, and BottomNavigationBar
/// for all business sub-pages (agenda, stylists, services, stats).
class BusinessShell extends StatelessWidget {
  final Widget child;

  const BusinessShell({super.key, required this.child});

  int _currentIndex(String location) {
    if (location.contains('/business/home/stylists')) return 1;
    if (location.contains('/business/home/services')) return 2;
    if (location.contains('/business/home/looks')) return 3;
    if (location.contains('/business/home/salon')) return 4;
    if (location.contains('/business/home/stats')) return 5;
    return 0; // agenda (default)
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesion'),
        content: const Text('Estas seguro de que quieres cerrar sesion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      authBloc.add(LogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _currentIndex(location);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          context.go('/welcome');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onLongPress: () => context.go('/admin/create-salon'),
            child: const Text('Area de Negocio'),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/business/home/agenda');
              case 1:
                context.go('/business/home/stylists');
              case 2:
                context.go('/business/home/services');
              case 3:
                context.go('/business/home/looks');
              case 4:
                context.go('/business/home/salon');
              case 5:
                context.go('/business/home/stats');
            }
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textGrey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Agenda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Estilistas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.content_cut),
              label: 'Servicios',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.image),
              label: 'Looks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'Mi Salón',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Estadísticas',
            ),
          ],
        ),
      ),
    );
  }
}
