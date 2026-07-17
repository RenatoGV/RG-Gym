import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/training_exercise.dart';

class ExecutionSetItem extends StatefulWidget {
  final int index;
  final TrainingType type;
  final TrainingSet set;
  final bool isLast;
  final bool isCurrentSet;
  final bool isCompleted;

  const ExecutionSetItem({
    super.key,
    required this.index,
    required this.type,
    required this.set,
    required this.isLast,
    required this.isCurrentSet,
    required this.isCompleted,
  });

  @override
  State<ExecutionSetItem> createState() => _ExecutionSetItemState();
}

class _ExecutionSetItemState extends State<ExecutionSetItem> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SeriesIndicator(
            index: widget.index,
            isLast: widget.isLast,
            isCurrentSet: widget.isCurrentSet,
            isCompleted: widget.isCompleted,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                height: 74,
                decoration: BoxDecoration(
                  color: widget.isCurrentSet ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.isCurrentSet ? AppColors.primary : AppColors.backgroundSecondary,
                    width: 2
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if(widget.type == .reps || widget.type == .repsWeight)
                      Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(
                              widget.set.reps.toString(),
                              style: const TextStyle(fontSize: 28),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(width: 8),

                          const Text('reps'),
                        ],
                      ),
                    
                    if(widget.type == .repsWeight)
                      Row(
                        children: [
                          const SizedBox(width: 25),

                          const Text('•'),

                          const SizedBox(width: 25),
                        ],
                      ),

                    if(widget.type == .repsWeight || widget.type == .weight)
                      Row(
                        children: [
                          SizedBox(
                            width: 55,
                            child: AutoSizeText(
                              widget.set.weight.toString(),
                              maxLines: 1,
                              style: const TextStyle(fontSize: 28),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(width: 8),

                          const Text('kg'),
                        ],
                      ),

                    if(widget.type == .time)
                      Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(
                              widget.set.time!.inMinutes.toString(),
                              style: const TextStyle(fontSize: 28),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(width: 8),

                          const Text('minutos'),
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesIndicator extends StatelessWidget {
  final int index;
  final bool isLast;
  final bool isCurrentSet;
  final bool isCompleted;

  const _SeriesIndicator({
    required this.index,
    required this.isLast,
    required this.isCurrentSet,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [

          if (!isLast)
            Positioned(
              top: 49,
              bottom: -40,
              child: Container(
                width: 2,
                color: AppColors.backgroundSecondary,
              ),
            ),

          Positioned(
            top: 25,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: isCompleted ? AppColors.completed : isCurrentSet ? AppColors.primary : AppColors.backgroundSecondary,
              child: isCompleted ?
              Icon(Icons.check) :
              Text(
                '$index',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}