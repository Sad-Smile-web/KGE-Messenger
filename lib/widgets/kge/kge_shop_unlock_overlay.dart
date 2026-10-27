import 'package:flutter/material.dart';

import '../../services/app_localization.dart';
import '../../services/kge_store.dart';
import '../l10n_text.dart';

class KgeShopUnlockOverlay extends StatefulWidget {
  final KgeColorTheme theme;
  final Future<void> Function() onClose;

  const KgeShopUnlockOverlay({
    super.key,
    required this.theme,
    required this.onClose,
  });

  @override
  State<KgeShopUnlockOverlay> createState() =>
      _KgeShopUnlockOverlayState();
}

class _KgeShopUnlockOverlayState extends State<KgeShopUnlockOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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
        color: const Color(0x99000000),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = Curves.easeOutCubic.transform(
              _controller.value,
            );

            return Stack(
              children: [
                Positioned(
                  top: MediaQuery.of(context).padding.top + 18,
                  left: 18,
                  right: 18,
                  child: Transform.translate(
                    offset: Offset(0, -12 * (1 - progress)),
                    child: Opacity(
                      opacity: progress,
                      child: _buildNotice(),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 70,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: progress,
                      child: Column(
                        children: [
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: widget.theme.primary,
                            size: 38,
                          ),
                          Container(
                            width: 48,
                            height: 2,
                            decoration: BoxDecoration(
                              color: widget.theme.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.theme.primary.withOpacity(0.65),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 8, 15),
      decoration: BoxDecoration(
        color: const Color(0xF20A0710),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.theme.primary.withOpacity(0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.theme.primary.withOpacity(0.20),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.theme.primary.withOpacity(0.10),
              border: Border.all(
                color: widget.theme.primary.withOpacity(0.45),
              ),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: widget.theme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                L10nText(
                  'МАГАЗИН KGE РАЗБЛОКИРОВАН',
                  style: TextStyle(
                    color: widget.theme.brightText,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 7),
                L10nText(
                  'Магазин KGE теперь доступен в разделе «Операции».',
                  style: TextStyle(
                    color: widget.theme.secondaryText,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                L10nText(
                  'OPERATIONS // SHOP',
                  style: TextStyle(
                    color: widget.theme.mutedText,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: L10n.t('Закрыть'),
            onPressed: widget.onClose,
            icon: Icon(
              Icons.close_rounded,
              color: widget.theme.subtitle,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
