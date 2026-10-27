import 'dart:async';

import 'package:flutter/material.dart';

import 'kge/kge_home_screen.dart';
import 'kge/kge_profile_screen.dart';
import 'kge/kge_orders_screen.dart';
import 'kge/kge_chats_screen.dart';
import '../services/kge_store.dart';
import '../widgets/l10n_text.dart';
import '../services/app_localization.dart';
import '../services/language_store.dart';
import '../services/chat_store.dart';
import '../services/story_session_store.dart';
import '../widgets/kge/kge_shop_unlock_overlay.dart';
import '../widgets/kge/kge_panel.dart';
import '../widgets/kge/kge_notes_unlock_overlay.dart';

class KgeShell extends StatefulWidget {
  final KgeStore kgeStore;
  final ChatStore chatStore;
  final ValueChanged<String>? onNiksNotification;
  final VoidCallback onExit;

  const KgeShell({
    super.key,
    required this.kgeStore,
    required this.chatStore,
    this.onNiksNotification,
    required this.onExit,
  });

  @override
  State<KgeShell> createState() => _KgeShellState();
}

class _KgeShellState extends State<KgeShell> {
  int _selectedIndex = 0;
  bool _profileOpen = false;
  bool _newsArticleOpen = false;
  bool _shopNoticeVisible = false;
  bool _kgeNotesTutorialVisible = false;
  Timer? _shopDialogueTimer;

  final List<String> _titles = const [
    'Главная',
    'Операции',
    'Новости',
  ];

  @override
  void initState() {
    super.initState();
    _prepareShopNotice();
    _prepareKgeNotes();
  }

  bool _isShopActuallyUnlocked() {
    if (!widget.kgeStore.shopUnlocked) {
      return false;
    }

    final niks = widget.chatStore.getChat('nika');

    if (niks == null) {
      return false;
    }

    final stepId = StorySessionStore.instance
        .getForChat(niks)
        .stepId;

    const unlockedSteps = <String>{
      'hackers_reply',
      'shop_followup',
      'shop_agree_reply',
      'system_reply',
      'kge_update',
    };

    return unlockedSteps.contains(stepId);
  }

  @override
  void dispose() {
    _shopDialogueTimer?.cancel();
    super.dispose();
  }

  Future<void> _prepareShopNotice() async {
    if (!_isShopActuallyUnlocked() ||
        widget.kgeStore.shopNoticeSeen) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (!mounted ||
        !_isShopActuallyUnlocked() ||
        widget.kgeStore.shopNoticeSeen) {
      return;
    }

    setState(() {
      _shopNoticeVisible = true;
    });
  }

  Future<void> _closeShopNotice() async {
    if (!mounted) return;

    setState(() {
      _shopNoticeVisible = false;
    });

    await widget.kgeStore.markShopNoticeSeen();
  }

  Future<void> _prepareKgeNotes() async {
    final niks = widget.chatStore.getChat('nika');
    if (niks == null) return;

    final session = StorySessionStore.instance.getForChat(niks);
    if (session.stepId != 'kge_update') return;

    await widget.kgeStore.unlockKgeNotes();
    if (!mounted || widget.kgeStore.kgeNotesTutorialSeen) return;

    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!mounted || widget.kgeStore.kgeNotesTutorialSeen) return;

