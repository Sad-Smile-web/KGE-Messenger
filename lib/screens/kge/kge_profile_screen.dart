import 'package:flutter/material.dart';

import '../../services/kge_store.dart';
import '../../services/chat_store.dart';
import '../../services/notes_task_store.dart';
import '../../services/story_session_store.dart';
import '../../services/profile_store.dart';
import '../../widgets/kge/kge_panel.dart';
import '../../widgets/l10n_text.dart';

class KgeProfileScreen extends StatefulWidget {
  final VoidCallback onBack;
  final ChatStore chatStore;

  const KgeProfileScreen({
    super.key,
    required this.onBack,
    required this.chatStore,
  });

  @override
  State<KgeProfileScreen> createState() => _KgeProfileScreenState();
}

class _KgeProfileScreenState extends State<KgeProfileScreen> {
  bool _settingsOpen = false;
  bool _notesOpen = false;

  void _openSettings() {
    setState(() {
      _settingsOpen = true;
    });
  }

  void _closeSettings() {
    setState(() {
      _settingsOpen = false;
    });
  }

  void _openNotes() {
    setState(() => _notesOpen = true);
  }

  void _closeNotes() {
    setState(() => _notesOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_settingsOpen) return _buildSettings();
    if (_notesOpen) return _buildKgeNotes();
    return _buildProfile();
  }

