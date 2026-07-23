import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rg_gym/config/data/equipments.dart';
import 'package:rg_gym/config/theme/app_colors.dart';

const equipmentColors = <int, Color>{
  0: Colors.blue,
  1: Colors.red,
  2: Colors.orange,
  3: Colors.green,
  4: Colors.purple,
  5: Colors.teal,
  6: Colors.brown,
  7: Colors.grey,
  8: Colors.indigo,
  9: Colors.pink,
  10: Colors.cyan,
  11: Colors.amber,
  12: Colors.deepOrange,
  13: Colors.lime,
};

class EquipmentStat extends StatefulWidget {
  final Map<int, int> equipmentCount;

  const EquipmentStat({
    super.key,
    required this.equipmentCount,
  });

  @override
  State<EquipmentStat> createState() => _EquipmentStatState();
}

class _EquipmentStatState extends State<EquipmentStat>
    with TickerProviderStateMixin {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final total = widget.equipmentCount.values.fold(0, (a, b) => a + b);

    final entries = widget.equipmentCount.entries.toList();

    final visibleEntries = expanded
        ? entries
        : entries.take(3).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: AppColors.backgroundSecondary,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 0,
                  sections: entries.map((entry) {
                    final percent = total == 0
                        ? 0.0
                        : entry.value / total * 100;

                    return PieChartSectionData(
                      value: percent,
                      color: equipmentColors[entry.key],
                      title: '${percent.toStringAsFixed(1)}%',
                      radius: 90,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                ...visibleEntries.map((entry) {
                  final equipment = equipments.firstWhere(
                    (e) => e.id == entry.key,
                  );

                  final percent = total == 0
                      ? 0.0
                      : entry.value / total * 100;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: equipmentColors[entry.key],
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(equipment.name),
                              Text('${percent.toStringAsFixed(1)}%'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                if (entries.length > 3)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        expanded = !expanded;
                      });
                    },
                    iconAlignment: IconAlignment.end,
                    icon: AnimatedRotation(
                      turns: expanded ? .5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    label: Text(
                      expanded ? 'Ver menos' : 'Ver más',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}