import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/helpers/format_helper.dart';
import 'package:rg_gym/models/chart_data.dart';
import 'package:rg_gym/models/history_workout.dart';
import 'package:rg_gym/providers/history_provider.dart';
import 'package:rg_gym/screens/tabs/stats/widgets/comparison_section.dart';

enum FilterDays {
  seven,
  fourteen,
  twentyEight,
  ninety
}

enum TabPosition {
  right,
  center,
  left
}

enum StatType {
  duration,
  calories,
  exercises,
  sets,
  reps,
  weight
}

class StatConfig {
  final String title;
  final String subtitle;
  final String label;

  const StatConfig({
    required this.title,
    required this.subtitle,
    required this.label
  });
}

const configs = {
  StatType.duration: StatConfig(
    title: 'Duración del ejercicio',
    subtitle: 'Minutos del ejercicio',
    label: 'minutos ejercitándote',
  ),
  StatType.calories: StatConfig(
    title: 'Calorías',
    subtitle: 'Calorías quemadas',
    label: 'kcal quemadas',
  ),
  StatType.exercises: StatConfig(
    title: 'Ejercicios',
    subtitle: 'Número de ejercicios',
    label: 'ejercicios completados',
  ),
  StatType.sets: StatConfig(
    title: 'Series',
    subtitle: 'Núermo de series',
    label: 'series completadas',
  ),
  StatType.reps: StatConfig(
    title: 'Repeticiones',
    subtitle: 'Número de repeticiones',
    label: 'repeticiones completadas',
  ),
  StatType.weight: StatConfig(
    title: 'Peso',
    subtitle: 'Total de peso',
    label: 'kg del total de peso',
  ),
};

class StatsBottomSheet extends StatefulWidget {
  final StatType type;

  const StatsBottomSheet({
    super.key,
    required this.type
  });

  @override
  State<StatsBottomSheet> createState() => _StatsBottomSheetState();
}

class _StatsBottomSheetState extends State<StatsBottomSheet> {
  FilterDays selectedFilter = FilterDays.seven;

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>().history;
    final config = configs[widget.type]!;
    
    List<HistoryWorkout> getByFilter() {
      final now = DateTime.now();

      return switch (selectedFilter) {
        .seven => history.where((h) {
          return now.difference(h.date).inDays < 7;
        }).toList(),
        .fourteen => history.where((h) {
          return now.difference(h.date).inDays < 14;
        }).toList(),
        .twentyEight => history.where((h) {
          return now.difference(h.date).inDays < 28;
        }).toList(),
        .ninety => history.where((h) {
          return now.difference(h.date).inDays < 90;
        }).toList(),
      };
    }
    
    String daysText(FilterDays filter) {
      return switch (filter) {
        .seven => '7 días',
        .fourteen => '14 días',
        .twentyEight => '28 días',
        .ninety => '90 días',
      };
    }

    dynamic getStatValue(List<HistoryWorkout> history) {
      switch (widget.type) {
        case .duration:
          return history.fold<Duration>(
            Duration.zero,
            (sum, h) => sum + h.totalDuration
          );

        case StatType.calories:
          return history
            .expand((h) => h.completedExercises)
            .expand((e) => e.sets)
            .fold<double>(
              0,
              (sum, set) => sum + (set.reps ?? 0),
            );

        case StatType.exercises:
          return history.fold<int>(
            0,
            (sum, h) => sum + h.completedExercises.length,
          );

        case StatType.sets:
          return history.fold<int>(
            0,
            (sum, h) => sum + h.completedSets,
          );

        case StatType.reps:
          return history.fold<int>(
            0,
            (sum, h) => sum + h.completedReps,
          );

        case StatType.weight:
          return history.fold<double>(
            0,
            (sum, h) => sum + h.totalWeight,
          );
      }
    }

    String formatValue(dynamic value) {
      switch(widget.type) {
        case StatType.duration:
          final duration = value as Duration;
          return duration.inMinutes.toString();

        case StatType.weight:
        case StatType.calories:
          return FormatHelper.formatDouble((value as num).toDouble());

        default:
          return value.toString();
      }
    }

