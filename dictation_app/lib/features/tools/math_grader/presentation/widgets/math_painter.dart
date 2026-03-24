import 'package:flutter/material.dart';
import '../../models/math_problem.dart';

class MathPainter extends CustomPainter {
  final List<MathProblem> problems;
  final double scale;

  MathPainter({required this.problems, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final correctPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final wrongPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    for (var problem in problems) {
      // Scale coordinates from original image to current screen size
      final rect = Rect.fromLTRB(
        problem.boundingBox.left * scale,
        problem.boundingBox.top * scale,
        problem.boundingBox.right * scale,
        problem.boundingBox.bottom * scale,
      );

      // Draw bounding box (optional, for debug or highlight)
      // canvas.drawRect(rect, Paint()..color = Colors.blue.withOpacity(0.2)..style = PaintingStyle.fill);

      // Draw checkmark or cross to the right of the equation
      double iconX = rect.right + 10;
      double iconY = rect.center.dy;
      double iconSize = 20.0;

      if (problem.isCorrect) {
        // Draw ✓
        final path = Path();
        path.moveTo(iconX, iconY);
        path.lineTo(iconX + iconSize / 3, iconY + iconSize / 2);
        path.lineTo(iconX + iconSize, iconY - iconSize / 2);
        canvas.drawPath(path, correctPaint);
      } else {
        // Draw ✗
        canvas.drawLine(Offset(iconX, iconY - iconSize / 2), Offset(iconX + iconSize, iconY + iconSize / 2), wrongPaint);
        canvas.drawLine(Offset(iconX + iconSize, iconY - iconSize / 2), Offset(iconX, iconY + iconSize / 2), wrongPaint);
        
        // Add a small hint text
        TextPainter(
          text: const TextSpan(text: 'TAP', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr,
        )
          ..layout()
          ..paint(canvas, Offset(iconX, iconY + iconSize));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
