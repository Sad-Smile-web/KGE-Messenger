import 'package:flutter/material.dart';

import '../data/niks_story.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../services/chat_store.dart';
import '../services/app_localization.dart';
import '../services/kge_store.dart';
import '../services/story_session_store.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/l10n_text.dart';

class ChatScreen extends StatefulWidget {
  final ChatStore store;
  final KgeStore kgeStore;
  final Chat chat;
  final Future<void> Function()? onBadEndingExit;

  const ChatScreen({
    super.key,
    required this.store,
    required this.kgeStore,
    required this.chat,
    this.onBadEndingExit,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController =
  ScrollController();

  late StorySessionState _story;

  bool get _isNiksChat => widget.chat.id == 'nika';

  bool get _isStoryChat => _isNiksChat;

  bool _kgeInstallInProgress = false;
  bool _endingExitStarted = false;
  bool _allowEndingPop = false;

  bool get _shouldShowBadEndingOnExit =>
      _isNiksChat && StorySessionStore.instance.badEndingPending;

  @override
  void initState() {
    super.initState();

    _story =
        StorySessionStore.instance
            .getForChat(widget.chat);

    widget.store.markRead(
      widget.chat.id,
    );

    StorySessionStore.instance.addListener(_onStoryChanged);

    WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToBottom(),
    );
  }

  void _onStoryChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _updateStory(void Function() update) {
    update();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    StorySessionStore.instance.removeListener(_onStoryChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration:
      const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Message _createStoryMessage({
    required String text,
    required bool isMine,
  }) {
    return Message(
      id:
      'story-${DateTime.now().microsecondsSinceEpoch}-${isMine ? 'mine' : 'reply'}',
      text: text,
      isMine: isMine,
      time: DateTime.now(),
      status: MessageStatus.read,
    );
  }

  List<StoryChoice> _currentChoices() {
    if (!_isStoryChat || _story.stepId == null) {
      return const [];
    }

    final step = NiksStory.getStep(_story.stepId!);
    return step?.choices ?? const [];
  }

  Future<void> _handleChatBack() async {
    if (!_shouldShowBadEndingOnExit) {
      if (mounted) Navigator.pop(context);
      return;
    }
    await _showDeletedExtensionNoticeAndEnding();
  }

  Future<void> _showDeletedExtensionNoticeAndEnding() async {
    if (_endingExitStarted) return;
    _endingExitStarted = true;

    // Run a visible removal/loading sequence only after the player leaves
    // Niks's chat. The extension is actually uninstalled when the animation
    // completes, then the black ending screen is opened.
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: L10n.t('Удаление расширения KGE'),
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return const _KgeRemovalProgressScreen();
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(opacity: curved, child: child);
      },
    );

    if (!mounted) return;
    setState(() => _allowEndingPop = true);
    await widget.kgeStore.uninstall();
    await StorySessionStore.instance.clearBadEndingPending();
    await widget.onBadEndingExit?.call();
  }

  Future<void> _saveStory() async {
    if (!_isStoryChat) return;

    await StorySessionStore.instance.saveForChat(widget.chat.id);
  }

  Future<void> _selectStoryChoice(
      StoryChoice choice,
      ) async {
    if (!_isStoryChat || _story.choiceLocked) return;

    final nextStepId = NiksStory.getNextStep(choice.id);

    if (nextStepId == null) {
      _updateStory(() {
        _story.messages.add(
          _createStoryMessage(
            text: choice.text,
            isMine: true,
          ),
        );

        _story.choiceLocked = true;
        _story.stepId = null;
      });

      await _saveStory();

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback(
              (_) => _scrollToBottom(),
        );
      }

      return;
    }

    final nextStep = NiksStory.getStep(nextStepId);

    if (nextStep == null) {
      return;
    }

    // Сначала показываем сообщение игрока.
    _updateStory(() {
      _story.messages.add(
        _createStoryMessage(
          text: choice.text,
          isMine: true,
        ),
      );

      _story.choiceLocked = true;
      _story.stepId = null;

      if (nextStep.showKgeApk) {
        _story.showKgeFile = true;
      }

      if (nextStep.messages.isNotEmpty) {
        _story.storyTyping = true;
      }
    });

    await _saveStory();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
      );
    }

    // Печатает перед первым ответом.
    if (nextStep.messages.isNotEmpty) {
      await Future<void>.delayed(
        const Duration(
          milliseconds: 900,
        ),
      );
    }

    for (int i = 0;
    i < nextStep.messages.length;
    i++) {
      // Если это второе и последующее сообщение
      // и для шага включена имитация печати,
      // показываем typing indicator.
      if (i > 0 &&
          nextStep.typingBetweenMessages) {
        _updateStory(() {
          _story.storyTyping = true;
        });

        await _saveStory();

        await Future<void>.delayed(
          nextStep.typingDelay,
        );

      }

      _updateStory(() {
        _story.storyTyping = false;

        _story.messages.add(
          _createStoryMessage(
            text: nextStep.messages[i],
            isMine: false,
          ),
        );
      });

      await _saveStory();

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback(
              (_) => _scrollToBottom(),
        );
      }
    }

    _updateStory(() {
      _story.storyTyping = false;
      if (nextStep.id == 'kge_removed_niks_final') {
        // Финальная реплика завершает диалог; выход из чата запустит концовку.
        _story.stepId = null;
        _story.choiceLocked = true;
      } else {
        _story.stepId = nextStep.id;
        _story.choiceLocked = false;
      }

      if (nextStep.showKgeApk) {
        _story.showKgeFile = true;
      }
    });

    if (nextStep.id == 'kge_removed_niks_final') {
      await StorySessionStore.instance.markBadEndingPending();
    }

    // Магазин KGE разблокируется только после полной финальной сцены.
    if (nextStep.unlockShop) {
      await widget.kgeStore.unlockShop();
    }

    await _saveStory();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToBottom(),
    );
  }

  Future<void> _installKge() async {
    if (widget.kgeStore.isInstalled ||
        _kgeInstallInProgress) {
      return;
    }

    setState(() {
      _kgeInstallInProgress = true;
    });

    // Сначала имитируем скачивание, затем установку.
    // Это только сюжетная анимация — реальный APK не скачивается.
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: L10n.t('Установка KGE'),
      barrierColor: const Color(0x99000000),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return const _KgeInstallProgressDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.94,
              end: 1.0,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    await widget.kgeStore.install();

    if (!mounted) {
      return;
    }

    setState(() {
      _kgeInstallInProgress = false;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: L10nText(
                  'Расширение KGE установлено',
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final chat =
    widget.store.getChat(
      widget.chat.id,
    );

    if (chat == null) {
      return const Scaffold(
        body: Center(
          child: L10nText('Чат не найден',
          ),
        ),
      );
    }

    final isTyping =
        _story.storyTyping ||
            widget.store.isTyping(
              chat.id,
            );

    final choices =
    _currentChoices();

    final totalItems =
        _story.messages.length +
            (_story.showKgeFile ? 1 : 0) +
            (isTyping ? 1 : 0);

    return PopScope<Object?>(
      canPop: !_shouldShowBadEndingOnExit || _allowEndingPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _shouldShowBadEndingOnExit && !_endingExitStarted) {
          _showDeletedExtensionNoticeAndEnding();
        }
      },
      child: Scaffold(
      resizeToAvoidBottomInset:
      true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: _handleChatBack,
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            _Avatar(chat: chat),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                L10nText(
                  chat.name,
                  style: const TextStyle(
                    color:
                    Color(0xFF111827),
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                L10nText(
                  isTyping
                      ? 'печатает...'
                      : chat.isOnline
                      ? 'в сети'
                      : 'был(а) недавно',
                  style:
                  TextStyle(
                    color: isTyping
                        ? const Color(
                      0xFF1976F3,
                    )
                        : const Color(
                      0xFF7D8899,
                    ),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.call_outlined,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert_rounded,
            ),
          ),
        ],
      ),
      body: Container(
        decoration:
        const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/backgrounds/chat_screen.png',
            ),
            fit: BoxFit.cover,
            opacity: 0.9,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller:
                _scrollController,
                padding:
                const EdgeInsets.only(
                  top: 12,
                  bottom: 12,
                ),
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,
                itemCount:
                totalItems,
                itemBuilder:
                    (context, index) {
                  // ---------------------------------------------------
                  // СООБЩЕНИЯ ИЗ СЮЖЕТА
                  // ---------------------------------------------------

                  if (index <
                      _story.messages.length) {
                    return MessageBubble(
                      message:
                      _story.messages[index],
                    );
                  }

                  // ---------------------------------------------------
                  // KGE.APK
                  // ---------------------------------------------------

                  int currentIndex =
                      _story.messages.length;

                  if (_story.showKgeFile) {
                    if (index ==
                        currentIndex) {
                      return _KgeApkMessage(
                        installed:
                        widget.kgeStore
                            .isInstalled,
                        onTap:
                        _installKge,
                      );
                    }

                    currentIndex++;
                  }

                  // ---------------------------------------------------
                  // ПЕЧАТАЕТ...
                  // ---------------------------------------------------

                  if (isTyping &&
                      index ==
                          currentIndex) {
                    return const TypingIndicator();
                  }

                  return const SizedBox
                      .shrink();
                },
              ),
            ),

            // ---------------------------------------------------------
            // ВАРИАНТЫ ОТВЕТА
            // ---------------------------------------------------------

            if (_isStoryChat &&
                choices.isNotEmpty)
              _StoryChoices(
                choices:
                choices,
                enabled:
                !_story.choiceLocked,
                onChoiceSelected:
                _selectStoryChoice,
              )
            else ...[
              const Divider(
                height: 1,
                color:
                Color(0x22000000),
              ),
              MessageInput(
                enabled: false,
                onSend: (_) {},
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }
}

// ===========================================================================
// ВЫБОР ОТВЕТА
// ===========================================================================

class _StoryChoices
    extends StatelessWidget {
  final List<StoryChoice> choices;
  final bool enabled;

  final ValueChanged<StoryChoice>
  onChoiceSelected;

  const _StoryChoices({
    required this.choices,
    required this.enabled,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding:
        const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          10,
        ),
        decoration:
        const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0x16000000),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding:
              EdgeInsets.only(
                left: 4,
                bottom: 7,
              ),
              child: L10nText('Выберите ответ',
                style:
                TextStyle(
                  color:
                  Color(0xFF8A95A6),
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
            for (int i = 0;
            i < choices.length;
            i++) ...[
              SizedBox(
                height: 48,
                child: Material(
                  color:
                  const Color(0xFFEAF2FF),
                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                  child: InkWell(
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                    onTap: enabled
                        ? () {
                      onChoiceSelected(
                        choices[i],
                      );
                    }
                        : null,
                    child: Center(
                      child: Padding(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 10,
                        ),
                        child: L10nText(
                          choices[i].text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color:
                            Color(
                              0xFF1976F3,
                            ),
                            fontSize: 15,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (i !=
                  choices.length - 1)
                const SizedBox(
                  height: 7,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// АНИМАЦИЯ УДАЛЕНИЯ KGE
// ===========================================================================

class _KgeRemovalProgressScreen extends StatefulWidget {
  const _KgeRemovalProgressScreen();

  @override
  State<_KgeRemovalProgressScreen> createState() =>
      _KgeRemovalProgressScreenState();
}

class _KgeRemovalProgressScreenState extends State<_KgeRemovalProgressScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;
  bool _complete = false;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _complete = true);
          Future<void>.delayed(const Duration(milliseconds: 850), () {
            if (mounted) Navigator.of(context).pop();
          });
        }
      });
    _progress.forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  String get _status {
    if (_complete) return 'Расширение KGE было удалено!';
    final value = _progress.value;
    if (value < 0.22) return 'Завершение активных процессов...';
    if (value < 0.48) return 'Удаление файлов расширения...';
    if (value < 0.74) return 'Очистка локальных данных...';
    if (value < 0.96) return 'Удаление конфигурации...';
    return 'Завершение удаления...';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _progress,
            builder: (context, _) {
              final percent = (_progress.value * 100).round();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _complete
                                ? const Color(0x1B7CF7C2)
                                : const Color(0x1BB45CFF),
                            border: Border.all(
                              color: _complete
                                  ? const Color(0xFF7CF7C2)
                                  : const Color(0xFFB45CFF),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_complete
                                        ? const Color(0xFF7CF7C2)
                                        : const Color(0xFFB45CFF))
                                    .withOpacity(0.20 + (_progress.value * 0.12)),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _complete ? Icons.check_rounded : Icons.delete_outline_rounded,
                            size: 34,
                            color: _complete
                                ? const Color(0xFF7CF7C2)
                                : const Color(0xFFB45CFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const L10nText(
                        'УДАЛЕНИЕ KGE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFF1E9FA),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 12),
                      L10nText(
                        _status,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _complete
                              ? const Color(0xFF7CF7C2)
                              : const Color(0xFFB9A8CC),
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 25),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progress.value,
                          minHeight: 8,
                          backgroundColor: const Color(0xFF20162B),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _complete
                                ? const Color(0xFF7CF7C2)
                                : const Color(0xFFB45CFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$percent%',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFF8B7B9B),
                          fontSize: 12,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// KGE.APK
// ===========================================================================


class _KgeInstallProgressDialog extends StatefulWidget {
  const _KgeInstallProgressDialog();

  @override
  State<_KgeInstallProgressDialog> createState() =>
      _KgeInstallProgressDialogState();
}

class _KgeInstallProgressDialogState
    extends State<_KgeInstallProgressDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;

  @override
  void initState() {
    super.initState();

    // 2 seconds download + 5 seconds installation.
    _progress = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          Navigator.of(context).pop();
        }
      });

    _progress.forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        final total = _progress.value;
        final downloading = total < (2 / 7);
        final phaseProgress = downloading
            ? total / (2 / 7)
            : (total - (2 / 7)) / (5 / 7);

        final percent =
            (phaseProgress.clamp(0.0, 1.0) * 100).round();

        final title = downloading
            ? 'Скачивание KGE.apk'
            : 'Установка KGE';

        final subtitle = downloading
            ? 'Получение файлов расширения...'
            : 'Подготовка и установка расширения...';

        return Material(
          color: Colors.transparent,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF080A14),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF9C4DFF).withOpacity(0.75),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 32,
                      offset: Offset(0, 16),
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
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0x1F9C4DFF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0x664F16A8),
                            ),
                          ),
                          child: const Icon(
                            Icons.android_rounded,
                            color: Color(0xFFB45CFF),
                            size: 27,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: L10nText(
                            title,
                            style: const TextStyle(
                              color: Color(0xFFF2E7FF),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    L10nText(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFFCDBADB),
                        fontSize: 13,
                        height: 1.4,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: phaseProgress.clamp(0.0, 1.0),
                        minHeight: 7,
                        backgroundColor: const Color(0x221A0030),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFB45CFF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        L10nText(
                          downloading
                              ? 'Загрузка файлов'
                              : 'Установка',
                          style: const TextStyle(
                            color: Color(0xFF9D8DAF),
                            fontSize: 11,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            color: Color(0xFFB45CFF),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _KgeApkMessage
    extends StatelessWidget {
  final bool installed;
  final VoidCallback onTap;

  const _KgeApkMessage({
    required this.installed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
      Alignment.centerLeft,
      child: Padding(
        padding:
        const EdgeInsets.fromLTRB(
          12,
          6,
          60,
          6,
        ),
        child: Material(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(18),
          elevation: 1,
          child: InkWell(
            onTap:
            installed
                ? null
                : onTap,
            borderRadius:
            BorderRadius.circular(18),
            child: Padding(
              padding:
              const EdgeInsets.all(
                14,
              ),
              child: Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFEAF1FF,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),
                    child:
                    const Icon(
                      Icons
                          .android_rounded,
                      color:
                      Color(0xFF5B8DEF),
                      size: 28,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  const Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      L10nText('KGE.apk',
                        style:
                        TextStyle(
                          color:
                          Color(
                            0xFF18253A,
                          ),
                          fontSize:
                          16,
                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      L10nText('Приложение',
                        style:
                        TextStyle(
                          color:
                          Color(
                            0xFF8A97AA,
                          ),
                          fontSize:
                          13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    width: 16,
                  ),

                  Icon(
                    installed
                        ? Icons
                        .check_circle_rounded
                        : Icons
                        .download_rounded,
                    color: installed
                        ? const Color(
                      0xFF1DBA67,
                    )
                        : const Color(
                      0xFF5B8DEF,
                    ),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// АВАТАР
// ===========================================================================

class _Avatar
    extends StatelessWidget {
  final Chat chat;

  const _Avatar({
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior:
      Clip.none,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration:
          BoxDecoration(
            color:
            chat.type ==
                ChatType.group
                ? const Color(
              0xFF48617C,
            )
                : const Color(
              0xFFDDE4EE,
            ),
            shape:
            BoxShape.circle,
          ),
          alignment:
          Alignment.center,
          child: chat.type == ChatType.group
              ? const Icon(Icons.people_alt_rounded, color: Colors.white, size: 20)
              : Text(
                  chat.initials,
                  style: const TextStyle(
                    color: Color(0xFF233247),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        if (chat.isOnline)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 13,
              height: 13,
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFF18B65B,
                ),
                shape:
                BoxShape.circle,
                border:
                Border.all(
                  color:
                  Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
