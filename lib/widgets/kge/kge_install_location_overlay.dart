import 'package:flutter/material.dart';

import '../../services/kge_store.dart';
import '../l10n_text.dart';

class KgeInstallLocationOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final GlobalKey targetKey;

  const KgeInstallLocationOverlay({
    super.key,
    required this.onClose,
    required this.targetKey,
  });

  @override
  State<KgeInstallLocationOverlay> createState() =>
      _KgeInstallLocationOverlayState();
}

class _KgeInstallLocationOverlayState extends State<KgeInstallLocationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTargetRect();
    });
  }

  void _updateTargetRect() {
    final targetContext = widget.targetKey.currentContext;
    final renderObject = targetContext?.findRenderObject();

    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final topLeft = renderObject.localToGlobal(Offset.zero);
    final rect = topLeft & renderObject.size;

    if (!mounted) return;

    setState(() {
      _targetRect = rect;
    });
  }

  Future<void> _close() async {
    if (_controller.isAnimating) {
      await _controller.reverse();
    } else {
      await _controller.reverse();
    }

    if (mounted) {
      widget.onClose();
    }
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
        final scale = 0.96 + (0.04 * curved);

        return Material(
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: 0.78 * curved,
                child: const ColoredBox(
                  color: Color(0xFF05070D),
                ),
              ),

              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _KgeLocationArrowPainter(
                      color: theme.primary,
                      topInset: topInset,
                      targetRect: _targetRect,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: topInset + 86,
                left: 18,
                right: 0,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topCenter,
                  child: Opacity(
                    opacity: curved,
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
        color: const Color(0xF2070A14),
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
                                'ОБУЧЕНИЕ // KGE',
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
                              onTap: _close,
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
                          'Расширение установлено',
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
                          'KGE теперь доступно в верхней части списка чатов.',
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
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: L10nText(
                                'Нажмите KGE → открыть расширение',
                                style: TextStyle(
                                  color: theme.bodyText,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  decoration: TextDecoration.none,
                                ),
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

class _KgeLocationArrowPainter extends CustomPainter {
  final Color color;
  final double topInset;
  final Rect? targetRect;

  const _KgeLocationArrowPainter({
    required this.color,
    required this.topInset,
    required this.targetRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (targetRect == null) return;

    final target = Offset(
      targetRect!.center.dx,
      targetRect!.bottom + 6,
    );
    final start = Offset(
      size.width * 0.38,
      topInset + 74,
    );
    final elbow = Offset(
      (start.dx + target.dx) / 2,
      topInset + 118,
    );

    final paint = Paint()
      ..color = color.withOpacity(0.92)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(elbow.dx, elbow.dy)
      ..lineTo(target.dx, target.dy);

    canvas.drawPath(path, paint);

    final head = Path()
      ..moveTo(target.dx, target.dy)
      ..lineTo(target.dx - 7, target.dy - 5)
      ..lineTo(target.dx - 1, target.dy - 7);

    canvas.drawPath(head, paint);
  }

  @override
  bool shouldRepaint(covariant _KgeLocationArrowPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.topInset != topInset ||
        oldDelegate.targetRect != targetRect;
  }
}
