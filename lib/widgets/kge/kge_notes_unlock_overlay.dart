import 'package:flutter/material.dart';

import '../../services/app_localization.dart';
import '../../services/kge_store.dart';
import '../l10n_text.dart';

class KgeNotesUnlockOverlay extends StatefulWidget {
  final KgeColorTheme theme;
  final Future<void> Function() onClose;

  const KgeNotesUnlockOverlay({
    super.key,
    required this.theme,
    required this.onClose,
  });

  @override
  State<KgeNotesUnlockOverlay> createState() => _KgeNotesUnlockOverlayState();
}

class _KgeNotesUnlockOverlayState extends State<KgeNotesUnlockOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: const Color(0xCC020107),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = Curves.easeOutCubic.transform(_controller.value);
            return Stack(
              children: [
                Center(
                  child: Opacity(
                    opacity: progress,
                    child: Transform.translate(
                      offset: Offset(0, 18 * (1 - progress)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: _notice(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _notice() {
    return Container(
      padding: const EdgeInsets.fromLTRB(19, 17, 10, 19),
      decoration: BoxDecoration(
        color: const Color(0xF4080610),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.theme.primary.withOpacity(0.85), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: widget.theme.primary.withOpacity(0.22),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: L10nText(
                  'ОБУЧЕНИЕ // KGE NOTES',
                  style: TextStyle(
                    color: widget.theme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.7,
                  ),
                ),
              ),
              IconButton(
                tooltip: L10n.t('Закрыть'),
                onPressed: widget.onClose,
                icon: Icon(Icons.close_rounded, color: widget.theme.secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 4),
          L10nText(
            'Заметки KGE разблокированы',
            style: TextStyle(
              color: widget.theme.brightText,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          L10nText(
            'Теперь в профиле расширения доступен отдельный список сюжетных заданий, относящихся только к KGE.',
            style: TextStyle(
              color: widget.theme.secondaryText,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.touch_app_rounded, color: widget.theme.primary, size: 23),
              const SizedBox(width: 10),
              Expanded(
                child: L10nText(
                  'Нажмите на значок K в левом верхнем углу, чтобы открыть профиль.',
                  style: TextStyle(
                    color: widget.theme.brightText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
