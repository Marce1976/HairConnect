import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/features/business/data/business_repository.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final BusinessRepository _repository = sl<BusinessRepository>();
  CalendarFormat _format = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  /// Parses a date string in "dd/mm/aaaa" format into a [DateTime].
  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  /// Groups booking documents by their normalized date, preserving the
  /// document id so it can be used later in status update dialogs.
  Map<DateTime, List<MapEntry<String, Map<String, dynamic>>>>
      _groupBookingsByDate(List<QueryDocumentSnapshot> docs) {
    final map = <DateTime,
        List<MapEntry<String, Map<String, dynamic>>>>{};
    for (final doc in docs) {
      final booking = doc.data() as Map<String, dynamic>;
      final dateStr = booking['date'] as String? ?? '';
      final date = _parseDate(dateStr);
      if (date != null) {
        final normalized = DateTime(date.year, date.month, date.day);
        map.putIfAbsent(normalized, () => []);
        map[normalized]!.add(MapEntry(doc.id, booking));
      }
    }
    return map;
  }

  /// Returns the list of (docId, data) entries for the given day.
  List<MapEntry<String, Map<String, dynamic>>> _getBookingsForDay(
    DateTime day,
    Map<DateTime, List<MapEntry<String, Map<String, dynamic>>>>
        bookingsByDate,
  ) {
    final normalized = DateTime(day.year, day.month, day.day);
    return bookingsByDate[normalized] ?? [];
  }

  void _showStatusUpdateDialog(
    String bookingId,
    String currentStatus,
    Map<String, dynamic> booking,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Confirmada'),
              leading: const Icon(Icons.check_circle, color: Colors.green),
              onTap: () async {
                await _repository.updateBookingStatus(
                  bookingId: bookingId,
                  status: 'confirmed',
                  userId: booking['userId'] ?? '',
                );
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Pendiente'),
              leading: const Icon(Icons.pending, color: Colors.orange),
              onTap: () async {
                await _repository.updateBookingStatus(
                  bookingId: bookingId,
                  status: 'pending',
                  userId: booking['userId'] ?? '',
                );
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Cancelada'),
              leading: const Icon(Icons.cancel, color: Colors.red),
              onTap: () async {
                await _repository.updateBookingStatus(
                  bookingId: bookingId,
                  status: 'canceled',
                  userId: booking['userId'] ?? '',
                );
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _repository.getBookings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar la agenda'));
        }

        final bookingsByDate =
            snapshot.hasData && snapshot.data!.docs.isNotEmpty
                ? _groupBookingsByDate(snapshot.data!.docs)
                : <DateTime,
                    List<MapEntry<String, Map<String, dynamic>>>>{};

        final dayBookings =
            _getBookingsForDay(_selectedDay, bookingsByDate);

        return Column(
          children: [
            // ── Calendario visual ──────────────────────────────────
            TableCalendar<MapEntry<String, Map<String, dynamic>>>(
              firstDay:
                  DateTime.now().subtract(const Duration(days: 30)),
              lastDay:
                  DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _format,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) =>
                  isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() => _format = format);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
              ),
              eventLoader: (day) {
                final normalized =
                    DateTime(day.year, day.month, day.day);
                return bookingsByDate[normalized] ?? [];
              },
            ),
            const Divider(height: 1),
            // ── Lista de reservas del día seleccionado ────────────
            Expanded(
              child: dayBookings.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay reservas para este día',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: dayBookings.length,
                      itemBuilder: (context, index) {
                        final entry = dayBookings[index];
                        final bookingId = entry.key;
                        final booking = entry.value;
                        return GestureDetector(
                          onTap: () =>
                              _showStatusUpdateDialog(
                                bookingId,
                                booking['status'] ?? 'pending',
                                booking,
                              ),
                          child: Card(
                            margin:
                                const EdgeInsets.only(bottom: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.person,
                                    color: Colors.white, size: 20),
                              ),
                              title: Text(
                                booking['service'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${booking['date'] ?? ''} a las ${booking['time'] ?? ''}'
                                '${booking['stylist'] != null ? ' con ${booking['stylist']}' : ''}',
                                style: const TextStyle(
                                    color: AppColors.textGrey),
                              ),
                              trailing: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    booking['status'] ?? 'pending',
                                  ).withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  booking['status'] ?? 'Pendiente',
                                  style: TextStyle(
                                    color: _getStatusColor(
                                        booking['status'] ??
                                            'pending'),
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
