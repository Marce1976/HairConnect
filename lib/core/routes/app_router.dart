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
import 'package:hair_connect/features/booking/presentation/my_booking_page.dart';
import 'package:hair_connect/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:hair_connect/features/notifications/notifications_page.dart';
import 'package:hair_connect/features/business/presentation/agenda_page.dart';
import 'package:hair_connect/features/business/presentation/stylists_page.dart';
import 'package:hair_connect/features/business/presentation/stylist_detail_page.dart';
import 'package:hair_connect/features/business/presentation/services_page.dart';
import 'package:hair_connect/features/business/presentation/stats_page.dart';
import 'package:hair_connect/features/business/presentation/business_looks_page.dart';
import 'package:hair_connect/features/business/presentation/salon_search_page.dart';
import 'package:hair_connect/features/business/presentation/salon_detail_page.dart';
import 'package:hair_connect/features/business/presentation/lookbook_page.dart';
import 'package:hair_connect/features/business/presentation/look_detail_page.dart';
import 'package:hair_connect/features/business/presentation/favorites_page.dart';
import 'package:hair_connect/features/business/presentation/upload_look_page.dart';
import 'package:hair_connect/features/business/presentation/seed_data_page.dart';
import 'package:hair_connect/features/business/presentation/salon_gallery_page.dart';
import 'package:hair_connect/features/business/presentation/salon_edit_page.dart';
import 'package:hair_connect/features/admin/presentation/create_salon_page.dart';

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
          path: '/business/home/stylist/:stylistId',
          builder: (context, state) {
            final stylistId = state.pathParameters['stylistId']!;
            final stylistName =
                state.uri.queryParameters['name'] ?? 'Estilista';
            return StylistDetailPage(
              stylistId: stylistId,
              stylistName: stylistName,
            );
          },
        ),
        GoRoute(
          path: '/business/home/services',
          builder: (context, state) => const ServicesPage(),
        ),
        GoRoute(
          path: '/business/home/looks',
          builder: (context, state) => const BusinessLooksPage(),
        ),
        GoRoute(
          path: '/business/home/salon',
          builder: (context, state) => const SalonEditPage(),
        ),
        GoRoute(
          path: '/business/home/stats',
          builder: (context, state) => const StatsPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/booking',
      builder: (context, state) {
        final lookId = state.uri.queryParameters['lookId'];
        return BlocProvider(
          create: (_) => sl<BookingBloc>(),
          child: BookingPage(lookId: lookId),
        );
      },
    ),
    GoRoute(
      path: '/booking/history',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<BookingBloc>(),
        child: const BookingHistoryPage(),
      ),
    ),
    GoRoute(
      path: '/my-booking',
      builder: (context, state) => const MyBookingPage(),
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
      path: '/lookbook/:lookId',
      builder: (context, state) {
        final lookId = state.pathParameters['lookId']!;
        return LookDetailPage(lookId: lookId);
      },
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesPage(),
    ),
    GoRoute(
      path: '/upload-look',
      builder: (context, state) => const UploadLookPage(),
    ),
    GoRoute(
      path: '/admin/create-salon',
      builder: (context, state) => const CreateSalonPage(),
    ),
    GoRoute(
      path: '/seed',
      builder: (context, state) => const SeedDataPage(),
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
