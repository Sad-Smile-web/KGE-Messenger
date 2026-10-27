import 'package:flutter/material.dart';

import '../../services/kge_store.dart';
import '../l10n_text.dart';

class KgePanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const KgePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: KgeStore.instance,
      builder: (context, _) {
        final theme = KgeStore.instance.colorTheme;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xD9080710),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.panelBorder,
              width: 1,
            ),
            boxShadow: [
              const BoxShadow(
                color: Color(0x24000000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
              BoxShadow(
                color: theme.panelGlow,
                blurRadius: 18,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 18,
                  right: 18,
                  child: Container(
                    height: 1,
                    color: theme.topLine,
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.panelTint,
                            const Color(0x00000000),
                            theme.panelTint,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: padding,
                  child: child,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class KgeSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const KgeSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: KgeStore.instance,
      builder: (context, _) {
        final theme = KgeStore.instance.colorTheme;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 29,
              margin: const EdgeInsets.only(right: 11),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withOpacity(0.53),
                    blurRadius: 9,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  L10nText(
                    title,
                    style: TextStyle(
                      color: theme.brightText,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    L10nText(
                      subtitle!,
                      style: TextStyle(
                        color: theme.subtitle,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
