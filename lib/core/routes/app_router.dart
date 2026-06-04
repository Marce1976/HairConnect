import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/features/auth/presentation/splash_page.dart';
import 'package:hair_connect/features/auth/presentation/welcome_page.dart';
import 'package:hair_connect/features/auth/presentation/login_page.dart';
import 'package:hair_connect/features/auth/presentation/register_page.dart';
import 'package:hair_connect/features/home/presentation/client_home_page.dart';
import 'package:hair_connect/features/home/presentation/business_home_page.dart';
import 'package:hair_connect/features/booking/presentation/booking_page.dart';
import 'package:hair_connect/features/booking/presentation/booking_history_page.dart';
import 'package:hair_connect/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:hair_connect/features/notifications/notifications_page.dart';
import 'package:hair_connect/features/business/presentation/agenda_page.dart';
import 'package:hair_connect/features/business/presentation/stylists_page.dart';
import 'package:hair_connect/features/business/presentation/services_page.dart';
import 'package:hair_connect/features/business/presentation/stats_page.dart';
import 'package:hair_connect/features/business/presentation/salon_search_page.dart';
import 'package:hair_connect/features/business/presentation/salon_detail_page.dart';
import 'package:hair_connect/features/business/presentation/lookbook_page.dart';
import 'package:hair_connect/features/business/presentation/salon_gallery_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/login/:role',
      builder: (context, state) {
        final role = state.pathParameters['role']!;
        return LoginPage(isClient: role == 'client');
      },
    ),
    GoRoute(
      path: '/register/:role',
      builder: (context, state) {
        final role = state.pathParameters['role']!;
        return RegisterPage(isClient: role == 'client');
      },
    ),
    GoRoute(
      path: '/client/home',
      builder: (context, state) => const ClientHomePage(),
    ),
    GoRoute(
      path: '/business/home',
      redirect: (context, state) => '/business/home/agenda',
    ),
    ShellRoute(
      builder: (context, state, child) => BusinessShell(child: child),
      routes: [
        GoRoute(
          path: '/business/home/agenda',
          builder: (context, state) => const AgendaPage(),
        ),
        GoRoute(
          path: '/business/home/stylists',
          builder: (context, state) => const StylistsPage(),
        ),
        GoRoute(
          path: '/business/home/services',
          builder: (context, state) => const ServicesPage(),
        ),
        GoRoute(
          path: '/business/home/stats',
          builder: (context, state) => const StatsPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/booking',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<BookingBloc>(),
        child: const BookingPage(),
      ),
    ),
    GoRoute(
      path: '/booking/history',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<BookingBloc>(),
        child: const BookingHistoryPage(),
      ),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/salons',
      builder: (context, state) => const SalonSearchPage(),
    ),
    GoRoute(
      path: '/salons/:salonId',
      builder: (context, state) {
        final salonId = state.pathParameters['salonId']!;
        return SalonDetailPage(salonId: salonId);
      },
    ),
    GoRoute(
      path: '/lookbook',
      builder: (context, state) => const LookBookPage(),
    ),
    GoRoute(
      path: '/salons/:salonId/gallery',
      builder: (context, state) {
        final salonId = state.pathParameters['salonId']!;
        return SalonGalleryPage(salonId: salonId);
      },
    ),
  ],
);
