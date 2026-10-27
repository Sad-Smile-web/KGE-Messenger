import 'dart:math' as math;

import 'package:flutter/material.dart';

class KgeLogo extends StatelessWidget {
  final double progress;

  const KgeLogo({
    super.key,
    this.progress = 1,
  });

  @override
  Widget build(BuildContext context) {
    final depth =
    (progress * 8).round();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 86,
          height: 86,
          child: CustomPaint(
            painter: _KgeLogoPainter(
              progress: progress,
            ),
          ),
        ),
        const SizedBox(width: 18),
        Stack(
          children: [
            for (int i = depth; i >= 1; i--)
              Positioned(
                left: i * 1.45,
                top: i * 1.25,
                child: Text(
                  'KGE',
                  style: TextStyle(
                    color:
                    Color.lerp(
                      const Color(
                        0xFF052033,
                      ),
                      const Color(
                        0xFF0E6D9D,
                      ),
                      i / math.max(
                        1,
                        depth,
                      ),
                    ),
                    fontSize: 58,
                    fontWeight:
                    FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ShaderMask(
              shaderCallback:
                  (bounds) {
                return const LinearGradient(
                  begin:
                  Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFB9ECFF),
                    Color(0xFF2EBDFF),
                  ],
                ).createShader(
                  bounds,
                );
              },
              child: const Text(
                'KGE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 58,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      color:
                      Color(0xAA2BBEFF),
                      blurRadius: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KgeLogoPainter
    extends CustomPainter {
  final double progress;

  _KgeLogoPainter({
    required this.progress,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final scale =
        0.72 + progress * 0.28;

    canvas.save();

    canvas.translate(
      center.dx,
      center.dy,
    );

    canvas.scale(scale);

    final outerPaint = Paint()
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(
        0xFF55C9FF,
      );

    final glowPaint = Paint()
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = const Color(
        0x442FB9FF,
      );

    final path = Path();

    for (int i = 0; i < 6; i++) {
      final angle =
          -math.pi / 2 +
              i * math.pi / 3;

      final point = Offset(
        math.cos(angle) * 31,
        math.sin(angle) * 31,
      );

      if (i == 0) {
        path.moveTo(
          point.dx,
          point.dy,
        );
      } else {
        path.lineTo(
          point.dx,
          point.dy,
        );
      }
    }

    path.close();

    canvas.drawPath(
      path,
      glowPaint,
    );

    canvas.drawPath(
      path,
      outerPaint,
    );

    final innerPaint = Paint()
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(
        0xFF8FE1FF,
      );

    canvas.drawCircle(
      Offset.zero,
      20,
      innerPaint,
    );

    final centerPaint =
    Paint()
      ..style =
          PaintingStyle.fill
      ..color = const Color(
        0xFF55C9FF,
      );

    canvas.drawCircle(
      Offset.zero,
      5,
      centerPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(
      covariant _KgeLogoPainter oldDelegate,
      ) {
    return oldDelegate.progress !=
        progress;
  }
}