    List<ChartData> getChartData() {
      final history = getByFilter();

      final now = DateTime.now();
      final days = switch(selectedFilter) {
        .seven => 7,
        .fourteen => 14,
        .twentyEight => 28,
        .ninety => 90,
      };

      return List.generate(days, (index) {
        final day = DateTime(
          now.year,
          now.month,
          now.day
        ).subtract((Duration(days: days - index - 1)));

        final workouts = history.where((h) =>
          h.date.year == day.year &&
          h.date.month == day.month &&
          h.date.day == day.day,
        ).toList();

        final value = getStatValue(workouts);

        return ChartData(
          date: day,
          value: switch(value) {
            Duration d => d.inMinutes.toDouble(),
            int i => i.toDouble(),
            double d => d,
            _ => 0
          }
        );
      });
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.60,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.85],
      shouldCloseOnMinExtent: true,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),

                      const SizedBox(width: 4),

                      Text(
                        config.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: .symmetric(horizontal: 20),
                    children: [
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: .circular(25)
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _tabButton(
                                title: '7 días',
                                tab: .seven,
                                position: .left
                              )
                            ),
                            Expanded(
                              child: _tabButton(
                                title: '14 días',
                                tab: .fourteen,
                                position: .center
                              )
                            ),
                            Expanded(
                              child: _tabButton(
                                title: '28 días',
                                tab: .twentyEight,
                                position: .center
                              )
                            ),
                            Expanded(
                              child: _tabButton(
                                title: '90 días',
                                tab: .ninety,
                                position: .right
                              )
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(config.subtitle, style: TextStyle(fontSize: 16, fontWeight: .w500)),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Últimos ',
                              style: TextStyle(
                                color: AppColors.primary
                              )
                            ),
                            TextSpan(
                              text: daysText(selectedFilter),
                              style: const TextStyle(
                                color: AppColors.primary,
                              ),
                            ),
                          ]
                        )
                      ),
                      const SizedBox(height: 15),
                      Text('${formatValue(getStatValue(getByFilter()))} ${config.label}', style: TextStyle(fontWeight: .w500)),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 250,
                        child: getChartData().every((e) => e.value == 0) ?
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: .center,
                            children: [
                              Icon(
                                Icons.bar_chart_sharp,
                                color: AppColors.text,
                                size: 40,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Sin datos para el gráfico',
                                style: TextStyle(color: AppColors.text),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        :
                          _buildChart(getChartData(), widget.type, selectedFilter)
                      ),

                      const SizedBox(height: 40),

                      const Text('Comparativo', style: TextStyle(fontSize: 16, fontWeight: .w500)),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Últimos ',
                              style: TextStyle(
                                color: AppColors.primary
                              )
                            ),
                            TextSpan(
                              text: daysText(selectedFilter),
                              style: const TextStyle(
                                color: AppColors.primary,
                              ),
                            ),
                            const TextSpan(
                              text: ' vs ',
                              style: TextStyle(
                                color: AppColors.primary
                              )
                            ),
                            TextSpan(
                              text: daysText(selectedFilter),
                              style: const TextStyle(
                                color: AppColors.primary,
                              ),
                            ),
                            const TextSpan(
                              text: ' anteriores',
                              style: TextStyle(
                                color: AppColors.primary
                              )
                            ),
                          ]
                        )
                      ),
                      const SizedBox(height: 15),
                      ComparisonSection(
                        history: history,
                        filter: selectedFilter,
                        type: widget.type
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _tabButton({ required String title, required FilterDays tab, required TabPosition position }) {
    final selected = selectedFilter == tab;

    BorderRadius radius = switch (position) {
      TabPosition.left => const BorderRadius.horizontal(left: Radius.circular(25)),
      TabPosition.center => BorderRadius.zero,
      TabPosition.right => const BorderRadius.horizontal(right: Radius.circular(25)),
    };

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = tab;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: .center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: radius
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.text,
            fontWeight: .w600
          ),
        ),
      ),
    );
  }
}

Widget _buildChart(List<ChartData> data, StatType type, FilterDays filter) {
  final maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  final formattedMaxY = _calculateMaxY(maxY, type);
  final interval = switch(type) {
    .exercises => 1.0,
    .sets => _calculateInterval(maxY),
    .reps => _calculateInterval(maxY),
    _ => _calculateInterval(maxY),
  };

  final labelInterval = switch(filter) {
    .seven => 1,
    .fourteen => 2,
    .twentyEight => 5,
    .ninety => 20
  };

  
  String unit() {
    return switch(type){
      .duration => 'min',
      .calories => 'kcal',
      .exercises => 'ejercicios',
      .sets => 'series',
      .reps => 'reps',
      .weight => 'kg',
    };
  }

  return Padding(
    padding: const .only(top: 10),
    child: BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBorderRadius: BorderRadius.circular(10),
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipColor: (_) => AppColors.backgroundSecondary,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${FormatHelper.formatDouble(rod.toY)} ${unit()}',
                const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        maxY: formattedMaxY,
        alignment: BarChartAlignment.spaceBetween,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white24,
              strokeWidth: 1,
              dashArray: [8, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: interval,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatAxis(value),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.round();

                if (index >= data.length || index % labelInterval != 0) {
                  return const SizedBox();
                }

                final date = data[index].date;

                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: Text(
                    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),

        barGroups: List.generate(
          data.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i].value,
                width: switch (data.length) {
                  <= 14 => 18,
                  <= 28 => 10,
                  _ => 6,
                },
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

double _calculateInterval(double maxY) {
  if (maxY <= 5) return 1;
  if (maxY <= 10) return 2;
  if (maxY <= 20) return 5;
  if (maxY <= 50) return 10;
  if (maxY <= 100) return 20;
  if (maxY <= 250) return 50;
  if (maxY <= 500) return 100;

  return (maxY / 5).ceilToDouble();
}

double _calculateMaxY(double value, StatType type) {
  if (value == 0) return 10;

  switch (type) {
    case StatType.exercises:
      return value.ceilToDouble();

    case StatType.sets:
      return _roundUp(value, 5);

    case StatType.reps:
      return _roundUp(value, 10);

    case StatType.weight:
    case StatType.calories:
    case StatType.duration:
      return _roundUp(value * 1.1, _calculateInterval(value * 1.1));
  }
}

double _roundUp(double value, double multiple) {
  return (value / multiple).ceil() * multiple;
}

String _formatAxis(double value) {
  if (value % 1 == 0) {
    return value.toInt().toString();
  }

  return FormatHelper.formatDouble(value);
}