  Widget _buildProfile() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        KgeStore.instance,
      ]),
      builder: (context, _) {
        final theme = KgeStore.instance.colorTheme;
        final profile = ProfileStore.instance;
        final nickname = profile.nickname.trim().isEmpty
            ? 'Пользователь'
            : profile.nickname.trim();

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 26, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(
                  title: 'ПРОФИЛЬ',
                  onBack: widget.onBack,
                ),
                const SizedBox(height: 14),
                KgePanel(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                  child: Column(
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                            color: theme.primary,
                            width: 1.3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primary.withOpacity(0.22),
                              blurRadius: 22,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Container(
                            color: theme.primary.withOpacity(0.08),
                            alignment: Alignment.center,
                            child: Text(
                              _initials(nickname),
                              style: TextStyle(
                                color: theme.brightText,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        nickname,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.brightText,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.1,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 5),
                      L10nText('НИКНЕЙМ',
                        style: TextStyle(
                          color: theme.subtitle,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primary.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: theme.primary.withOpacity(0.22),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.primary.withOpacity(0.12),
                              ),
                              child: Icon(
                                Icons.star_rounded,
                                color: theme.primary,
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  L10nText('РЕПУТАЦИЯ',
                                    style: TextStyle(
                                      color: theme.subtitle,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  L10nText('${profile.reputation}',
                                    style: TextStyle(
                                      color: theme.brightText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      decoration: TextDecoration.none,
                                    ),
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
                const SizedBox(height: 12),
                KgePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KgeSectionTitle(
                        title: 'ПРОФИЛЬ KGE',
                        subtitle: 'Настройки интерфейса и оформления',
                      ),
                      const SizedBox(height: 16),
                      if (KgeStore.instance.kgeNotesUnlocked) ...[
                        _ProfileButton(
                          icon: Icons.sticky_note_2_rounded,
                          title: 'Заметки KGE',
                          subtitle: 'Сюжетные задания расширения',
                          onTap: _openNotes,
                        ),
                        const SizedBox(height: 9),
                      ],
                      _ProfileButton(
                        icon: Icons.settings_rounded,
                        title: 'Настройки',
                        subtitle: 'Цвет интерфейса и другие параметры',
                        onTap: _openSettings,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKgeNotes() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.chatStore,
        KgeStore.instance,
        StorySessionStore.instance,
      ]),
      builder: (context, _) {
        final theme = KgeStore.instance.colorTheme;
        final isCompleted = KgeStore.instance.kgeChatsChecked;

        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                child: _TopBar(
                  title: 'ЗАДАНИЯ KGE',
                  onBack: _closeNotes,
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                  children: [
                    KgePanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KgeSectionTitle(
                            title: 'ЗАМЕТКИ KGE',
                            subtitle: 'Задания, связанные только с расширением',
                          ),
                          const SizedBox(height: 12),
                          Builder(
                            builder: (context) {
                              final livenSession = StorySessionStore.instance
                                  .getByChatId('kge_liven');
                              final livenJobAvailable = livenSession?.messages.any(
                                    (message) => message.text.trim() == 'Дерзай!',
                                  ) ??
                                  false;
                              final packInstalled = KgeStore.instance.newbiePackInstalled;
                              final completedTasks = <String>[];
                              if (isCompleted) {
                                completedTasks.add('Проверить чаты');
                              }
                              if (livenJobAvailable && packInstalled) {
                                completedTasks.add('Зайти в магазин и купить «Новичок»');
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (completedTasks.isNotEmpty)
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        dividerColor: Colors.transparent,
                                        splashColor: theme.primary.withOpacity(0.08),
                                        highlightColor: Colors.transparent,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: theme.primary.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(13),
                                          border: Border.all(color: theme.primary.withOpacity(0.20)),
                                        ),
                                        child: ExpansionTile(
                                          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                                          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                          leading: Icon(Icons.task_alt_rounded, color: theme.primary),
                                          title: L10nText(
                                            'Выполненные задания',
                                            style: TextStyle(
                                              color: theme.brightText,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                            ),
                                          ),
                                          subtitle: L10nText(
                                            'Выполнено: ${completedTasks.length}',
                                            style: TextStyle(color: theme.subtitle, fontSize: 11),
                                          ),
                                          children: [
                                            for (final task in completedTasks)
                                              Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.only(bottom: 7),
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: theme.primary.withOpacity(0.05),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Icon(Icons.check_circle_rounded, color: theme.primary, size: 18),
                                                    const SizedBox(width: 9),
                                                    Expanded(
                                                      child: L10nText(
                                                        task,
                                                        style: TextStyle(
                                                          color: theme.subtitle,
                                                          fontSize: 12,
                                                          height: 1.4,
                                                          decoration: TextDecoration.lineThrough,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (!isCompleted)
                                    _buildKgeTaskRow(theme, 'Проверить чаты', completed: false),
                                  if (livenJobAvailable && !packInstalled) ...[
                                    if (completedTasks.isNotEmpty || !isCompleted) const SizedBox(height: 9),
                                    _buildKgeTaskRow(
                                      theme,
                                      'Зайти в магазин и купить «Новичок»',
                                      completed: false,
                                    ),
                                  ],
                                  if (livenJobAvailable && packInstalled) ...[
                                    if (completedTasks.isNotEmpty || !isCompleted) const SizedBox(height: 9),
                                    _buildKgeTaskRow(
                                      theme,
                                      'Выполнить свой первый заказ',
                                      completed: false,
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          L10nText(
                            'Новые задания появятся по мере развития истории.',
                            style: TextStyle(
                              color: theme.subtitle,
                              fontSize: 11,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKgeTaskRow(KgeColorTheme theme, String label, {required bool completed}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: theme.primary.withOpacity(0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: completed ? theme.primary : theme.mutedText,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: L10nText(
              label,
              style: TextStyle(
                color: completed ? theme.subtitle : theme.brightText,
                fontSize: 12,
                height: 1.4,
                decoration: completed ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: _TopBar(
              title: 'НАСТРОЙКИ',
              onBack: _closeSettings,
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: KgeStore.instance,
              builder: (context, _) {
                final currentTheme = KgeStore.instance.colorTheme;

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                  children: [
                    KgePanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const KgeSectionTitle(
                            title: 'ЦВЕТ ИНТЕРФЕЙСА',
                            subtitle: 'Выберите основную цветовую схему KGE',
                          ),
                          const SizedBox(height: 16),
                          for (final option in KgeColorTheme.values) ...[
                            _ThemeOption(
                              theme: option,
                              selected: currentTheme == option,
                              onTap: () {
                                KgeStore.instance.setColorTheme(option);
                              },
                            ),
                            if (option != KgeColorTheme.values.last)
                              const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KgeStore.instance.colorTheme;

    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0x12000000),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.innerBorder,
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: theme.brightText,
                size: 23,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        L10nText(
          title,
          style: TextStyle(
            color: theme.brightText,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: KgeStore.instance,
      builder: (context, _) {
        final theme = KgeStore.instance.colorTheme;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Ink(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0x11000000),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.innerBorder,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.primary.withOpacity(0.35),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: theme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        L10nText(
                          title,
                          style: TextStyle(
                            color: theme.brightText,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 3),
                        L10nText(
                          subtitle,
                          style: TextStyle(
                            color: theme.subtitle,
                            fontSize: 11,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.mutedText,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final KgeColorTheme theme;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: KgeStore.instance,
      builder: (context, _) {
        final current = KgeStore.instance.colorTheme;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: onTap,
            child: Ink(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? theme.primary.withOpacity(0.09)
                    : const Color(0x09000000),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: selected
                      ? theme.primary.withOpacity(0.7)
                      : current.innerBorder,
                  width: selected ? 1.2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primary.withOpacity(0.45),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: L10nText(
                      theme.label,
                      style: TextStyle(
                        color: current.brightText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_rounded,
                      color: theme.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
