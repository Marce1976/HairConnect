import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hair_connect/features/booking/data/booking_service.dart';
import 'package:hair_connect/features/booking/domain/booking.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/services/notification_service.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingService _bookingService;
  final BusinessRepository _businessRepository;

  // TODO: Obtener businessId del contexto real (negocio logueado)
  static const String _defaultBusinessId = 'business_hairconnect';

  BookingBloc({BookingService? bookingService, BusinessRepository? businessRepository})
      : _bookingService = bookingService ?? sl<BookingService>(),
        _businessRepository = businessRepository ?? sl<BusinessRepository>(),
        super(BookingInitial()) {
    on<LoadBookingData>(_onLoadBookingData);
    on<SelectService>(_onSelectService);
    on<SelectStylist>(_onSelectStylist);
    on<SelectDate>(_onSelectDate);
    on<SelectTime>(_onSelectTime);
    on<ConfirmBooking>(_onConfirmBooking);
    on<ConfirmLookBooking>(_onConfirmLookBooking);
    on<CancelBooking>(_onCancelBooking);
    on<LoadBookingHistory>(_onLoadBookingHistory);
  }

  Future<void> _onLoadBookingData(
    LoadBookingData event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final servicesSnapshot = await _businessRepository.getServices().first;
      final stylistsSnapshot = await _businessRepository.getStylists().first;

      final services = servicesSnapshot.docs
          .map((doc) => (doc['name'] as String))
          .toList();
      final stylists = stylistsSnapshot.docs
          .map((doc) => (doc['name'] as String))
          .toList();

      emit(BookingDataLoaded(
        services: services,
        stylists: stylists,
      ));
    } catch (e) {
      emit(BookingError('Error al cargar datos: $e'));
    }
  }

  void _onSelectService(
    SelectService event,
    Emitter<BookingState> emit,
  ) {
    final currentState = state;
    if (currentState is BookingDataLoaded) {
      emit(currentState.copyWith(selectedService: event.service));
    }
  }

  void _onSelectStylist(
    SelectStylist event,
    Emitter<BookingState> emit,
  ) {
    final currentState = state;
    if (currentState is BookingDataLoaded) {
      emit(currentState.copyWith(selectedStylist: event.stylist));
    }
  }

  void _onSelectDate(
    SelectDate event,
    Emitter<BookingState> emit,
  ) {
    final currentState = state;
    if (currentState is BookingDataLoaded) {
      emit(currentState.copyWith(selectedDate: event.date));
    }
  }

  void _onSelectTime(
    SelectTime event,
    Emitter<BookingState> emit,
  ) {
    final currentState = state;
    if (currentState is BookingDataLoaded) {
      emit(currentState.copyWith(
        selectedTime: event.time.isEmpty ? null : event.time,
      ));
    }
  }

  Future<void> _onConfirmBooking(
    ConfirmBooking event,
    Emitter<BookingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BookingDataLoaded) return;

    if (currentState.selectedService == null ||
        currentState.selectedDate == null ||
        currentState.selectedTime == null ||
        currentState.selectedStylist == null) {
      emit(BookingError(
        'Por favor, completa todos los pasos para confirmar tu reserva.',
      ));
      return;
    }

    emit(BookingLoading());
    try {
      final success = await _bookingService.saveBooking(
        service: currentState.selectedService!,
        date: currentState.selectedDate!,
        time: currentState.selectedTime!,
        stylist: currentState.selectedStylist!,
        businessId: _defaultBusinessId,
        lookId: event.lookId,
      );
      if (success) {
        emit(BookingConfirmed());
      } else {
        emit(BookingError('Error al confirmar la reserva. Inténtalo de nuevo.'));
      }
    } catch (e) {
      emit(BookingError('Error inesperado: $e'));
    }
  }

  Future<void> _onConfirmLookBooking(
    ConfirmLookBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final success = await _bookingService.saveBooking(
        service: event.services.join(', '),
        date: event.date,
        time: event.time,
        stylist: event.stylistName,
        businessId: _defaultBusinessId,
        lookId: event.lookId,
        salonName: event.salonName,
        services: event.services,
        price: event.price,
        status: 'confirmed',
      );
      if (success) {
        // Notificación in-app
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final notificationService = sl<NotificationService>();
          await notificationService.sendNotification(
            userId: user.uid,
            title: 'Reserva confirmada',
            message: 'Tu cita en ${event.salonName} con ${event.stylistName} el ${event.date} a las ${event.time} ha sido confirmada.',
          );
        }
        emit(BookingLookConfirmed(
          salonName: event.salonName,
          stylistName: event.stylistName,
          date: event.date,
          time: event.time,
          price: event.price,
        ));
      } else {
        emit(BookingError('Error al confirmar la reserva. Inténtalo de nuevo.'));
      }
    } catch (e) {
      emit(BookingError('Error inesperado: $e'));
    }
  }

  Future<void> _onCancelBooking(
    CancelBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      await _businessRepository.updateBookingStatus(
        bookingId: event.bookingId,
        status: 'canceled',
        userId: event.businessId,
      );
      emit(BookingCancelled());
    } catch (e) {
      emit(BookingError('Error al cancelar la reserva: $e'));
    }
  }

  Future<void> _onLoadBookingHistory(
    LoadBookingHistory event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(BookingError('Usuario no autenticado'));
        return;
      }
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .get();
      final bookings = snapshot.docs
          .map((doc) => Booking.fromMap(doc.id, doc.data()))
          .toList();
      emit(BookingHistoryLoaded(bookings));
    } catch (e) {
      emit(BookingError('Error al cargar historial: $e'));
    }
  }
}
