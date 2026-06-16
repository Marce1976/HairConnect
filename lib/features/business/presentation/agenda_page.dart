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

  /// Parsea una fecha en formato "dd/mm/aaaa".
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

  /// Agrupa reservas por fecha normalizada.
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

  /// Devuelve las reservas para un día concreto.
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
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Actualizar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusOption(
              icon: Icons.check_circle,
              color: Colors.green,
              label: 'Confirmada',
              onTap: () async {
                await _repository.updateBookingStatus(
                  bookingId: bookingId,
                  status: 'confirmed',
                  userId: booking['userId'] ?? '',
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            _StatusOption(
              icon: Icons.schedule,
              color: Colors.orange,
              label: 'Pendiente',
              onTap: () async {
                await _repository.updateBookingStatus(
                  bookingId: bookingId,
                  status: 'pending',
                  userId: booking['userId'] ?? '',
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            _StatusOption(
              icon: Icons.cancel,
              color: Colors.red,
              label: 'Cancelada',
              onTap: () async {
                await _repository.updateBookingStatus(
                  bookingId: bookingId,
                  status: 'canceled',
                  userId: booking['userId'] ?? '',
                );
                if (ctx.mounted) Navigator.pop(ctx);
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

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmada';
      case 'pending':
        return 'Pendiente';
      case 'canceled':
        return 'Cancelada';
      default:
        return status;
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: AppColors.textGrey),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar la agenda',
                    style:
                        TextStyle(fontSize: 16, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textGrey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final bookingsByDate =
            snapshot.hasData && snapshot.data!.docs.isNotEmpty
                ? _groupBookingsByDate(snapshot.data!.docs)
                : <DateTime,
                    List<MapEntry<String, Map<String, dynamic>>>>{};

        final dayBookings =
            _getBookingsForDay(_selectedDay, bookingsByDate);

        final todayStr =
            '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}';
        final isToday = _selectedDay.day == DateTime.now().day &&
            _selectedDay.month == DateTime.now().month &&
            _selectedDay.year == DateTime.now().year;

        return Column(
          children: [
            // ── Calendario ──
            Card(
              margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              elevation: 2,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: TableCalendar<MapEntry<String, Map<String, dynamic>>>(
                firstDay:
                    DateTime.now().subtract(const Duration(days: 30)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
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
                  formatButtonDecoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  formatButtonTextStyle: TextStyle(color: Colors.white),
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
                  markerDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                eventLoader: (day) {
                  final normalized =
                      DateTime(day.year, day.month, day.day);
                  return bookingsByDate[normalized] ?? [];
                },
              ),
            ),
            const SizedBox(height: 8),

            // ── Cabecera del día ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    isToday ? 'Hoy' : todayStr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${dayBookings.length} reserva${dayBookings.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Lista de reservas ──
            Expanded(
              child: dayBookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy,
                              size: 48, color: AppColors.textGrey.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text(
                            isToday
                                ? 'No hay reservas para hoy'
                                : 'No hay reservas para este día',
                            style: TextStyle(color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: dayBookings.length,
                      itemBuilder: (context, index) {
                        final entry = dayBookings[index];
                        final bookingId = entry.key;
                        final booking = entry.value;
                        final status = booking['status'] ?? 'pending';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 1,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _showStatusUpdateDialog(
                              bookingId,
                              status,
                              booking,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  // Avatar con hora
                                  CircleAvatar(
                                    backgroundColor: _getStatusColor(status)
                                        .withValues(alpha: 0.15),
                                    radius: 26,
                                    child: Text(
                                      booking['time'] ?? '--',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(status),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          booking['service'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        if (booking['stylist'] != null)
                                          Text(
                                            '${booking['stylist']}',
                                            style: TextStyle(
                                              color: AppColors.textGrey,
                                              fontSize: 13,
                                            ),
                                          ),
                                        if (booking['salonName'] != null &&
                                            (booking['salonName'] as String)
                                                .isNotEmpty)
                                          Text(
                                            booking['salonName'],
                                            style: TextStyle(
                                              color: AppColors.textGrey,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Badge de estado
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status)
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _statusLabel(status),
                                      style: TextStyle(
                                        color: _getStatusColor(status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
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

// ──────────────────────────────────────────────────────────────
// Opción de estado en el diálogo de actualización
// ──────────────────────────────────────────────────────────────
class _StatusOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _StatusOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
