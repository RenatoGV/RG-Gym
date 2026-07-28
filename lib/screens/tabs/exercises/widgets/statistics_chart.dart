import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/chart_data.dart';
import 'package:rg_gym/screens/tabs/exercises/tabs/statistics_tab.dart';

class StatisticsChart extends StatefulWidget {
  final List<ChartData> points;
  final double average;
  final StatisticType type;
  
  const StatisticsChart({
    super.key,
    required this.points,
    required this.average,
    required this.type,
  });

  @override
  State<StatisticsChart> createState() => _StatisticsChartState();
}

class _StatisticsChartState extends State<StatisticsChart> {
  int? selectedIndex;

  @override
  void initState() {
    super.initState();

    if(widget.points.isNotEmpty) selectedIndex = widget.points.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    final average = widget.average;
    
    if (points.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: Text("Sin datos"),
        ),
      );
    }

    final maxY = [average, ...points.map((e) => e.value)].reduce((a, b) => a > b ? a : b);
    final minY = [average, ...points.map((e) => e.value)].reduce((a, b) => a < b ? a : b);

    final lineBarData = LineChartBarData(
      spots: List.generate(
        points.length,
        (i) => FlSpot(i.toDouble(), points[i].value),
      ),
      color: AppColors.primary,
      barWidth: 3,
      isCurved: false,
      dotData: const FlDotData(show: true),
    );

    return SizedBox(
      height: 270,
      child: LineChart(
        LineChartData(
          minY: (minY * .9).clamp(0, double.infinity),
          maxY: maxY * 1.15,

          borderData: FlBorderData(show: false),

          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: (maxY / 4).ceilToDouble(),
            getDrawingHorizontalLine: (value) {
              return FlLine(color: AppColors.backgroundSecondary, strokeWidth: 1);
            },
          ),

          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                interval: (maxY / 4).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatValue(value),
                    style: const TextStyle(fontSize: 11, color: AppColors.text),
                  );
                },
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 || index >= points.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat("d MMM", "es").format(points[index].date),
                      style: const TextStyle(fontSize: 10, color: AppColors.text),
                    ),
                  );
                },
              ),
            ),
          ),

          showingTooltipIndicators: selectedIndex == null
            ? []
            : [
                ShowingTooltipIndicators([
                  LineBarSpot(
                    lineBarData,
                    0,
                    lineBarData.spots[selectedIndex!],
                  ),
                ]),
              ],

          lineTouchData: LineTouchData(
            handleBuiltInTouches: false,
            
            touchCallback: (event, response) {
              if (event is! FlTapUpEvent) return;

              final spot = response?.lineBarSpots?.first;

              setState(() {
                if (spot == null) {
                  selectedIndex = null;
                  return;
                }

                if (selectedIndex == spot.spotIndex) {
                  selectedIndex = null;
                } else {
                  selectedIndex = spot.spotIndex;
                }
              });
            },

            touchTooltipData: LineTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              tooltipBorderRadius: BorderRadius.circular(10),
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipColor: (_) => AppColors.backgroundSecondary,

              getTooltipItems: (spots) {
                return spots.map((spot) {
                  return LineTooltipItem(
                    _tooltipText(points[spot.spotIndex]),
                    const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),

            getTouchedSpotIndicator: (barData, indexes) {
              return indexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(color: AppColors.primary, strokeWidth: 1, dashArray: [4, 4]),
                  FlDotData(show: true),
                );
              }).toList();
            },
          ),

          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: average,
                color: AppColors.secondary,
                strokeWidth: 2,
                dashArray: [8, 4],
              ),
            ],
          ),

          lineBarsData: [lineBarData],
        ),
      ),
    );
  }

  String _formatValue(double value) {
    switch (widget.type) {
      case .weight:
      case .oneRm:
      case .volume:
        return value.toStringAsFixed(0);
      case .reps:
        return value.toInt().toString();
    }
  }

  String _tooltipText(ChartData point) {
    final value = switch (widget.type) {
      .weight => "${point.value.toStringAsFixed(1)} kg",

      .oneRm => "${point.value.toStringAsFixed(1)} kg",

      .volume => "${point.value.toStringAsFixed(0)} kg",

      .reps => "${point.value.toInt()} reps",
    };

    return value;
  }
}