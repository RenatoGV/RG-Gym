import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_gym/helpers/statistics_calculator.dart';
import 'package:rg_gym/providers/history_provider.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/screens/tabs/exercises/widgets/personal_records.dart';
import 'package:rg_gym/screens/tabs/exercises/widgets/statistics_chart.dart';

enum FilterDaysWithAll {
  all,
  seven,
  fourteen,
  twentyEight,
  ninety
}

enum StatisticType {
  volume,
  oneRm,
  weight,
  reps,
}

class _StatisticDescription {
  final String title;
  final String description;

  const _StatisticDescription({
    required this.title,
    required this.description,
  });
}

const _descriptions = {
  StatisticType.volume: _StatisticDescription(
    title: 'Volumen',
    description: 'Se refiere a la cantidad total de trabajo realizado durante el entrenamiento. El volumen se calcula multiplicando el número de repeticiones por la carga utilizada en el ejercicio.'
  ),

  StatisticType.oneRm: _StatisticDescription(
    title: '1RM',
    description: 'Presenta la estimación de la carga máxima que puedes levantar en una sola repetición en ese entrenamiento, basada en el peso y el número de repeticiones utilizadas en un set'
  ),

  StatisticType.weight: _StatisticDescription(
    title: 'Peso',
    description: 'Indica la carga más alta utilizada durante la ejecución del ejercicio, ya sea con pesas libres, máquinas y otros tipos de resistencia.'
  ),

  StatisticType.reps: _StatisticDescription(
    title: 'Repeticiones',
    description: 'Muestra la evolución del número total de repeticiones realizadas en los entrenamientos, permitiendo analizar variaciones en la resistencia muscular y la capacidad de mantener o aumentar la intensidad a lo largo del tiempo.'
  )
};

class StatisticsTab extends StatefulWidget {
  final int exerciseId;

  const StatisticsTab({
    super.key,
    required this.exerciseId
  });

  @override
  State<StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {
  StatisticType selectedType = StatisticType.volume;
  FilterDaysWithAll selectedFilter = FilterDaysWithAll.all;

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>().getHistoryByExercise(widget.exerciseId);

    if (history.isEmpty) {
      return _emptyStatistics();
    }

    final statistics = StatisticsCalculator.calculate(
      exerciseId: widget.exerciseId,
      filter: selectedFilter,
      history: history,
      type: selectedType
    );

    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            const Text("Progreso", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildFilter()
          ],
        ),

        const SizedBox(height: 25),

        StatisticsChart(points: statistics.points, average: statistics.average, type: selectedType),

        const SizedBox(height: 25),

        _buildSelector(),

        const SizedBox(height: 25),

        _buildDescription(),

        const SizedBox(height: 25),

        const Divider(
          color: AppColors.backgroundSecondary,
        ),

        const SizedBox(height: 20),

        PersonalRecords(records: statistics.records),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildFilter() {
    return SizedBox(
      width: 170,
      child: DropdownButtonFormField<FilterDaysWithAll>(
        initialValue: selectedFilter,

        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          filled: true,
          fillColor: AppColors.backgroundSecondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),

        dropdownColor: AppColors.backgroundSecondary,
        iconEnabledColor: AppColors.text,
        style: const TextStyle(color: AppColors.text),

        items: FilterDaysWithAll.values.map((filter) {
          return DropdownMenuItem(
            value: filter,
            child: Text(_getFilterName(filter)),
          );
        }).toList(),

        onChanged: (value) {
          if (value == null) return;

          setState(() {
            selectedFilter = value;
          });
        },
      )
    );
  }

  Widget _buildSelector() {
    return SizedBox(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: StatisticType.values.map((type) {
            final selected = selectedType == type;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedType = type;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: .symmetric(horizontal: 20, vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.backgroundSecondary,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _statisticTitle(type),
                    style: TextStyle(
                      color: selected
                          ? AppColors.primary
                          : AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    final info = _descriptions[selectedType]!;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          info.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          info.description,
          style: const TextStyle(
            color: AppColors.text,
            height: 1.5,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

String _getFilterName(FilterDaysWithAll filter) {
  return switch(filter) {
    .all => 'Todo el periodo',
    .seven => '7 días',
    .fourteen => '14 días',
    .twentyEight => '28 días',
    .ninety => '90 días'
  };
}

String _statisticTitle(StatisticType type) {
  return switch(type) {
    .volume => 'Volumen total',
    .oneRm => '1RM',
    .weight => 'Peso',
    .reps => 'Repeticiones'
  };
}

Widget _emptyStatistics() {
  return const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 50),
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
    ),
  );
}