    setState(() => _kgeNotesTutorialVisible = true);
  }

  Future<void> _closeKgeNotesTutorial() async {
    if (mounted) {
      setState(() => _kgeNotesTutorialVisible = false);
    }
    await widget.kgeStore.markKgeNotesTutorialSeen();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      _scheduleShopDialogue();
    }
  }

  void _scheduleShopDialogue() {
    if (_shopDialogueTimer != null ||
        !_isShopActuallyUnlocked()) {
      return;
    }

    final niks = widget.chatStore.getChat('nika');

    if (niks == null) {
      return;
    }

    final session = StorySessionStore.instance.getForChat(niks);

    if (session.stepId != 'hackers_reply') {
      return;
    }

    _shopDialogueTimer = Timer(
      const Duration(seconds: 3),
      () async {
        _shopDialogueTimer = null;

        if (!mounted) {
          return;
        }

        final currentNiks = widget.chatStore.getChat('nika');

        if (currentNiks == null) {
          return;
        }

        final currentSession =
            StorySessionStore.instance.getForChat(currentNiks);
        final beforeCount = currentSession.messages.length;

        final triggered = await StorySessionStore.instance
            .triggerAfterShopChecked(currentNiks);

        if (!triggered || !mounted) {
          return;
        }

        for (final message
            in currentSession.messages.skip(beforeCount)) {
          if (!message.isMine) {
            widget.chatStore.addIncomingMessage(
              currentNiks.id,
              message.text,
            );
          }
        }

        widget.onNiksNotification?.call('Ну что?');
      },
    );
  }

  bool _isOperationsUnlocked() {
    final niks = widget.chatStore.getChat('nika');

    if (niks == null) {
      return false;
    }

    final stepId = StorySessionStore.instance
        .getForChat(niks)
        .stepId;

    return stepId == 'kge_update';
  }

  bool _isLivenNewsUnlocked() {
    // The robbery article becomes available only after LIVEN has sent
    // the final instruction for the first task.
    final session =
        StorySessionStore.instance.getByChatId('kge_liven');

    if (session == null) {
      return false;
    }

    return session.messages.any(
      (message) => message.text.trim() == 'Дерзай!',
    );
  }

  void _openProfile() {
    if (_profileOpen) return;

    setState(() {
      _profileOpen = true;
    });
  }

  void _closeProfile() {
    if (!_profileOpen) return;

    setState(() {
      _profileOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        KgeStore.instance,
        LanguageStore.instance,
        widget.chatStore,
        StorySessionStore.instance,
      ]),
      builder: (context, _) {
        final theme = KgeStore.instance.colorTheme;
        final showShopNotice =
            _shopNoticeVisible &&
            !_profileOpen &&
            !_kgeNotesTutorialVisible &&
            _selectedIndex == 0 &&
            _isShopActuallyUnlocked();

        return Stack(
          fit: StackFit.expand,
          children: [
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _buildAppBar(theme),
              body: _profileOpen
                  ? KgeProfileScreen(
                      onBack: _closeProfile,
                      chatStore: widget.chatStore,
                    )
                  : _newsArticleOpen && _selectedIndex == 2
                      ? _LivenRobberyArticlePage(
                          onBack: () => setState(() => _newsArticleOpen = false),
                        )
                      : IndexedStack(
                      index: _selectedIndex,
                      children: [
                        const KgeHomeScreen(),
                        _OperationsPage(
                          shopUnlocked: _isShopActuallyUnlocked() && _isLivenNewsUnlocked(),
                          accessUnlocked: _isOperationsUnlocked(),
                          chatStore: widget.chatStore,
                        ),
                        _KgeNewsPage(
                          unlocked: _isLivenNewsUnlocked(),
                          onOpenArticle: () {
                            setState(() => _newsArticleOpen = true);
                          },
                        ),
                      ],
                    ),
              bottomNavigationBar: _profileOpen || _newsArticleOpen
                  ? null
                  : _buildNavigationBar(theme),
            ),

            if (showShopNotice)
              KgeShopUnlockOverlay(
                theme: theme,
                onClose: _closeShopNotice,
              ),

            if (_kgeNotesTutorialVisible)
              KgeNotesUnlockOverlay(
                theme: theme,
                onClose: _closeKgeNotesTutorial,
              ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(KgeColorTheme theme) {
    final title = _profileOpen
        ? 'Профиль'
        : _newsArticleOpen && _selectedIndex == 2
            ? 'Новости'
            : _titles[_selectedIndex];

    return AppBar(
      backgroundColor: const Color(0xD006040B),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        tooltip: L10n.t(_profileOpen ? 'Назад' : 'Выйти'),
        onPressed: _profileOpen
            ? _closeProfile
            : _newsArticleOpen && _selectedIndex == 2
                ? () => setState(() => _newsArticleOpen = false)
                : widget.onExit,
        icon: Icon(
          Icons.arrow_back_rounded,
          color: theme.brightText,
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          GestureDetector(
            onTap: _openProfile,
            behavior: HitTestBehavior.opaque,
            child: _KgeMiniLogo(theme: theme),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              L10nText(
                'KGE',
                style: TextStyle(
                  color: theme.brightText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                L10n.t(title).toUpperCase(),
                style: TextStyle(
                  color: theme.subtitle,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0x16160022),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.panelBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                color: theme.primary,
                size: 7,
              ),
              const SizedBox(width: 6),
              L10nText(
                'ONLINE',
                style: TextStyle(
                  color: theme.secondaryText,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationBar(KgeColorTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xE906040B),
        border: Border(
          top: BorderSide(
            color: theme.panelBorder,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            10,
            8,
            10,
            8,
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Главная',
                  selected: _selectedIndex == 0,
                  theme: theme,
                  onTap: () => _selectPage(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.hub_rounded,
                  label: 'Операции',
                  selected: _selectedIndex == 1,
                  theme: theme,
                  onTap: () => _selectPage(1),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.newspaper_rounded,
                  label: 'Новости',
                  selected: _selectedIndex == 2,
                  theme: theme,
                  onTap: () => _selectPage(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final KgeColorTheme theme;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.primary.withOpacity(0.11)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 21,
              color: selected
                  ? theme.primary
                  : theme.mutedText,
            ),
            const SizedBox(height: 4),
            L10nText(
              label,
              style: TextStyle(
                color: selected
                    ? theme.brightText
                    : theme.mutedText,
                fontSize: 9,
                fontWeight: selected
                    ? FontWeight.w800
                    : FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KgeMiniLogo extends StatelessWidget {
  final KgeColorTheme theme;

  const _KgeMiniLogo({
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.primary,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(0.28),
            blurRadius: 12,
          ),
        ],
      ),
      child: Center(
        child: L10nText(
          'K',
          style: TextStyle(
            color: theme.brightText,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class _OperationsPage extends StatelessWidget {
  final bool shopUnlocked;
  final bool accessUnlocked;
  final ChatStore chatStore;

  const _OperationsPage({
    required this.shopUnlocked,
    required this.accessUnlocked,
    required this.chatStore,
  });

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return ColoredBox(
            color: const Color(0xFF020107),
            child: page,
          );
        },
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curved),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.035, 0.0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = KgeStore.instance.colorTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          L10nText(
            'ОПЕРАЦИИ',
            style: TextStyle(
              color: theme.brightText,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 5),
          L10nText(
            accessUnlocked
                ? 'СТАТУС // СИСТЕМА АКТИВНА'
                : 'СТАТУС // ДОСТУП ОГРАНИЧЕН',
            style: TextStyle(
              color: accessUnlocked ? theme.primary : theme.mutedText,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          if (accessUnlocked) ...[
            _OperationCard(
              icon: KgeStore.instance.newbiePackInstalled
                  ? Icons.assignment_turned_in_outlined
                  : Icons.assignment_outlined,
              title: 'ЗАКАЗЫ',
              subtitle: KgeStore.instance.newbiePackInstalled
                  ? 'Новый заказ от LIVEN ожидает выполнения.'
                  : 'Сначала купите и установите набор «Новичок».',
              status: KgeStore.instance.newbiePackInstalled
                  ? '1 НОВЫЙ ЗАКАЗ'
                  : 'ЗАБЛОКИРОВАНО // НЕТ НАБОРА',
              theme: theme,
              onTap: () => _openPage(
                context,
                const KgeOrdersScreen(),
              ),
              locked: !KgeStore.instance.newbiePackInstalled,
            ),
            const SizedBox(height: 12),
            _OperationCard(
              icon: Icons.forum_outlined,
              title: 'ЧАТЫ',
              subtitle: 'Переписки с клиентами.',
              status: 'ПУСТО',
              theme: theme,
              onTap: () => _openPage(
                context,
                KgeChatsScreen(chatStore: chatStore),
              ),
            ),
            const SizedBox(height: 12),
          ],
          _OperationCard(
            icon: shopUnlocked
                ? Icons.shopping_bag_outlined
                : Icons.lock_outline_rounded,
            title: 'МАГАЗИН KGE',
            subtitle: !shopUnlocked
                ? 'Магазин пока недоступен.'
                : KgeStore.instance.newbiePackInstalled
                    ? 'Набор «Новичок» установлен.'
                    : 'Набор для новичка доступен бесплатно.',
            status: !shopUnlocked
                ? 'ЗАБЛОКИРОВАН'
                : KgeStore.instance.newbiePackInstalled
                    ? 'НАБОР УСТАНОВЛЕН'
                    : '1 ТОВАР // \$0',
            theme: theme,
            locked: !shopUnlocked,
            onTap: shopUnlocked
                ? () => _openPage(
                      context,
                      const _ShopPage(unlocked: true),
                    )
                : null,
          ),
        ],
      ),
    );
  }
}

class _OperationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final KgeColorTheme theme;
  final VoidCallback? onTap;
  final bool locked;

  const _OperationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.theme,
    required this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = KgePanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: locked
                  ? theme.mutedText.withOpacity(0.06)
                  : theme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: theme.panelBorder,
              ),
            ),
            child: Icon(
              icon,
              color: locked ? theme.mutedText : theme.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                L10nText(
                  title,
                  style: TextStyle(
                    color: theme.brightText,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                L10nText(
                  subtitle,
                  style: TextStyle(
                    color: theme.subtitle,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                L10nText(
                  status,
                  style: TextStyle(
                    color: locked ? theme.mutedText : theme.primary,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              color: theme.mutedText,
            ),
        ],
      ),
    );

    if (onTap == null) {
      return child;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: child,
    );
  }
}

class _ShopPage extends StatelessWidget {
  final bool unlocked;

  const _ShopPage({super.key, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: KgeStore.instance,
      builder: (context, _) {
        final store = KgeStore.instance;
        final theme = store.colorTheme;
        final installed = store.newbiePackInstalled;
        return Scaffold(
          backgroundColor: const Color(0xFF020107),
          appBar: AppBar(
            backgroundColor: const Color(0xD006040B),
            foregroundColor: theme.brightText,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: const L10nText(
              'Интернет-магазин KGE',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          body: !unlocked
              ? const _PlaceholderPage(
                  title: 'МАГАЗИН ЗАБЛОКИРОВАН',
                  description: 'Доступ к магазину ещё не получен.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
                  children: [
                    L10nText(
                      'НАБОРЫ И ИНСТРУМЕНТЫ',
                      style: TextStyle(
                        color: theme.brightText,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    L10nText(
                      'Доступен один стартовый набор.',
                      style: TextStyle(color: theme.subtitle, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    KgePanel(
                      padding: const EdgeInsets.all(17),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: theme.primary.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: theme.panelBorder),
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: theme.primary,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    L10nText(
                                      'Набор для новичка',
                                      style: TextStyle(
                                        color: theme.brightText,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    L10nText(
                                      'Новичок',
                                      style: TextStyle(
                                        color: theme.subtitle,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      '\$0',
                                      style: TextStyle(
                                        color: theme.primary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.innerBorder),
                            ),
                            child: L10nText(
                              installed
                                  ? 'Набор приобретён и установлен в расширение KGE.'
                                  : 'Стартовый комплект для первого заказа. После покупки он сразу установится в KGE.',
                              style: TextStyle(
                                color: theme.bodyText,
                                fontSize: 12,
                                height: 1.45,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: installed
                                  ? null
                                  : () async {
                                      await store.purchaseAndInstallNewbiePack();
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Набор «Новичок» куплен и установлен.'),
                                          backgroundColor: const Color(0xE6110A1B),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    },
                              icon: Icon(installed ? Icons.check_circle_rounded : Icons.download_done_rounded),
                              label: L10nText(
                                installed ? 'УСТАНОВЛЕНО' : 'КУПИТЬ ЗА \$0',
                                style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.7),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primary.withOpacity(installed ? 0.18 : 0.95),
                                foregroundColor: theme.brightText,
                                disabledBackgroundColor: theme.primary.withOpacity(0.12),
                                disabledForegroundColor: theme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
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
}

class _KgeNewsPage extends StatelessWidget {
  final bool unlocked;
  final VoidCallback onOpenArticle;

  const _KgeNewsPage({
    required this.unlocked,
    required this.onOpenArticle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KgeStore.instance.colorTheme;
    if (!unlocked) {
      return const _PlaceholderPage(
        title: 'Новости',
        description: 'Новостей нет',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        Text(
          'ПОСЛЕДНИЕ СОБЫТИЯ',
          style: TextStyle(
            color: theme.subtitle,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: const Color(0xFF100A19),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onOpenArticle,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.primary.withOpacity(0.45)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/kge/Grab1.png',
                      width: 104,
                      height: 86,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ограбление 13lenen',
                          style: TextStyle(
                            color: theme.brightText,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Вчера был ограблен небольшой частный магазин.',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.subtitle,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Читать статью',
                              style: TextStyle(
                                color: theme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded,
                                size: 13, color: theme.primary),
                          ],
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
  }
}

class _LivenRobberyArticlePage extends StatelessWidget {
  final VoidCallback onBack;

  const _LivenRobberyArticlePage({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = KgeStore.instance.colorTheme;
    return Container(
      color: const Color(0xFF08070A),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EBDD),
            border: Border.all(color: const Color(0xFFB7AD98), width: 1.2),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 22, offset: Offset(0, 8)),
            ],
          ),
          child: DefaultTextStyle(
            style: const TextStyle(color: Color(0xFF211E1A)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'BRTV',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                const Divider(color: Color(0xFF4C463D), thickness: 1.2),
                const SizedBox(height: 5),
                const Text(
                  'НОВОСТИ  •  ПРОИСШЕСТВИЯ' ,
                  style: TextStyle(fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 13),
                const Text(
                  'Ограбление 13lenen',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 30,
                    height: 1.03,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Вчера был ограблен небольшой частный магазин «13lenen».',
                  style: TextStyle(fontFamily: 'serif', fontSize: 16, height: 1.45, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 13),
                const Text(
                  'Согласно предварительным данным и записям камер видеонаблюдения, подозреваемые были вооружены пистолетами Glock 19. Полиция осматривает место преступления и прилегающую территорию. Обстоятельства произошедшего устанавливаются.',
                  style: TextStyle(fontFamily: 'serif', fontSize: 14, height: 1.65),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Image.asset(
                    'assets/kge/Grab1.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Кадр с камеры видеонаблюдения. Изображение предоставлено следствием.',
                  style: TextStyle(fontFamily: 'serif', fontSize: 10, fontStyle: FontStyle.italic, height: 1.4),
                ),
                const SizedBox(height: 17),
                const Divider(color: Color(0xFF4C463D)),
                Text(
                  'Материал подготовлен редакцией BRTV',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF4C463D),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onBack,
                    icon: Icon(Icons.arrow_back_rounded, color: theme.primary),
                    label: Text('Назад к новостям', style: TextStyle(color: theme.primary, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final String description;

  const _PlaceholderPage({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KgeStore.instance.colorTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primary.withOpacity(0.10),
                border: Border.all(
                  color: theme.panelBorder,
                ),
              ),
              child: Icon(
                Icons.code_rounded,
                color: theme.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            L10nText(
              title,
              style: TextStyle(
                color: theme.brightText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            L10nText(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.subtitle,
                fontSize: 13,
                height: 1.5,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
