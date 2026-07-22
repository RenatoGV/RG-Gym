import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/providers/history_provider.dart';
import 'package:rg_gym/screens/tabs/stats/widgets/history_item.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>().history;

    final selectedHistory = history.where((h) => isSameDay(h.date, _selectedDay)).toList();

    final historyDays = history.map((h) => DateTime(h.date.year, h.date.month, h.date.day)).toSet();

    return Padding(
        padding: .symmetric(horizontal: 20),
        child: Column(
        crossAxisAlignment: .start,
        children: [
          TableCalendar(
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final hasHistory = historyDays.contains(DateTime(day.year, day.month, day.day));

                if(!hasHistory) return null;

                return Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text('${day.day}'),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                final hasHistory = historyDays.contains(DateTime(day.year, day.month, day.day));
                
                return Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.6),
                    border: hasHistory
                      ? Border.all(
                        color: AppColors.primary,
                        width: 2,
                        )
                      : null,
                  ),
                  alignment: Alignment.center,
                  child: Text('${day.day}'),
                );
              },
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: .circle
              )
            ),
            availableCalendarFormats: const { CalendarFormat.month: 'Month' },
            locale: 'es_ES',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 30),
          const Text('Historial', style: TextStyle(fontWeight: .bold)),
          const SizedBox(height: 10),

          (selectedHistory.isNotEmpty) ?
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.backgroundSecondary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10),
                  itemCount: selectedHistory.length,
                  itemBuilder: (context, index) {
                    return HistoryItem(historyWorkout: selectedHistory[index]);
                  },
                ),
              ),
            )
          : Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: .center,
                crossAxisAlignment: .center,
                children: [
                  const Icon(Icons.history, color: AppColors.text, size: 40),
                  const SizedBox(height: 10),
                  const Text(
                    'No hay historial',
                    style: TextStyle(color: AppColors.text),
                    textAlign: .center,
                  )
                ]
              )
            ),
          )
        ],
      ),
    );
  }
}