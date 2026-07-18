import 'package:flutter/material.dart';

class PulseButton extends StatefulWidget {
  final bool active;
  final Widget child;
  final Color color;

  const PulseButton({
    super.key,
    required this.active,
    required this.child,
    required this.color
  });

  @override
  State<PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<PulseButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant PulseButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.active != widget.active) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.active) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _controller, builder: (context, child) {
        if (!widget.active) {
          return child!;
        }

        final value = _controller.value;

        return Stack(
          alignment: .center,
          clipBehavior: .none,
          children: [
            Positioned.fill(
              child: Transform.scale(
                scaleX: 1 + (value * 0.15),
                scaleY: 1 + (value * 0.45),
                child: Opacity(
                  opacity: 1 - value,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),

            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}