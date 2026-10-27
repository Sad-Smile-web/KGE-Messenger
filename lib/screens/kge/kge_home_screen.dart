import 'package:flutter/material.dart';

import '../../services/kge_store.dart';
import '../../widgets/kge/kge_panel.dart';
import '../../widgets/l10n_text.dart';

class KgeHomeScreen extends StatelessWidget {
  const KgeHomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: KgeStore.instance,
      builder: (context, _) {
        final theme = KgeStore.instance.colorTheme;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KgePanel(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    L10nText('KGE',
                      style: TextStyle(
                        color: theme.brightText,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    L10nText('KERNEL GHOST ENGINE',
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 1,
                      color: const Color(0x332F0E49),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.primary,
                            boxShadow: [
                              BoxShadow(
                                color: theme.primary.withOpacity(0.8),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 9),
                        L10nText('СИСТЕМА ГОТОВА',
                          style: TextStyle(
                            color: theme.secondaryText,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              KgePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const KgeSectionTitle(
                      title: 'О ПРИЛОЖЕНИИ',
                      subtitle: 'Перед использованием внимательно ознакомьтесь',
                    ),
                    const SizedBox(height: 16),
                    _InfoBox(
                      text: 'Это расширение не принадлежит никому — '
                          'и одновременно принадлежит каждому.\n\n'
                          'Его происхождение, назначение и истинные '
                          'границы возможностей вам неизвестны. '
                          'Используя KGE, вы добровольно принимаете '
                          'на себя все связанные с ним риски — вплоть '
                          'до угрозы вашей жизни, безопасности '
                          'и анонимности.\n\n'
                          'Не обманывайте себя: абсолютной '
                          'анонимности не существует.\n'
                          'Никто не анонимен.',
                      color: theme.bodyText,
                      borderColor: theme.innerBorder,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              KgePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const KgeSectionTitle(
                      title: 'ПРАВИЛА',
                      subtitle: 'Обязательны к прочтению перед началом работы',
                    ),
                    const SizedBox(height: 16),
                    _InfoBox(
                      text: 'Запуская KGE, вы подтверждаете, '
                          'что осознаёте возможные последствия '
                          'своих действий и добровольно принимаете '
                          'на себя ответственность за них.\n\n'
                          'Не рассчитывайте на помощь, защиту '
                          'или вмешательство извне. Не пытайтесь '
                          'установить личность разработчика, '
                          'отыскать его местонахождение или выйти '
                          'с ним на связь.\n\n'
                          'Тот, кто создал это расширение, '
                          'не собирается быть найденным.\n'
                          'И вы никогда не узнаете, насколько '
                          'близко были к нему.',
                      color: theme.bodyText,
                      borderColor: theme.innerBorder,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              KgePanel(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: const [
                    Expanded(
                      child: _StatusItem(
                        label: 'ЯДРО',
                        value: 'ONLINE',
                      ),
                    ),
                    Expanded(
                      child: _StatusItem(
                        label: 'РЕЖИМ',
                        value: 'ЛОКАЛЬНЫЙ',
                      ),
                    ),
                    Expanded(
                      child: _StatusItem(
                        label: 'ВЕРСИЯ',
                        value: '0.1.7',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Center(
                child: L10nText('KGE / KERNEL GHOST ENGINE',
                  style: TextStyle(
                    color: theme.mutedText.withOpacity(0.85),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
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

class _InfoBox extends StatelessWidget {
  final String text;
  final Color color;
  final Color borderColor;

  const _InfoBox({
    required this.text,
    required this.color,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0x11000000),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor),
      ),
      child: L10nText(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          height: 1.6,
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatusItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: KgeStore.instance,
      builder: (context, _) {
        final theme = KgeStore.instance.colorTheme;

        return Column(
          children: [
            L10nText(
              label,
              style: TextStyle(
                color: theme.mutedText,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 5),
            L10nText(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.secondaryText,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        );
      },
    );
  }
}
