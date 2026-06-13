part of 'booking_bloc.dart';

@immutable
sealed class BookingState {}

final class BookingInitial extends BookingState {}

final class BookingLoading extends BookingState {}

final class BookingHistoryLoaded extends BookingState {
  final List<Booking> bookings;

  BookingHistoryLoaded(this.bookings);
}

final class BookingLookConfirmed extends BookingState {
  final String salonName;
  final String stylistName;
  final String date;
  final String time;
  final String price;

  BookingLookConfirmed({
    required this.salonName,
    required this.stylistName,
    required this.date,
    required this.time,
    required this.price,
  });
}

final class BookingCancelled extends BookingState {}

final class BookingError extends BookingState {
  final String message;

  BookingError(this.message);
}
