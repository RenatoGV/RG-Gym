import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/history_workout.dart';
import 'package:rg_gym/providers/history_provider.dart';
import 'package:rg_gym/screens/tabs/stats/widgets/history_item.dart';

class HistoryTab extends StatelessWidget {
  final int exerciseId;

  const HistoryTab({
    super.key,
    required this.exerciseId
  });

  @override
  Widget build(BuildContext context) {
    final historyByExercise = context.watch<HistoryProvider>().getHistoryByExercise(exerciseId);

    final groupedHistory = <String, List<HistoryWorkout>>{};

    for (final history in historyByExercise) {
      final key = DateFormat('yyyy-MM').format(history.date);

      groupedHistory.putIfAbsent(key, () => []).add(history);
    }
    
    return Center(
      child: Column(
        children: [
          (historyByExercise.isNotEmpty) ?
            Column(
              children: groupedHistory.entries.map((entry) {
                final monthTitle = DateFormat('MMMM yyyy','es').format(entry.value.first.date);

                return Column(
                  children: [
                    Text(
                      toBeginningOfSentenceCase(monthTitle)!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 15),

                    Container(
                      width: .infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.backgroundSecondary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: .stretch,
                        children: List.generate(entry.value.length, (index) {
                          return Column(
                            children: [
                              HistoryItem(historyWorkout: entry.value[index]),

                              if (index != entry.value.length - 1)
                                const Divider(color: AppColors.backgroundSecondary, thickness: 3, radius: BorderRadius.all(Radius.circular(2)),),
                            ],
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                );
              }).toList(),
            ) :
            Column(
              children: [
                SizedBox(height: 50),
                Icon(
                  Icons.history,
                  color: AppColors.text,
                  size: 40,
                ),
                SizedBox(height: 10),
                Text(
                  'No hay historial',
                  style: TextStyle(color: AppColors.text),
                ),
              ],
            )
        ],
      ),
    );
  }
}