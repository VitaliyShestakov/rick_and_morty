import 'package:flutter/material.dart';
import 'package:rick_and_morty/shared/theme/app_colors.dart';

class PortalMark extends StatelessWidget {
  const PortalMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: const CustomPaint(painter: PortalPainter()),
  );
}

class PortalPainter extends CustomPainter {
  const PortalPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    canvas.drawCircle(
      const Offset(50, 50),
      43,
      Paint()..color = AppColors.accent.withValues(alpha: 0.09),
    );
    final spiral = Path()
      ..moveTo(51, 13)
      ..cubicTo(82, 8, 96, 36, 82, 62)
      ..cubicTo(69, 88, 32, 91, 18, 66)
      ..cubicTo(3, 40, 25, 15, 48, 24)
      ..cubicTo(73, 31, 77, 58, 57, 70)
      ..cubicTo(40, 80, 24, 63, 33, 47)
      ..cubicTo(40, 34, 58, 37, 59, 49)
      ..cubicTo(60, 58, 48, 63, 45, 54);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      spiral,
      stroke
        ..strokeWidth = 14
        ..color = const Color(0xFF58A94D),
    );
    canvas.drawPath(
      spiral,
      stroke
        ..strokeWidth = 8
        ..color = AppColors.accent,
    );
    final speck = Paint()..color = AppColors.accent;
    canvas.drawCircle(const Offset(18, 20), 3, speck);
    canvas.drawCircle(const Offset(84, 79), 4, speck);
    canvas.drawCircle(const Offset(61, 93), 2, speck);
    canvas.restore();
  }

  @override
  bool shouldRepaint(PortalPainter oldDelegate) => false;
}
