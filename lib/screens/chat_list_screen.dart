import 'dart:io';

import 'package:flutter/material.dart';

import '../models/chat.dart';
import '../services/chat_store.dart';
import '../services/kge_store.dart';
import '../services/app_localization.dart';
import '../services/profile_store.dart';
import '../services/story_session_store.dart';
import '../widgets/chat_tile.dart';
import 'about_app_screen.dart';
import 'notes_screen.dart';
import '../widgets/l10n_text.dart';
import '../widgets/kge/kge_install_location_overlay.dart';
import '../services/language_store.dart';
import '../services/notes_task_store.dart';

class ChatListScreen extends StatefulWidget {
  final ChatStore store;
  final KgeStore kgeStore;
  final ProfileStore profileStore;

  const ChatListScreen({
    super.key,
    required this.store,
    required this.kgeStore,
    required this.profileStore,
  });

  @override
  State<ChatListScreen> createState() =>
      _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _selectedTab = 0;
  bool _kgeLocationTutorialVisible = false;
  bool _checkingKgeLocationTutorial = false;
  final GlobalKey _kgeTargetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeNotification();
    });
  }

  Future<void> _showWelcomeNotification() async {
    if (!mounted || widget.profileStore.welcomeNotificationShown) {
      return;
    }

    await widget.profileStore.markWelcomeNotificationShown();

    if (!mounted) {
      return;
    }

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: L10n.t('Добро пожаловать в «Связь»!'),
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFD9E5F7),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x24000000),
                        blurRadius: 30,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAF2FF),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.mark_chat_read_rounded,
                              color: Color(0xFF3F83E8),
                              size: 27,
                            ),
                          ),
                          const Spacer(),
                          Material(
                            color: const Color(0xFFEFF3F9),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => Navigator.of(dialogContext).pop(),
                              child: const SizedBox(
                                width: 42,
                                height: 42,
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF66758A),
                                  size: 23,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        L10n.t(
                          'Добро пожаловать в «Связь»!',
                          'Welcome to “Svyaz”!',
                        ),
                        style: const TextStyle(
                          color: Color(0xFF172338),
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        L10n.t(
                          'Благодарим вас за установку нашего мессенджера!\n\nОчень надеемся, что «Связь» вам понравится и станет удобным местом для ваших разговоров.',
                          'Thank you for installing our messenger!\n\nWe sincerely hope you enjoy using “Svyaz” and that it becomes a pleasant place for your conversations.',
                        ),
                        style: const TextStyle(
                          color: Color(0xFF65748A),
                          fontSize: 15.5,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 14),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Color(0xFFE1E8F2),
                            ),
                          ),
                        ),
                        child: Text(
                          L10n.t(
                            'Искренне, команда Kusok Game Enterprises.',
                            'Sincerely, the Kusok Game Enterprises team.',
                          ),
                          style: const TextStyle(
                            color: Color(0xFF3F83E8),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final scale = Tween<double>(begin: 0.92, end: 1.0).animate(curved);
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved);

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
    );
  }

  List<String> get _tabs => const [
    'Все',
    'Личные',
    'Группы',
    'Архив',
  ].map(L10n.t).toList();

  List<Chat> _filteredChats() {
    final chats = widget.store.chats;

    switch (_selectedTab) {
      case 1:
        return chats
            .where(
              (chat) =>
          chat.type == ChatType.personal &&
              !chat.isArchived,
        )
            .toList();

      case 2:
        return chats
            .where(
              (chat) =>
          chat.type == ChatType.group &&
              !chat.isArchived,
        )
            .toList();

      case 3:
        return chats
            .where(
              (chat) => chat.isArchived,
        )
            .toList();

      default:
        return chats
            .where(
              (chat) => !chat.isArchived,
        )
            .toList();
    }
  }

  Future<void> _maybeShowKgeLocationTutorial() async {
    if (_checkingKgeLocationTutorial ||
        _kgeLocationTutorialVisible ||
        !widget.kgeStore.isInstalled ||
        !widget.kgeStore.locationTutorialPending) {
      return;
    }

    _checkingKgeLocationTutorial = true;

    // Показываем подсказку именно после возвращения из чата,
    // если KGE уже установлено.
    await widget.kgeStore.markLocationTutorialSeen();

    if (!mounted) {
      _checkingKgeLocationTutorial = false;
      return;
    }

    setState(() {
      _kgeLocationTutorialVisible = true;
      _checkingKgeLocationTutorial = false;
    });
  }

  void _closeKgeLocationTutorial() {
    if (!mounted) {
      return;
    }

    setState(() {
      _kgeLocationTutorialVisible = false;
    });
  }

  Future<void> _openProfile() async {
    await Navigator.pushNamed(
      context,
      '/profile',
    );

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _openKge() async {
    final result = await Navigator.pushNamed(
      context,
      '/kge',
    );

    if (!mounted || result != true) {
      return;
    }

    _showNiksNotification();
  }

  void _showNiksNotification() {
    final messenger =
    ScaffoldMessenger.of(context);

    messenger.hideCurrentMaterialBanner();

    messenger.showMaterialBanner(
      MaterialBanner(
        backgroundColor: Colors.white,
        elevation: 5,
        leading: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF2FF),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const L10nText('Н',
            style: TextStyle(
              color: Color(0xFF4A88EB),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        content: const Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            L10nText('Никс',
              style: TextStyle(
                color: Color(0xFF18253A),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2),
            L10nText('Ну как? Правда зачёт?',
              style: TextStyle(
                color: Color(0xFF6F7E92),
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              messenger.hideCurrentMaterialBanner();

              Navigator.pushNamed(
                context,
                '/chat',
                arguments: 'nika',
              );
            },
            child: const L10nText('Открыть',
              style: TextStyle(
                color: Color(0xFF1976F3),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.store,
        widget.kgeStore,
        StorySessionStore.instance,
        LanguageStore.instance,
        NotesTaskStore.changes,
      ]),
      builder: (context, _) {
        final chats = _filteredChats();

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            fit: StackFit.expand,
            children: [
              SafeArea(
                child: Column(
                  children: [
                _Header(
                  profileStore:
                  widget.profileStore,
                  kgeInstalled:
                  widget.kgeStore.isInstalled,
                  kgeTargetKey:
                  _kgeTargetKey,
                  onProfile:
                  _openProfile,
                  onKge:
                  _openKge,
                  onSearch: () {
                    Navigator.pushNamed(
                      context,
                      '/search',
                    );
                  },
                  onMenu: () {
                    _showMenu(context);
                  },
                ),

                _Tabs(
                  selectedIndex:
                  _selectedTab,
                  labels: _tabs,
                  onChanged: (index) {
                    setState(() {
                      _selectedTab = index;
                    });
                  },
                ),

                Expanded(
                  child: (_selectedTab != 0 && chats.isEmpty)
                      ? const Center(
                          child: L10nText(
                            'Здесь пока ничего нет',
                            style: TextStyle(
                              color: Color(0xFF8A95A6),
                              fontSize: 15,
                            ),
                          ),
                        )
                      : ListView.separated(
                    padding: const EdgeInsets.only(
                      top: 4,
                      bottom: 12,
                    ),
                    itemCount: chats.length + (_selectedTab == 0 ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        const Divider(
                      height: 1,
                      indent: 84,
                      endIndent: 16,
                      color: Color(0xFFE8EDF3),
                    ),
                    itemBuilder: (context, index) {
                      if (_selectedTab == 0 && index == 0) {
                        return _PinnedNotesTile(
                          chatStore: widget.store,
                          kgeStore: widget.kgeStore,
                          onTap: () async {
                            final currentStage = NotesTaskStore.stage(
                              chatStore: widget.store,
                              kgeStore: widget.kgeStore,
                            );
                            await NotesTaskStore.markSeen(currentStage);
                            if (!context.mounted) return;
                            await Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => NotesScreen(
                                  chatStore: widget.store,
                                  kgeStore: widget.kgeStore,
                                ),
                              ),
                            );
                          },
                        );
                      }

                      final chatIndex =
                          _selectedTab == 0 ? index - 1 : index;
                      final chat = chats[chatIndex];

                      return ChatTile(
                        chat: chat,
                        onTap: () async {
                          if (chat.id == 'nika') {
                            ScaffoldMessenger.of(context)
                                .hideCurrentMaterialBanner();
                          }

                          widget.store.markRead(chat.id);

                          await Navigator.pushNamed(
                            context,
                            '/chat',
                            arguments: chat.id,
                          );

                          await _maybeShowKgeLocationTutorial();
                        },
                      );
                    },
                  ),
                ),
                  ],
                ),
              ),

              if (_kgeLocationTutorialVisible)
                Positioned.fill(
                  child: KgeInstallLocationOverlay(
                    onClose: _closeKgeLocationTutorial,
                    targetKey: _kgeTargetKey,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                ),
                title: const L10nText('Новое сообщение',
                ),
                onTap: () {
                  Navigator.pop(
                    sheetContext,
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.mark_email_read_outlined,
                ),
                title: const L10nText('Отметить всё прочитанным',
                ),
                onTap: () {
                  for (final chat
                  in widget.store.chats) {
                    widget.store.markRead(
                      chat.id,
                    );
                  }

                  Navigator.pop(
                    sheetContext,
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.info_outline_rounded,
                ),
                title: const L10nText('О приложении',
                ),
                onTap: () {
                  Navigator.pop(
                    sheetContext,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const AboutAppScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 8,
              ),
            ],
          ),
        );
      },
    );
  }
}


class _PinnedNotesTile extends StatelessWidget {
  final ChatStore chatStore;
  final KgeStore kgeStore;
  final VoidCallback onTap;

  const _PinnedNotesTile({
    required this.chatStore,
    required this.kgeStore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final stage = NotesTaskStore.stage(
      chatStore: chatStore,
      kgeStore: kgeStore,
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 11, 14, 11),
        color: const Color(0xFFF8FBFF),
        child: Row(
          children: [
            Container(
              width: 53,
              height: 53,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD4E5FB),
                ),
              ),
              alignment: Alignment.center,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Center(child: Icon(Icons.sticky_note_2_outlined, color: Color(0xFF1976F3), size: 26)),
                  if (NotesTaskStore.hasUnreadTask(stage))
                    Positioned(right: -3, top: -3, child: Container(
                      width: 11, height: 11,
                      decoration: BoxDecoration(color: const Color(0xFFFF3B5C), shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5)),
                    )),
                ],
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      L10nText('Заметки',
                        style: TextStyle(
                          color: Color(0xFF101827),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.push_pin_rounded,
                        size: 14,
                        color: Color(0xFF7E9CC2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  L10nText(
                    NotesTaskStore.activeTask(stage),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF728094),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFAAB5C3),
              size: 23,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ProfileStore profileStore;
  final bool kgeInstalled;

  final VoidCallback onProfile;
  final VoidCallback onKge;
  final GlobalKey kgeTargetKey;
  final VoidCallback onSearch;
  final VoidCallback onMenu;

  const _Header({
    required this.profileStore,
    required this.kgeInstalled,
    required this.onProfile,
    required this.onKge,
    required this.kgeTargetKey,
    required this.onSearch,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final avatarPath =
        profileStore.avatarPath;

    final hasAvatar =
        avatarPath != null &&
            avatarPath.isNotEmpty;

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        12,
        8,
        6,
        5,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onProfile,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape:
                BoxShape.circle,
                color:
                const Color(
                  0xFFE8EEF7,
                ),
                border:
                Border.all(
                  color:
                  const Color(
                    0xFFD9E2EF,
                  ),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: hasAvatar
                    ? Image.file(
                  File(avatarPath),
                  fit: BoxFit.cover,
                )
                    : const Icon(
                  Icons
                      .person_outline_rounded,
                  color:
                  Color(
                    0xFF8594A8,
                  ),
                  size: 25,
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          const Expanded(
            child: L10nText('Связь',
              style: TextStyle(
                color:
                Color(0xFF101827),
                fontSize: 27,
                fontWeight:
                FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),

          if (kgeInstalled)
            GestureDetector(
              key: kgeTargetKey,
              onTap: onKge,
              child: Container(
                height: 38,
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 12,
                ),
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFEAF3FF,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    14,
                  ),
                  border:
                  Border.all(
                    color:
                    const Color(
                      0xFFBDD8FF,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons
                          .extension_rounded,
                      color:
                      Color(0xFF4A88EB),
                      size: 18,
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    const L10nText('KGE',
                      style: TextStyle(
                        color:
                        Color(0xFF2D70D8),
                        fontSize: 13,
                        fontWeight:
                        FontWeight
                            .w900,
                        letterSpacing:
                        0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(
            width: 2,
          ),

          IconButton(
            tooltip: L10n.t('Поиск'),
            onPressed: onSearch,
            icon: const Icon(
              Icons.search_rounded,
              size: 27,
            ),
            color:
            const Color(
              0xFF142034,
            ),
          ),

          IconButton(
            tooltip: L10n.t('Меню'),
            onPressed: onMenu,
            icon: const Icon(
              Icons.more_vert_rounded,
              size: 26,
            ),
            color:
            const Color(
              0xFF142034,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _Tabs({
    required this.selectedIndex,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 53,
      child: Row(
        children: List.generate(
          labels.length,
              (index) {
            final selected =
                index == selectedIndex;

            return Expanded(
              child: InkWell(
                onTap: () {
                  onChanged(index);
                },
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        labels[index],
                        style:
                        TextStyle(
                          color: selected
                              ? const Color(
                            0xFF1976F3,
                          )
                              : const Color(
                            0xFF7A8799,
                          ),
                          fontSize: 15,
                          fontWeight:
                          selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),

                    if (selected)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child:
                        Container(
                          height: 3,
                          color:
                          const Color(
                            0xFF1976F3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
