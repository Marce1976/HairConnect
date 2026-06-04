part of 'booking_bloc.dart';

@immutable
sealed class BookingEvent {}

final class LoadBookingData extends BookingEvent {}

final class SelectService extends BookingEvent {
  final String service;

  SelectService(this.service);
}

final class SelectStylist extends BookingEvent {
  final String stylist;

  SelectStylist(this.stylist);
}

final class SelectDate extends BookingEvent {
  final String date;

  SelectDate(this.date);
}

final class SelectTime extends BookingEvent {
  final String time;

  SelectTime(this.time);
}

final class ConfirmBooking extends BookingEvent {}

final class CancelBooking extends BookingEvent {
  final String bookingId;
  final String businessId;

  CancelBooking({required this.bookingId, required this.businessId});
}

final class LoadBookingHistory extends BookingEvent {}
