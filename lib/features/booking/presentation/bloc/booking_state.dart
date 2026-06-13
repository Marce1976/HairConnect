part of 'booking_bloc.dart';

@immutable
sealed class BookingState {}

final class BookingInitial extends BookingState {}

final class BookingLoading extends BookingState {}

final class BookingDataLoaded extends BookingState {
  final List<String> services;
  final List<String> stylists;
  final String? selectedService;
  final String? selectedStylist;
  final String? selectedDate;
  final String? selectedTime;

  BookingDataLoaded({
    required this.services,
    required this.stylists,
    this.selectedService,
    this.selectedStylist,
    this.selectedDate,
    this.selectedTime,
  });

  BookingDataLoaded copyWith({
    List<String>? services,
    List<String>? stylists,
    String? selectedService,
    String? selectedStylist,
    String? selectedDate,
    String? selectedTime,
  }) {
    return BookingDataLoaded(
      services: services ?? this.services,
      stylists: stylists ?? this.stylists,
      selectedService: selectedService ?? this.selectedService,
      selectedStylist: selectedStylist ?? this.selectedStylist,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
    );
  }
}

final class BookingHistoryLoaded extends BookingState {
  final List<Booking> bookings;

  BookingHistoryLoaded(this.bookings);
}

final class BookingConfirmed extends BookingState {}

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
