import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/helpers/format_helper.dart';
import 'package:rg_gym/models/history_workout.dart';
import 'package:rg_gym/screens/tabs/stats/widgets/stats_bottom_sheet.dart';

class ComparisonData {
  final List<HistoryWorkout> current;
  final List<HistoryWorkout> previous;

  final DateTime currentStart;
  final DateTime currentEnd;

  final DateTime previousStart;
  final DateTime previousEnd;

  const ComparisonData({
    required this.current,
    required this.previous,
    required this.currentStart,
    required this.currentEnd,
    required this.previousStart,
    required this.previousEnd,
  });
}

class ComparisonSection extends StatelessWidget {
  final List<HistoryWorkout> history;
  final FilterDays filter;
  final StatType type;

  const ComparisonSection({
    super.key,
    required this.history,
    required this.filter,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final comparison = _getComparison();

    final current = _getStatValue(comparison.current);
    final previous = _getStatValue(comparison.previous);

    final maxValue = math.max(current, previous);

    final currentFactor = maxValue == 0 ? 0.0 : current / maxValue;
    final previousFactor = maxValue == 0 ? 0.0 : previous / maxValue;

    final difference = current - previous;

    return Column(
      children: [
        _comparisonRow(
          label: _formatPeriod(comparison.currentStart, comparison.currentEnd),
          factor: currentFactor,
          value: current,
          difference: difference
        ),

        const SizedBox(height: 6),

        _comparisonRow(
          label: _formatPeriod(
            comparison.previousStart,
            comparison.previousEnd,
          ),
          factor: previousFactor,
          value: previous,
        ),
      ],
    );
  }

  Widget _comparisonRow({
    required String label,
    required double factor,
    required double value,
    double? difference
  }) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(color: AppColors.text, fontSize: 12),
          ),
        ),
        Container(
          width: 100,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            widthFactor: factor,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),

        SizedBox(width: 8),

        Text('${_formatValue(value)} ${_unit()}', style: TextStyle(fontSize: 12)),
        if (difference != null) ...[
          const SizedBox(width: 10),
          Text(
            '(${difference > 0 ? '+' : ''}${_formatValue(difference.abs())})',
            style: TextStyle(
              fontSize: 12,
              color: difference > 0
                  ? Colors.green
                  : difference < 0
                      ? Colors.red
                      : AppColors.text,
            ),
          ),
        ],
      ],
    );
  }

  ComparisonData _getComparison() {
    final now = DateTime.now();

    final days = switch (filter) {
      FilterDays.seven => 7,
      FilterDays.fourteen => 14,
      FilterDays.twentyEight => 28,
      FilterDays.ninety => 90,
    };

    final today = DateTime(now.year, now.month, now.day);


    final currentStart = today.subtract(Duration(days: days - 1));
    final previousStart = currentStart.subtract(Duration(days: days));
    final previousEnd = currentStart.subtract(const Duration(days: 1));

    final current = history.where((e) {
      final date = DateTime(e.date.year, e.date.month, e.date.day);

      return !date.isBefore(currentStart) &&
          !date.isAfter(today);
    }).toList();

    final previous = history.where((e) {
      final date = DateTime(e.date.year, e.date.month, e.date.day);

      return !date.isBefore(previousStart) &&
          !date.isAfter(previousEnd);
    }).toList();

    return ComparisonData(
      current: current,
      previous: previous,
      currentStart: currentStart,
      currentEnd: today,
      previousStart: previousStart,
      previousEnd: previousEnd,
    );
  }

  double _getStatValue(List<HistoryWorkout> workouts) {
    switch(type) {
      case .duration:
        return workouts.fold<Duration>(
          Duration.zero,
          (sum, h) => sum + h.totalDuration,
        ).inMinutes.toDouble();

      case .calories:
        return workouts
            .expand((e) => e.completedExercises)
            .expand((e) => e.sets)
            .fold<double>(
              0,
              (sum, set) => sum + (set.reps ?? 0),
            );

      case .exercises:
        return workouts.fold(
          0.0,
          (sum, h) => sum + h.completedExercises.length,
        );

      case .sets:
        return workouts.fold(
          0.0,
          (sum, h) => sum + h.completedSets,
        );

      case .reps:
        return workouts.fold(
          0.0,
          (sum, h) => sum + h.completedReps,
        );

      case .weight:
        return workouts.fold(
          0.0,
          (sum, h) => sum + h.totalWeight,
        );
    }
  }

  String _formatPeriod(DateTime start, DateTime end) {
    return '${start.day} ${DateFormat.MMM('es').format(start)} - '
      '${end.day} ${DateFormat.MMM('es').format(end)}';
  }

  String _formatValue(double value) {
    if(value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return FormatHelper.formatDouble(value);
  }

  String _unit() {
    return switch(type){
      .duration => 'min',
      .calories => 'kcal',
      .exercises => 'ejercicios',
      .sets => 'series',
      .reps => 'reps',
      .weight => 'kg',
    };
  }
}