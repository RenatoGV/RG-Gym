import 'package:flutter/material.dart';
import 'package:rg_gym/config/data/muscle_groups.dart';
import 'package:rg_gym/config/theme/app_colors.dart';

class MuscleCountList extends StatefulWidget {
  final Map<int, int> muscleCount;

  const MuscleCountList({
    super.key,
    required this.muscleCount,
  });

  @override
  State<MuscleCountList> createState() => _MuscleCountListState();
}

class _MuscleCountListState extends State<MuscleCountList>
    with TickerProviderStateMixin {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final entries = widget.muscleCount.entries.toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    final visible = expanded
        ? entries
        : entries.take(3).toList();

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          ...visible.map((entry) {
            final muscle = muscleGroups.firstWhere((m) => m.id == entry.key);
            final percent = total == 0 ? 0 : entry.value / total * 100;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(muscle.name),
                  ),
                  Text('${percent.toStringAsFixed(1)}%'),
                ],
              ),
            );
          }),

          if (entries.length > 3)
            TextButton.icon(
              onPressed: () {
                setState(() => expanded = !expanded);
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
    );
  }
}