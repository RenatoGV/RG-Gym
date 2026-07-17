import 'package:flutter/material.dart';
import 'package:rg_gym/models/muscle_maker.dart';

class MuscleHotspot extends StatelessWidget {
  final MuscleMarker marker;
  final double imageWidth;
  final double imageHeight;
  final VoidCallback? onTap;

  const MuscleHotspot({
    super.key,
    required this.marker,
    required this.imageWidth,
    required this.imageHeight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _MuscleHotspotPainter(
            marker: marker,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
          ),
        ),
      ),
    );
  }
}

class _MuscleHotspotPainter extends CustomPainter {
  final MuscleMarker marker;
  final double imageWidth;
  final double imageHeight;

  _MuscleHotspotPainter({
    required this.marker,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = imageWidth / 500;

    final square = 12 * scale;
    final vertical = 20 * scale;
    final gap = 8 * scale;

    final point = Offset(
      marker.x * imageWidth,
      marker.y * imageHeight,
    );

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2 * scale
      ..style = PaintingStyle.stroke;

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5 * scale;

    final textPainter = TextPainter(
      text: TextSpan(
        text: marker.name,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16 * scale,
          fontWeight: .w500
        )
      ),
      textDirection: TextDirection.ltr
    )..layout();

    switch (marker.position) {
      case .left:
        canvas.drawRect(
          Rect.fromCenter(
            center: point,
            width: square,
            height: square
          ),
          paint
        );

        canvas.drawLine(
          Offset(point.dx, point.dy - square / 2),
          Offset(point.dx, point.dy - vertical),
          linePaint,
        );

        canvas.drawLine(
          Offset(0, point.dy - vertical),
          Offset(point.dx, point.dy - vertical),
          linePaint,
        );

        textPainter.paint(
          canvas,
          Offset(
            0,
            point.dy - vertical - textPainter.height - gap,
          ),
        );

        break;

      case .right:
        canvas.drawRect(
          Rect.fromCenter(
            center: point,
            width: square,
            height: square,
          ),
          paint,
        );

        canvas.drawLine(
          Offset(point.dx, point.dy - square / 2),
          Offset(point.dx, point.dy - vertical),
          linePaint,
        );

        canvas.drawLine(
          Offset(point.dx, point.dy - vertical),
          Offset(imageWidth, point.dy - vertical),
          linePaint,
        );

        textPainter.paint(
          canvas,
          Offset(
            imageWidth - textPainter.width,
            point.dy - vertical - textPainter.height - gap,
          ),
        );

        break;

      case MarkerPosition.floating:
        final textOffset = Offset(
          point.dx - textPainter.width / 2,
          point.dy - textPainter.height / 2,
        );

        textPainter.paint(canvas, textOffset);

        final underlineY = textOffset.dy + textPainter.height + 2 * scale;

        canvas.drawLine(
          Offset(textOffset.dx, underlineY),
          Offset(textOffset.dx + textPainter.width, underlineY),
          linePaint,
        );

        break;
    }
  }

  @override
  bool shouldRepaint(covariant _MuscleHotspotPainter oldDelegate) {
    return oldDelegate.marker != marker ||
      oldDelegate.imageWidth != imageWidth ||
      oldDelegate.imageHeight != imageHeight;
  }
}