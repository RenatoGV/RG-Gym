import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/helpers/statistics_calculator.dart';
import 'package:rg_gym/screens/tabs/exercises/tabs/statistics_tab.dart';

class PersonalRecords extends StatelessWidget {
  final ExerciseRecords records;
  
  const PersonalRecords({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Récords personales",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.backgroundSecondary,
              width: 2
            )
          ),
          child: Column(
            children: [
              _recordTile(
                title: "Mejor volumen",
                type: StatisticType.volume,
              ),

              const Divider(height: 1, color: AppColors.backgroundSecondary),

              _recordTile(
                title: "Mejor 1RM",
                type: StatisticType.oneRm,
              ),

              const Divider(height: 1, color: AppColors.backgroundSecondary),

              _recordTile(
                title: "Mayor carga",
                type: StatisticType.weight,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _recordTile({required String title, required StatisticType type}) {
    final record = records.get(type);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _format(record.value, type),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primary
                ),
              ),

              const SizedBox(height: 2),

              Text(
                DateFormat("dd MMM yyyy", "es").format(record.date),
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _format(double value, StatisticType type) {
    switch (type) {
      case StatisticType.volume:
        return "${value.toStringAsFixed(0)} kg";

      case StatisticType.weight:
        return "${value.toStringAsFixed(1)} kg";

      case StatisticType.oneRm:
        return "${value.toStringAsFixed(1)} kg";

      case StatisticType.reps:
        return "${value.toInt()} reps";
    }
  }
}