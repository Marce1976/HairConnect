import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hair_connect/features/auth/data/auth_service.dart';
import 'package:hair_connect/features/auth/data/user_service.dart';
import 'package:hair_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hair_connect/features/booking/data/booking_service.dart';
import 'package:hair_connect/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';
import 'package:hair_connect/core/services/notification_service.dart';
import 'package:hair_connect/core/services/storage_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Services
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<UserService>(() => UserService());
  sl.registerLazySingleton<BookingService>(() => BookingService());
  sl.registerLazySingleton<BusinessRepository>(() => BusinessRepository());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<StorageService>(() => StorageService());

  // BLoCs
  sl.registerFactory<AuthBloc>(() => AuthBloc());
  sl.registerFactory<BookingBloc>(() => BookingBloc());
}
