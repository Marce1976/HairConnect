part of 'booking_bloc.dart';

@immutable
sealed class BookingEvent {}

final class ConfirmLookBooking extends BookingEvent {
  final String lookId;
  final String salonId;
  final String salonName;
  final String stylistName;
  final List<String> services;
  final String price;
  final String date;
  final String time;

  ConfirmLookBooking({
    required this.lookId,
    required this.salonId,
    required this.salonName,
    required this.stylistName,
    required this.services,
    required this.price,
    required this.date,
    required this.time,
  });
}

final class CancelBooking extends BookingEvent {
  final String bookingId;
  final String businessId;

  CancelBooking({required this.bookingId, required this.businessId});
}

final class LoadBookingHistory extends BookingEvent {}
