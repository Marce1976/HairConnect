import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Callback para navegar cuando el usuario toca una notificación push.
typedef FcmNavigationCallback = void Function(String path);

class FcmService {
  final FirebaseMessaging _fcm;
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  /// Callback de navegación, se asigna desde main.dart tras el runApp.
  FcmNavigationCallback? _onNavigate;

  FcmService({
    FirebaseMessaging? firebaseMessaging,
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _fcm = firebaseMessaging ?? FirebaseMessaging.instance,
        _db = firestore ?? FirebaseFirestore.instance,
        _auth = firebaseAuth ?? FirebaseAuth.instance;

  /// Inicializa el servicio: permisos, token y escucha de refresh.
  Future<void> init() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('FCM: Permiso de notificaciones denegado');
        return;
      }

      // Obtener y guardar el token inicial
      final token = await _fcm.getToken();
      if (token != null) {
        await _saveToken(token);
      }

      // Escuchar cambios del token
      _fcm.onTokenRefresh.listen(_saveToken);
    } catch (e) {
      debugPrint('FCM: Error al inicializar: $e');
    }
  }

  /// Asigna el callback de navegación y configura los listeners.
  ///
  /// Debe llamarse después de que el router esté activo (post-runApp).
  void attachRouter(GoRouter router) {
    _onNavigate = (path) => router.go(path);

    // ── Mensaje en primer plano → actualizar badge (sin snackbar) ──
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('FCM: Mensaje en primer plano: ${message.notification?.title}');
      // La notificación in-app ya se creó en Firestore, el StreamBuilder
      // de la campanita se actualizará solo al tener nuevos datos.
    });

    // ── Tap en notificación (app en background) ──
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // ── App abierta desde notificación (app terminada) ──
    _checkInitialMessage();
  }

  /// Lee el mensaje que abrió la app si venía de una notificación terminada.
  Future<void> _checkInitialMessage() async {
    try {
      final message = await _fcm.getInitialMessage();
      if (message != null) {
        _handleNotificationTap(message);
      }
    } catch (e) {
      debugPrint('FCM: Error al obtener mensaje inicial: $e');
    }
  }

  /// Navega según el tipo de notificación.
  void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'] ?? '';
    final path = _routeForType(type);
    debugPrint('FCM: Tap en notificación type=$type → $path');
    _onNavigate?.call(path);
  }

  /// Mapea el type de la notificación a una ruta de GoRouter.
  String _routeForType(String type) {
    switch (type) {
      case 'booking_confirmed':
        return '/my-booking';
      case 'new_booking':
      case 'in_app_notification':
      default:
        return '/notifications';
    }
  }

  Future<void> _saveToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
    } catch (e) {
      debugPrint('FCM: Error al guardar token: $e');
    }
  }
}
