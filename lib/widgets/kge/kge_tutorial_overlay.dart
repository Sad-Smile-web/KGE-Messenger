import 'package:flutter/material.dart';

import '../../services/kge_store.dart';
import '../l10n_text.dart';

class KgeTutorialOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const KgeTutorialOverlay({
    super.key,
    required this.onClose,
  });

  @override
  State<KgeTutorialOverlay> createState() => _KgeTutorialOverlayState();
}

class _KgeTutorialOverlayState extends State<KgeTutorialOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = KgeStore.instance.colorTheme;
    final topInset = MediaQuery.of(context).padding.top;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final curved = Curves.easeOutCubic.transform(_controller.value);
        final opacity = curved;
        final scale = 0.96 + (0.04 * curved);

        return Material(
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: 0.88 * opacity,
                child: const ColoredBox(
                  color: Color(0xFF010208),
                ),
              ),

              // Highlight around the K button in the upper-left corner.
              Positioned(
                top: topInset + 4,
                left: 48,
                child: IgnorePointer(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.primary.withOpacity(0.95),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primary.withOpacity(0.55),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _KgeTutorialArrowPainter(
                      color: theme.primary,
                      topInset: topInset,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: topInset + 92,
                left: 18,
                right: 18,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topCenter,
                  child: Opacity(
                    opacity: opacity,
                    child: _buildCard(theme),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(KgeColorTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xEE070A14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.primary.withOpacity(0.72),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(0.18),
            blurRadius: 28,
            spreadRadius: 2,
          ),
          const BoxShadow(
            color: Color(0xAA000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: theme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primary.withOpacity(0.65),
                      blurRadius: 14,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: L10nText(
                                'ОБУЧЕНИЕ // 01',
                                style: TextStyle(
                                  color: theme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.7,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: widget.onClose,
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: theme.bodyText,
                                  size: 19,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        L10nText(
                          'Новый доступ обнаружен',
                          style: TextStyle(
                            color: theme.brightText,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 7),
                        L10nText(
                          'Нажмите на K в левом верхнем углу, чтобы открыть Профиль KGE.',
                          style: TextStyle(
                            color: theme.bodyText,
                            fontSize: 12.5,
                            height: 1.45,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              color: theme.primary,
                              size: 17,
                            ),
                            const SizedBox(width: 6),
                            L10nText(
                              'Нажмите K → Профиль',
                              style: TextStyle(
                                color: theme.secondaryText,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KgeTutorialArrowPainter extends CustomPainter {
  final Color color;
  final double topInset;

  const _KgeTutorialArrowPainter({
    required this.color,
    required this.topInset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(84, topInset + 93);
    final elbow = Offset(55, topInset + 71);
    final end = Offset(73, topInset + 29);

    final line = Paint()
      ..color = color.withOpacity(0.92)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(elbow.dx, elbow.dy)
      ..lineTo(end.dx, end.dy);

    canvas.drawPath(path, line);

    final arrowHead = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - 7, end.dy + 5)
      ..lineTo(end.dx + 2, end.dy + 7);

    canvas.drawPath(arrowHead, line);
  }

  @override
  bool shouldRepaint(covariant _KgeTutorialArrowPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.topInset != topInset;
  }
}
