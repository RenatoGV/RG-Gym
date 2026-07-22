import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/history_workout.dart';

class HistoryItem extends StatelessWidget {
  final HistoryWorkout historyWorkout;

  const HistoryItem({
    super.key,
    required this.historyWorkout
  });

  @override
  Widget build(BuildContext context) {
    final historyMonth = DateFormat('MMM', 'es_ES').format(historyWorkout.date);

    return Row(
      crossAxisAlignment: .center,
      children: [
        Padding(
          padding: .symmetric(horizontal: 10),
          child: Column(
            children: [
              Text(historyWorkout.date.day.toString(), style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: .bold)),
              Text(historyMonth, style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: .bold)),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                historyWorkout.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                historyWorkout.musclesWorkedString,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.text
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(
            context,
            '/history',
            arguments: historyWorkout,
          ),
          icon: Icon(Icons.navigate_next_rounded, color: AppColors.text),
        )
      ],
    );
  }
}