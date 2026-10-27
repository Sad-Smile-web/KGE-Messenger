import 'package:flutter/material.dart';
import '../../services/app_localization.dart';

import '../../widgets/kge/kge_logo.dart';
import '../../widgets/l10n_text.dart';

class KgeBootOverlay extends StatefulWidget {
  final VoidCallback onFinished;

  const KgeBootOverlay({
    super.key,
    required this.onFinished,
  });

  @override
  State<KgeBootOverlay> createState() =>
      _KgeBootOverlayState();
}

class _KgeBootOverlayState
    extends State<KgeBootOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _finished = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 2800,
      ),
    );

    _controller.addStatusListener(
          (status) {
        if (status == AnimationStatus.completed &&
            !_finished) {
          _finished = true;
          widget.onFinished();
        }
      },
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(
          _controller.value,
        );

        final logoOpacity = ((t - 0.04) / 0.20)
            .clamp(0.0, 1.0);

        final logoProgress = ((t - 0.06) / 0.42)
            .clamp(0.0, 1.0);

        final subtitleProgress =
        ((t - 0.32) / 0.25)
            .clamp(0.0, 1.0);

        final loadingProgress =
        ((t - 0.20) / 0.60)
            .clamp(0.0, 1.0);

        final status = t < 0.30
            ? 'ИНИЦИАЛИЗАЦИЯ'
            : t < 0.52
            ? 'ЗАГРУЗКА ЯДРА'
            : t < 0.76
            ? 'ПОДГОТОВКА СИСТЕМЫ'
            : 'СИСТЕМА ГОТОВА';

        return Material(
          color: const Color(
            0xFF020106,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Фоновые линии.
              CustomPaint(
                painter: _BootGridPainter(
                  progress: t,
                ),
              ),

              // Центральное свечение.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.85,
                      colors: [
                        Color(
                          0x503E0968,
                        ).withOpacity(
                          0.35 +
                              t * 0.25,
                        ),
                        const Color(
                          0x00000000,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Логотип.
              Center(
                child: Opacity(
                  opacity: logoOpacity,
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      28 *
                          (1 -
                              logoOpacity),
                    ),
                    child: Transform.scale(
                      scale: 0.76 +
                          logoProgress *
                              0.24,
                      child: Column(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          KgeLogo(
                            progress:
                            logoProgress,
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          Opacity(
                            opacity:
                            subtitleProgress,
                            child: const L10nText('KERNEL GHOST ENGINE',
                              style: TextStyle(
                                color: Color(
                                  0xFFB45CFF,
                                ),
                                fontSize: 10,
                                fontWeight:
                                FontWeight.w800,
                                letterSpacing:
                                3.0,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          L10nText(
                            status,
                            style:
                            const TextStyle(
                              color: Color(
                                0xFFEFE1FF,
                              ),
                              fontSize: 9,
                              fontWeight:
                              FontWeight.w800,
                              letterSpacing:
                              1.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Нижний прогресс.
              Positioned(
                left: 36,
                right: 36,
                bottom: 78,
                child: Column(
                  children: [
                    Container(
                      height: 3,
                      decoration:
                      BoxDecoration(
                        color: const Color(
                          0x221A0A28,
                        ),
                        borderRadius:
                        BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: FractionallySizedBox(
                        alignment:
                        Alignment.centerLeft,
                        widthFactor:
                        loadingProgress,
                        child: Container(
                          decoration:
                          BoxDecoration(
                            color: const Color(
                              0xFFB45CFF,
                            ),
                            borderRadius:
                            BorderRadius.circular(
                              20,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(
                                  0x993F00AA,
                                ),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                      children: [
                        const L10nText('KGE CORE',
                          style: TextStyle(
                            color: Color(
                              0xFF735783,
                            ),
                            fontSize: 8,
                            fontWeight:
                            FontWeight.w700,
                            letterSpacing:
                            1.5,
                          ),
                        ),
                        L10nText('${(loadingProgress * 100).round()}%',
                          style: const TextStyle(
                            color: Color(
                              0xFFCBA7E4,
                            ),
                            fontSize: 8,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Сканирующая линия.
              if (t > 0.18)
                Positioned(
                  top:
                  MediaQuery.sizeOf(context)
                      .height *
                      ((t - 0.18) / 0.82)
                          .clamp(0.0, 1.0),
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    decoration:
                    const BoxDecoration(
                      color: Color(
                        0x665B18A6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(
                            0x884F00AA,
                          ),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BootGridPainter
    extends CustomPainter {
  final double progress;

  _BootGridPainter({
    required this.progress,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = const Color(
        0x101B0A2A,
      )
      ..strokeWidth = 1;

    const grid = 40.0;

    for (double x = 0;
    x <= size.width;
    x += grid) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0;
    y <= size.height;
    y += grid) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    final markerPaint = Paint()
      ..color = const Color(
        0x663F146D,
      );

    final y =
        (size.height * progress * 1.4) %
            size.height;

    canvas.drawCircle(
      Offset(
        size.width * 0.15,
        y,
      ),
      2.5,
      markerPaint,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.82,
        (y + 180) %
            size.height,
      ),
      2,
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _BootGridPainter oldDelegate,
      ) {
    return oldDelegate.progress !=
        progress;
  }
}
