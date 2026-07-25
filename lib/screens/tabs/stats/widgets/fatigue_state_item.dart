import 'package:flutter/material.dart';
import 'package:rg_gym/models/fatigued_muscle.dart';

class FatigueStateItem extends StatelessWidget {
  final FatigueState state;

  const FatigueStateItem({
    super.key,
    required this.state
  });

  @override
  Widget build(BuildContext context) {
    final stateName = switch(state) {
      .weakened => 'Debilitado',
      .recovered => 'Recuperado',
      .recovering => 'En recuperación',
      .fatigued => 'Fatigado'
    };

    final stateColor = switch(state) {
      .weakened => Colors.green,
      .recovered => Colors.blue,
      .recovering => Colors.amber,
      .fatigued => Colors.red
    };

    return SizedBox(
      width: 150,
      child: Row(
        children: [
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              color: stateColor,
              borderRadius: BorderRadius.circular(100)
            ),
          ),
          const SizedBox(width: 10),
          Text(stateName)
        ]
      ),
    );
  }
}