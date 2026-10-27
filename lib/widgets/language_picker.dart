import 'package:flutter/material.dart';

import '../services/app_localization.dart';
import '../services/language_store.dart';
import 'l10n_text.dart';

Future<void> showLanguagePicker(BuildContext context) async {
  final languageStore = LanguageStore.instance;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 28,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: languageStore,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8E0EA),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(
                        Icons.language_rounded,
                        color: Color(0xFF4A88EB),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      const L10nText(
                        'Язык интерфейса',
                        english: 'Interface language',
                        style: TextStyle(
                          color: Color(0xFF18253A),
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _LanguageChoice(
                    title: 'Русский',
                    code: 'ru',
                    selected: languageStore.code == 'ru',
                    onTap: () async {
                      await languageStore.setLanguage('ru');
                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _LanguageChoice(
                    title: 'English',
                    code: 'en',
                    selected: languageStore.code == 'en',
                    onTap: () async {
                      await languageStore.setLanguage('en');
                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _LanguageChoice(
                    title: '简体中文',
                    code: 'zh',
                    selected: languageStore.code == 'zh',
                    onTap: () async {
                      await languageStore.setLanguage('zh');
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                  ),
                  const SizedBox(height: 10),
                  _LanguageChoice(
                    title: 'Español',
                    code: 'es',
                    selected: languageStore.code == 'es',
                    onTap: () async {
                      await languageStore.setLanguage('es');
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

class _LanguageChoice extends StatelessWidget {
  final String title;
  final String code;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChoice({
    required this.title,
    required this.code,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFFF0F6FF)
          : const Color(0xFFF8FAFD),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 13,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF18253A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                code.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF7E8DA3),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: selected
                    ? const Color(0xFF4A88EB)
                    : const Color(0xFFB8C3D1),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
