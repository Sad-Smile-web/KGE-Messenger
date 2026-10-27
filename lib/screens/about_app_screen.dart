import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/l10n_text.dart';
import '../services/app_localization.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({
    super.key,
  });

  // =========================================================
  // ССЫЛКИ
  // =========================================================

  static final Uri supportUri = Uri.parse(
    'https://kusok-game-enterprises.netlify.app/',
  );

  static final Uri itchUri = Uri.parse(
    'https://zreirby.itch.io/',
  );

  static final Uri boostyUri = Uri.parse(
    'https://boosty.to/sad-smile/donate',
  );

  // =========================================================
  // ЦВЕТА
  // =========================================================

  static const Color _background =
  Color(0xFFF6F8FC);

  static const Color _text =
  Color(0xFF18253A);

  static const Color _secondaryText =
  Color(0xFF7D8CA3);

  static const Color _blue =
  Color(0xFF1976F3);

  static const Color _lightBlue =
  Color(0xFFEAF3FF);

  static const Color _border =
  Color(0xFFDCE5F0);

  // =========================================================
  // ОТКРЫТЬ ССЫЛКУ
  // =========================================================

  Future<void> _openUrl(
      BuildContext context,
      Uri uri,
      ) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        return;
      }
    } catch (_) {
      // Ошибка обработана ниже.
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: L10nText('Не удалось открыть ссылку.',
          ),
          behavior:
          SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,

      // =====================================================
      // ВЕРХНЯЯ ПАНЕЛЬ
      // =====================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,

        leading: IconButton(
          tooltip: L10n.t('Назад'),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _text,
            size: 25,
          ),
        ),

        centerTitle: true,

        title: const L10nText('О приложении',
          style: TextStyle(
            color: _text,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),

        bottom: PreferredSize(
          preferredSize:
          const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(
              0xFFE8EDF3,
            ),
          ),
        ),
      ),

      // =====================================================
      // СОДЕРЖИМОЕ
      // =====================================================

      body: SafeArea(
        child: ListView(
          physics:
          const BouncingScrollPhysics(),

          padding:
          const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            30,
          ),

          children: [
            // =================================================
            // ЗАГОЛОВОК
            // =================================================

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(
                  22,
                ),
                border: Border.all(
                  color: _border,
                ),
                boxShadow: const [
                  BoxShadow(
                    color:
                    Color(0x12000000),
                    blurRadius: 18,
                    offset:
                    Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration:
                    BoxDecoration(
                      color: _lightBlue,
                      borderRadius:
                      BorderRadius.circular(
                        22,
                      ),
                    ),
                    child:
                    const Icon(
                      Icons
                          .chat_bubble_rounded,
                      color: _blue,
                      size: 36,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  const L10nText('Связь',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color: _text,
                      fontSize: 26,
                      fontWeight:
                      FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  const L10nText('О приложении',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color:
                      _secondaryText,
                      fontSize: 14,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // =================================================
            // РАЗРАБОТЧИК
            // =================================================

            _InfoSection(
              title: 'Разработчик',
              icon:
              Icons.person_outline_rounded,
              child: const _InfoRow(
                icon:
                Icons.alternate_email_rounded,
                title: 'Sad_Smile',
                subtitle:
                'Разработчик приложения',
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // =================================================
            // КОМПАНИЯ
            // =================================================

            _InfoSection(
              title: 'Компания',
              icon:
              Icons.business_outlined,
              child: const _InfoRow(
                icon:
                Icons.apartment_outlined,
                title:
                'Kusok Game Enterprises',
                subtitle:
                'Разработка и поддержка проектов',
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // =================================================
            // ССЫЛКИ
            // =================================================

            _InfoSection(
              title: 'Ссылки',
              icon:
              Icons.public_rounded,
              child: Column(
                children: [
                  _LinkTile(
                    icon:
                    Icons.support_agent_rounded,
                    title:
                    'Техническая поддержка',
                    subtitle:
                    'Сайт поддержки игр Sad_Smile',
                    onTap: () {
                      _openUrl(
                        context,
                        supportUri,
                      );
                    },
                  ),

                  const _Divider(),

                  _LinkTile(
                    icon:
                    Icons.gamepad_rounded,
                    title: 'itch.io',
                    subtitle:
                    'Страница Sad_Smile',
                    onTap: () {
                      _openUrl(
                        context,
                        itchUri,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // =================================================
            // ПОДДЕРЖАТЬ РАЗРАБОТКУ
            // =================================================

            _InfoSection(
              title:
              'Поддержать разработку',
              icon:
              Icons.favorite_border_rounded,
              child: _LinkTile(
                icon:
                Icons.auto_awesome_rounded,
                title: 'Boosty',
                subtitle:
                'Поддержать разработку',
                onTap: () {
                  _openUrl(
                    context,
                    boostyUri,
                  );
                },
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            // =================================================
            // НИЖНЯЯ ЧАСТЬ
            // =================================================

            const Center(
              child: L10nText('Kusok Game Enterprises',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color:
                  Color(0xFF8A95A6),
                  fontSize: 13,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            const Center(
              child: L10nText('Sad_Smile',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color:
                  Color(0xFFB0BAC8),
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            const Center(
              child: L10nText('© 2026 Kusok Game Enterprises',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color:
                  Color(0xFFB8C1CC),
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================
// СЕКЦИЯ
// ===========================================================

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color:
          const Color(0xFFDCE5F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
            const EdgeInsets.fromLTRB(
              4,
              0,
              4,
              10,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFEAF3FF,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      11,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color:
                    const Color(
                      0xFF4A88EB,
                    ),
                    size: 19,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                L10nText(
                  title,
                  style:
                  const TextStyle(
                    color:
                    Color(0xFF18253A),
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          child,
        ],
      ),
    );
  }
}

// ===========================================================
// ИНФОРМАЦИОННАЯ СТРОКА
// ===========================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 8,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
            BoxDecoration(
              color:
              const Color(0xFFF3F7FC),
              borderRadius:
              BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              icon,
              color:
              const Color(
                0xFF5F7088,
              ),
              size: 21,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                L10nText(
                  title,
                  style:
                  const TextStyle(
                    color:
                    Color(0xFF18253A),
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                L10nText(
                  subtitle,
                  style:
                  const TextStyle(
                    color:
                    Color(0xFF8A95A6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// КНОПКА ССЫЛКИ
// ===========================================================

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
        BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 9,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFEAF3FF,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                  const Color(
                    0xFF4A88EB,
                  ),
                  size: 21,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    L10nText(
                      title,
                      style:
                      const TextStyle(
                        color:
                        Color(
                          0xFF18253A,
                        ),
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    L10nText(
                      subtitle,
                      style:
                      const TextStyle(
                        color:
                        Color(
                          0xFF8A95A6,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                color:
                Color(0xFF9AA8BA),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// РАЗДЕЛИТЕЛЬ
// ===========================================================

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(
      BuildContext context,
      ) {
    return const Padding(
      padding:
      EdgeInsets.only(
        left: 56,
      ),
      child: Divider(
        height: 1,
        thickness: 1,
        color:
        Color(0xFFE8EDF3),
      ),
    );
  }
}
