import 'package:flutter/material.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/training_exercise.dart';
import 'package:rg_gym/shared/widgets/fixed_decimal_formatter.dart';

class TrainingSetItem extends StatefulWidget {
  final int index;
  final TrainingType type;
  final TrainingSet set;
  final bool isLast;
  final VoidCallback onDelete;
  final ValueChanged<int> onRepsChanged;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<Duration> onTimeChanged;
  
  const TrainingSetItem({
    super.key,
    required this.index,
    required this.type,
    required this.set,
    required this.isLast,
    required this.onDelete,
    required this.onRepsChanged,
    required this.onWeightChanged,
    required this.onTimeChanged,
  });

  @override
  State<TrainingSetItem> createState() => _TrainingSetItemState();
}

class _TrainingSetItemState extends State<TrainingSetItem> {
  late final TextEditingController repsController;
  late final TextEditingController weightController;
  late final TextEditingController timeController;

  bool _isSyncingFromModel = false;

  late String _lastRepsText;
  late String _lastWeightText;
  late String _lastTimeText;

  @override
  void initState() {
    super.initState();

    repsController = TextEditingController(text: (widget.set.reps ?? 0).toString());
    weightController = TextEditingController(text: (widget.set.weight ?? 0).toString());
    timeController = TextEditingController(text: (widget.set.time?.inMinutes ?? 0).toString());
    
    _lastRepsText = repsController.text;
    _lastWeightText = weightController.text;
    _lastTimeText = timeController.text;

    repsController.addListener(() {
      if(_isSyncingFromModel) return;

      final text = repsController.text;

      if(text == _lastRepsText) return;

      String normalized = text;

      if (normalized.isEmpty) {
        normalized = '0';
      } else if (normalized.length > 1 && normalized.startsWith('0')) {
        normalized = normalized.substring(1);
      }

      if (normalized != text) {
        _isSyncingFromModel = true;
        repsController.value = TextEditingValue(
          text: normalized,
          selection: TextSelection.collapsed(offset: normalized.length),
        );
        _isSyncingFromModel = false;
      }

      _lastRepsText = normalized;

      widget.onRepsChanged(int.tryParse(repsController.text) ?? 0);
    });

    weightController.addListener(() {
      if(_isSyncingFromModel) return;

      final text = weightController.text;

      if (text == _lastWeightText) return;

      _lastWeightText = text;

      widget.onWeightChanged(double.parse(weightController.text));
    });

    timeController.addListener(() {
      if(_isSyncingFromModel) return;

      final text = timeController.text;

      if (text == _lastTimeText) return;

      String normalized = text;

      if (normalized.isEmpty) {
        normalized = '0';
      } else if (normalized.length > 1 && normalized.startsWith('0')) {
        normalized = normalized.substring(1);
      }

      if (normalized != text) {
        _isSyncingFromModel = true;
        timeController.value = TextEditingValue(
          text: normalized,
          selection: TextSelection.collapsed(offset: normalized.length),
        );
        _isSyncingFromModel = false;
      }

      _lastTimeText = normalized;

      widget.onTimeChanged(Duration(minutes: int.tryParse(timeController.text) ?? 0));
    });
  }

  @override
  void dispose() {
    repsController.dispose();
    weightController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TrainingSetItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    _isSyncingFromModel = true;

    final newReps = (widget.set.reps ?? 0).toString();
    if(repsController.text != newReps) {
      repsController.value = TextEditingValue(
        text: newReps,
        selection: TextSelection.collapsed(offset: newReps.length)
      );
    }

    
    final newWeight = (widget.set.weight ?? 0).toString();
    if (weightController.text != newWeight) {
      weightController.value = TextEditingValue(
        text: newWeight,
        selection: TextSelection.collapsed(offset: newWeight.length),
      );
    }

    final newTime = (widget.set.time?.inMinutes ?? 0).toString();
    if (timeController.text != newTime) {
      timeController.value = TextEditingValue(
        text: newTime,
        selection: TextSelection.collapsed(offset: newTime.length),
      );
    }

    _isSyncingFromModel = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) async {
        final value = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          items: const [
            PopupMenuItem(
              value: 'delete',
              child: Text('Quitar', style: TextStyle(color: AppColors.primary))
            )
          ]
        );
        if(value == 'delete') {
          widget.onDelete();
        }
      },
      child: SizedBox(
        height: 90,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _SeriesIndicator(
              index: widget.index,
              isLast: widget.isLast,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  height: 74,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.backgroundSecondary,
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
                              child: TextField(
                                controller: repsController,
                                cursorColor: Colors.white,
                                maxLength: 2,
                                style: const TextStyle(fontSize: 28),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: ''
                                ),
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
                              child: TextField(
                                controller: weightController,
                                cursorColor: Colors.white,
                                style: const TextStyle(fontSize: 28),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: const [
                                  FixedDecimalFormatter(
                                    decimalDigits: 1,
                                    maxIntegerDigits: 2,
                                  ),
                                ],
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
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
                              child: TextField(
                                controller: timeController,
                                cursorColor: Colors.white,
                                maxLength: 2,
                                style: const TextStyle(fontSize: 28),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: ''
                                ),
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
      )
    );
  }
}

class _SeriesIndicator extends StatelessWidget {
  final int index;
  final bool isLast;

  const _SeriesIndicator({
    required this.index,
    required this.isLast,
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
              backgroundColor: AppColors.backgroundSecondary,
              child: Text(
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