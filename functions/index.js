const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

/**
 * Se dispara cuando se crea un documento en bookings.
 * Si la reserva está confirmada, envía una notificación push al usuario.
 */
exports.onBookingCreated = functions.firestore
  .document('bookings/{bookingId}')
  .onCreate(async (snap, context) => {
    const booking = snap.data();

    // Solo enviar notificación si está confirmada
    if (booking.status !== 'confirmed') return null;

    try {
      // Obtener el token FCM del usuario
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(booking.userId)
        .get();

      const fcmToken = userDoc.data()?.fcmToken;
      if (!fcmToken) {
        console.log('No FCM token found for user', booking.userId);
        return null;
      }

      const salonName = booking.salonName || 'la peluquería';
      const date = booking.date || '';
      const time = booking.time || '';
      const stylist = booking.stylist || '';

      const message = {
        notification: {
          title: '¡Reserva confirmada!',
          body: `Tu cita en ${salonName} con ${stylist} el ${date} a las ${time} está confirmada.`,
        },
        data: {
          type: 'booking_confirmed',
          bookingId: context.params.bookingId,
          salonName,
        },
        token: fcmToken,
      };

      await admin.messaging().send(message);
      console.log('Push notification sent to user', booking.userId);
    } catch (error) {
      console.error('Error sending push notification:', error);
    }

    return null;
  });
