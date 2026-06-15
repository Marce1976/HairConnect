const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// ─── Helper: obtener token FCM de un usuario ──────────────────────────────

/**
 * Busca el token FCM de un usuario.
 * Primero intenta en users/{userId}.fcmToken.
 * Si no existe, busca en la subcolección users/{userId}/fcm_tokens.
 * @param {string} userId
 * @returns {Promise<string|null>}
 */
async function getFcmToken(userId) {
  try {
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(userId)
      .get();

    const fcmToken = userDoc.data()?.fcmToken;
    if (fcmToken) return fcmToken;

    // Fallback: subcolección fcm_tokens
    const tokensSnap = await admin.firestore()
      .collection('users')
      .doc(userId)
      .collection('fcm_tokens')
      .get();

    for (const doc of tokensSnap.docs) {
      const token = doc.data()?.token;
      if (token) return token;
    }

    return null;
  } catch (error) {
    console.error(`Error getting FCM token for user ${userId}:`, error);
    return null;
  }
}

// ─── 1. Notificaciones in-app → push ──────────────────────────────────────

/**
 * Se dispara cuando se crea un documento en notifications.
 * Envía un push FCM al usuario destinatario.
 */
exports.onNotificationCreated = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    const userId = notification?.userId;
    const title = notification?.title || 'Nueva notificación';
    const body = notification?.message || '';

    if (!userId) {
      console.log('onNotificationCreated: sin userId, se omite');
      return null;
    }

    try {
      const fcmToken = await getFcmToken(userId);
      if (!fcmToken) {
        console.log(`onNotificationCreated: sin token para user ${userId}`);
        return null;
      }

      const message = {
        notification: { title, body },
        data: {
          type: 'in_app_notification',
          notificationId: context.params.notificationId,
        },
        token: fcmToken,
      };

      await admin.messaging().send(message);
      console.log(`Push enviado a user ${userId}: "${title}"`);
    } catch (error) {
      console.error('Error en onNotificationCreated:', error);
    }

    return null;
  });

// ─── 2. Booking creado → push al cliente y al dueño ───────────────────────

/**
 * Se dispara cuando se crea un documento en bookings.
 * Si la reserva está confirmada, envía push al cliente y al dueño del salón.
 */
exports.onBookingCreated = functions.firestore
  .document('bookings/{bookingId}')
  .onCreate(async (snap, context) => {
    const booking = snap.data();

    // Solo enviar notificación si está confirmada
    if (booking.status !== 'confirmed') return null;

    const salonName = booking.salonName || 'la peluquería';
    const date = booking.date || '';
    const time = booking.time || '';
    const stylist = booking.stylist || '';
    const bookingId = context.params.bookingId;

    // ── Notificar al cliente ──
    try {
      const clientToken = await getFcmToken(booking.userId);
      if (clientToken) {
        const clientMessage = {
          notification: {
            title: '¡Reserva confirmada!',
            body: `Tu cita en ${salonName} con ${stylist} el ${date} a las ${time} está confirmada.`,
          },
          data: {
            type: 'booking_confirmed',
            bookingId,
            salonName,
          },
          token: clientToken,
        };
        await admin.messaging().send(clientMessage);
        console.log('Push enviado al cliente', booking.userId);
      }
    } catch (error) {
      console.error('Error notificando al cliente:', error);
    }

    // ── Notificar al dueño del salón ──
    try {
      const salonId = booking.salonId;
      if (!salonId) {
        console.log('Booking sin salonId');
        return null;
      }

      const salonDoc = await admin.firestore()
        .collection('salons')
        .doc(salonId)
        .get();

      const ownerId = salonDoc.data()?.ownerId;
      if (!ownerId) {
        console.log(`Salón ${salonId} sin ownerId`);
        return null;
      }

      const servicesLabel = Array.isArray(booking.services)
        ? booking.services.join(', ')
        : (booking.services || 'Servicio');

      const userName = booking.userName || booking.userEmail || 'Un cliente';

      // Notificación in-app para el dueño
      await admin.firestore().collection('notifications').add({
        userId: ownerId,
        title: 'Nueva reserva',
        message: `${userName} reservó ${servicesLabel} en ${salonName} para el ${date} a las ${time}.`,
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Push al dueño
      const ownerToken = await getFcmToken(ownerId);
      if (ownerToken) {
        const ownerMessage = {
          notification: {
            title: 'Nueva reserva',
            body: `${userName} reservó ${servicesLabel} el ${date} a las ${time}.`,
          },
          data: {
            type: 'new_booking',
            bookingId,
            salonId,
          },
          token: ownerToken,
        };
        await admin.messaging().send(ownerMessage);
        console.log('Push enviado al dueño', ownerId);
      }
    } catch (error) {
      console.error('Error notificando al dueño:', error);
    }

    return null;
  });
