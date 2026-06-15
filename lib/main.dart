import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hair_connect/core/theme/app_theme.dart';
import 'package:hair_connect/core/routes/app_router.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/services/fcm_service.dart';
import 'package:hair_connect/core/services/imgbb_service.dart';
import 'package:hair_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hair_connect/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Capturar errores no controlados
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    debugPrint('💥 CRASH REPORT: ${details.exception}');
    if (details.stack != null) {
      debugPrint('💥 CRASH STACK: ${details.stack}');
    }
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await initDependencies();
    await sl<FcmService>().init();
    // API Key de ImgBB para subida de imágenes desde galería.
    // Si migras a Cloudinary o Firebase Storage, cambia esta línea.
    ImgbbService.instance.init('5d979b30f2b1491bb0c3708c9fb4a7ed');
  } catch (e, stack) {
    debugPrint('💥 INIT ERROR: $e');
    debugPrint('💥 INIT STACK: $stack');
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
      ],
      child: const MyApp(),
    ),
  );

  // Conectar FCM al router después de que la app esté montada
  WidgetsBinding.instance.addPostFrameCallback((_) {
    sl<FcmService>().attachRouter(appRouter);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HairConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
