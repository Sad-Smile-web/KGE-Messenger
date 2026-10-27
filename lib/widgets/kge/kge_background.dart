import 'package:flutter/material.dart';

import '../../services/kge_store.dart';

class KgeBackground extends StatefulWidget {
  const KgeBackground({
    super.key,
  });

  @override
  State<KgeBackground> createState() => _KgeBackgroundState();
}

class _KgeBackgroundState extends State<KgeBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _controller,
        KgeStore.instance,
      ]),
      builder: (context, _) {
        final theme = KgeStore.instance.colorTheme;
        final pulse = 0.12 + (_controller.value * 0.08);

        return Stack(
          fit: StackFit.expand,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                theme.filterColor,
                BlendMode.modulate,
              ),
              child: Image.asset(
                'assets/kge/kge_background.png',
                fit: BoxFit.cover,
              ),
            ),

            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xDD030107),
                    Color(0xAA08030F),
                    Color(0xF5030107),
                  ],
                ),
              ),
            ),

            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    theme.centerGlow.withOpacity(pulse + 0.06),
                    const Color(0x00000000),
                  ],
                ),
              ),
            ),

            Positioned.fill(
              child: CustomPaint(
                painter: _KgeGridPainter(
                  animation: _controller.value,
                  gridColor: theme.grid,
                  markerColor: theme.marker,
                ),
              ),
            ),

            Positioned(
              top: MediaQuery.sizeOf(context).height * _controller.value,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 1,
                  color: theme.scanline,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _KgeGridPainter extends CustomPainter {
  final double animation;
  final Color gridColor;
  final Color markerColor;

  _KgeGridPainter({
    required this.animation,
    required this.gridColor,
    required this.markerColor,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = gridColor;

    const gridSize = 38.0;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    final markerPaint = Paint()
      ..color = markerColor
      ..style = PaintingStyle.fill;

    final markerY = size.height * ((animation * 1.3) % 1.0);

    canvas.drawCircle(
      Offset(
        size.width * 0.17,
        markerY,
      ),
      2.5,
      markerPaint,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.82,
        (markerY + size.height * 0.35) % size.height,
      ),
      2,
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _KgeGridPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.markerColor != markerColor;
  }
}
