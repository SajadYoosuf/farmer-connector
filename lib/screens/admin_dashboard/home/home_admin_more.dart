import 'package:flutter/material.dart';
import 'dart:math';

/// Reusable stat card with a built-in mini line chart
Widget cardItem({
  required IconData icon,
  required String label,
  required String value,
  required String percentage,
  required List<double> chartData,
  Color bgColor = const Color.fromRGBO(27, 94, 32, 1),
}) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON + PERCENTAGE BOX
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: const Color.fromRGBO(156, 229, 101, 1), size: 28),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.28),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  percentage,
                  style: const TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            label,
            style: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.78),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          // Mini line chart
          SizedBox(
            height: 40,
            child: CustomPaint(
              size: const Size(double.infinity, 40),
              painter: _MiniChartPainter(chartData),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Custom painter that draws a smooth mini line chart
class _MiniChartPainter extends CustomPainter {
  final List<double> data;

  _MiniChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce(max);
    final minVal = data.reduce(min);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final paint = Paint()
      ..color = const Color.fromRGBO(156, 229, 101, 1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color.fromRGBO(156, 229, 101, 0.4),
          const Color.fromRGBO(156, 229, 101, 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] - minVal) / range) * size.height * 0.85;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        // Smooth curve using cubic bezier
        final prevX = (i - 1) * stepX;
        final prevY = size.height - ((data[i - 1] - minVal) / range) * size.height * 0.85;
        final ctrlX = (prevX + x) / 2;
        path.cubicTo(ctrlX, prevY, ctrlX, y, x, y);
        fillPath.cubicTo(ctrlX, prevY, ctrlX, y, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
