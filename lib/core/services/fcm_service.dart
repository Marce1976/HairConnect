import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  final FirebaseMessaging _fcm;
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  FcmService({
    FirebaseMessaging? firebaseMessaging,
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _fcm = firebaseMessaging ?? FirebaseMessaging.instance,
        _db = firestore ?? FirebaseFirestore.instance,
        _auth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> init() async {
    try {
      // Solicitar permiso para notificaciones
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('FCM: Permiso de notificaciones denegado');
        return;
      }

      // Obtener y guardar el token
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
