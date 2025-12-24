
import 'dart:math';

import 'package:flutter/material.dart';

class ChristmasTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Tree layers
    final treeLayers = [
      {'y': 50.0, 'width': 80.0},
      {'y': 100.0, 'width': 120.0},
      {'y': 160.0, 'width': 160.0},
      //{'y': 230.0, 'width': 200.0},
    ];

    for (var layer in treeLayers) {
      paint.color = Colors.green.shade800;
      final path = Path();
      path.moveTo(size.width / 2, layer['y']!);
      path.lineTo(size.width / 2 - layer['width']! / 2, layer['y']! + 60);
      path.lineTo(size.width / 2 + layer['width']! / 2, layer['y']! + 60);
      path.close();
      canvas.drawPath(path, paint);
    }

    // Tree trunk
    paint.color = Colors.brown.shade700;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height - 65),
          width: 40,
          height: 60,
        ),
        const Radius.circular(8),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StarsPainter extends CustomPainter {
  final Animation<double> animation;
  final Random random = Random(42);

  StarsPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = (sin(animation.value * 2 * pi + i) + 1) / 2;
      
      paint.color = Colors.white.withOpacity(opacity * 0.8);
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SnowPainter extends CustomPainter {
  final Random random = Random(123);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.6);

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 1;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}