import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/liven_story.dart';
import '../../data/niks_story.dart' show StoryChoice, StoryStep;
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../services/kge_store.dart';
import '../../services/chat_store.dart';
import '../../services/story_session_store.dart';
import '../../widgets/kge/kge_panel.dart';
import '../../widgets/l10n_text.dart';

class KgeChatsScreen extends StatefulWidget {
  final ChatStore chatStore;

  const KgeChatsScreen({super.key, required this.chatStore});

  @override
  State<KgeChatsScreen> createState() => _KgeChatsScreenState();
}

class _KgeChatsScreenState extends State<KgeChatsScreen> {
  static const String _createdKey = 'kge_liven_chat_created';
  static const String _readKey = 'kge_liven_chat_read';
  static const String _deletedKey = 'kge_liven_chat_deleted';
  static const String _storyChatId = 'kge_liven';

  final ScrollController _messageScrollController = ScrollController();
  SharedPreferences? _prefs;
  Chat? _livenChat;
  StorySessionState? _story;

  bool _loading = true;
  bool _insideConversation = false;
  bool _chatCreated = false;
  bool _chatRead = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _messageScrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await KgeStore.instance.markKgeChatsChecked();
    await StorySessionStore.instance.load();
    _prefs = await SharedPreferences.getInstance();

    final deleted = _prefs!.getBool(_deletedKey) ?? false;
    _chatCreated = _prefs!.getBool(_createdKey) ?? false;
    _chatRead = _prefs!.getBool(_readKey) ?? false;

    if (!deleted && !KgeStore.instance.mirrorMessageSeen) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const _MirrorMessageDialog(),
      );
      await KgeStore.instance.markMirrorMessageSeen();
      if (!mounted) return;
    }

    if (!deleted) {
      if (!_chatCreated) {
        await _createLivenChat();
      } else {
        _restoreLivenChat();
      }
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _createLivenChat() async {
    // Use a separate session ID so LIVEN never appears in the regular Svyaz
    // messenger or shares its conversation state.
    await StorySessionStore.instance.clearForChat(_storyChatId);
    _livenChat = _buildLivenChat();
    _story = StorySessionStore.instance.getForChat(_livenChat!);
    _chatCreated = true;
    _chatRead = false;
    await _prefs?.setBool(_createdKey, true);
    await _prefs?.setBool(_readKey, false);
  }

  void _restoreLivenChat() {
    _livenChat = _buildLivenChat();
    _story = StorySessionStore.instance.getForChat(_livenChat!);
  }

  Chat _buildLivenChat() {
    final now = DateTime.now();
    return Chat(
      id: _storyChatId,
      name: 'LIVEN',
      initials: 'L',
      type: ChatType.personal,
      isOnline: true,
      isArchived: false,
      unreadCount: _chatRead ? 0 : 3,
      messages: [
        Message(
          id: 'kge-liven-initial-1',
          text: 'Привет',
          isMine: false,
          time: now.subtract(const Duration(seconds: 3)),
          status: MessageStatus.delivered,
        ),
        Message(
          id: 'kge-liven-initial-2',
          text: 'Мне тут кое-кто твои контакты дал.',
          isMine: false,
          time: now.subtract(const Duration(seconds: 2)),
          status: MessageStatus.delivered,
        ),
        Message(
          id: 'kge-liven-initial-3',
          text: 'Работа нужна?',
          isMine: false,
          time: now.subtract(const Duration(seconds: 1)),
          status: MessageStatus.delivered,
        ),
      ],
    );
  }

  Future<void> _openLivenChat() async {
    if (!_chatCreated || _livenChat == null) return;
    setState(() {
      _insideConversation = true;
      _chatRead = true;
      _livenChat!.unreadCount = 0;
      _story ??= StorySessionStore.instance.getForChat(_livenChat!);
    });
    await _prefs?.setBool(_readKey, true);
    _scrollToBottom();
  }

  Future<void> _backToChatList() async {
    // Leaving the LIVEN conversation returns to its chat list silently.
    // The temporary "Продолжение следует" notice was removed.
    if (!mounted) return;
    setState(() => _insideConversation = false);
  }

  StoryStep? get _currentStep {
    final id = _story?.stepId;
    if (id == null) return null;
    return LivenStory.getStep(id);
  }

  Future<void> _selectChoice(StoryChoice choice) async {
    final story = _story;
    if (story == null || story.choiceLocked) return;

    if (choice.id == 'liven_yes_sure') {
      // This choice deletes only LIVEN's conversation. KGE remains open;
      // its removal happens later, after the player finishes the Niks scene.
      await _prefs?.setBool(_deletedKey, true);
      await _prefs?.remove(_createdKey);
      await _prefs?.remove(_readKey);
      await StorySessionStore.instance.clearForChat(_storyChatId);
      await _prepareNiksBadEnding();
      if (!mounted) return;
      setState(() {
        _chatCreated = false;
        _chatRead = false;
        _insideConversation = false;
        _livenChat = null;
        _story = null;
      });
      return;
    }

    final nextStepId = LivenStory.getNextStep(choice.id);
    if (nextStepId == null) {
      setState(() {
        story.messages.add(_newMessage(choice.text, isMine: true));
        story.stepId = null;
        story.choiceLocked = true;
      });
      await StorySessionStore.instance.saveForChat(_storyChatId);
      _scrollToBottom();
      return;
    }

    final nextStep = LivenStory.getStep(nextStepId);
    if (nextStep == null) return;

    setState(() {
      story.messages.add(_newMessage(choice.text, isMine: true));
      // Keep the active step during delivery so the image can appear inline
      // as soon as the configured preceding message has arrived.
      story.stepId = nextStep.id;
      story.choiceLocked = true;
      story.storyTyping = nextStep.messages.isNotEmpty;
    });
    await StorySessionStore.instance.saveForChat(_storyChatId);
    _scrollToBottom();

    for (var i = 0; i < nextStep.messages.length; i++) {
      if (!mounted) return;

      final useTypingDelay = nextStep.typingBetweenMessages;
      if (i == 0) {
        await Future<void>.delayed(
          useTypingDelay
              ? nextStep.typingDelay
              : const Duration(milliseconds: 750),
        );
      } else if (useTypingDelay) {
        setState(() => story.storyTyping = true);
        _scrollToBottom();
        await Future<void>.delayed(nextStep.typingDelay);
      }

      if (!mounted) return;
      setState(() {
        story.messages.add(_newMessage(nextStep.messages[i], isMine: false));
        story.storyTyping = useTypingDelay && i < nextStep.messages.length - 1;
      });
      await StorySessionStore.instance.saveForChat(_storyChatId);
      _scrollToBottom();
    }

    if (!mounted) return;
    setState(() {
      story.storyTyping = false;
      story.stepId = nextStep.id;
      story.choiceLocked = false;
    });
    await StorySessionStore.instance.saveForChat(_storyChatId);
    _scrollToBottom();
  }

  Future<void> _prepareNiksBadEnding() async {
    final niks = widget.chatStore.getChat('nika');
    if (niks == null) return;

    final session = StorySessionStore.instance.getForChat(niks);
    final alreadyStarted = session.messages.any(
      (message) => message.id == 'story-kge-removal-niks-opening',
    );
    if (alreadyStarted) return;

    final opening = Message(
      id: 'story-kge-removal-niks-opening',
      text: 'Ну как ты там?',
      isMine: false,
      time: DateTime.now(),
      status: MessageStatus.delivered,
    );
    session.messages.add(opening);
    session.stepId = 'kge_removed_niks_start';
    session.storyTyping = false;
    session.choiceLocked = false;
    session.showKgeFile = false;
    await StorySessionStore.instance.saveForChat(niks.id);

    // Обновляем превью и индикатор непрочитанного сообщения в «Связи».
    widget.chatStore.addIncomingMessage(niks.id, opening.text);
  }

  Message _newMessage(String text, {required bool isMine}) {
    final now = DateTime.now();
    return Message(
      id: 'story-${now.microsecondsSinceEpoch}',
      text: text,
      isMine: isMine,
      time: now,
      status: MessageStatus.read,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_messageScrollController.hasClients) return;
      _messageScrollController.animateTo(
        _messageScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = KgeStore.instance.colorTheme;
    return Scaffold(
      backgroundColor: const Color(0xFF020107),
      appBar: AppBar(
        backgroundColor: const Color(0xD006040B),
        foregroundColor: theme.brightText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: _insideConversation
            ? IconButton(
                tooltip: 'Назад',
                onPressed: _backToChatList,
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        title: _insideConversation
            ? Row(
                children: [
                  _LivenAvatar(size: 32),
                  const SizedBox(width: 10),
                  const Text(
                    'LIVEN',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              )
            : const L10nText(
                'Чаты',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: theme.primary))
          : _insideConversation
              ? _buildConversation(theme)
              : _buildChatList(theme),
    );
  }

  Widget _buildChatList(KgeColorTheme theme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: [
        const Text(
          'ЧАТЫ',
          style: TextStyle(
            color: Color(0xFFB45CFF),
            fontSize: 21,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.7,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _chatCreated ? 'ВХОДЯЩИЕ СООБЩЕНИЯ' : 'ЗАЩИФРОВАННЫЙ КАНАЛ',
          style: TextStyle(
            color: theme.subtitle,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        if (_chatCreated && _livenChat != null && _story != null)
          KgePanel(
            padding: EdgeInsets.zero,
            child: InkWell(
              onTap: _openLivenChat,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _LivenAvatar(size: 54),
                        if (!_chatRead)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                color: theme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF080610),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'LIVEN',
                                  style: TextStyle(
                                    color: theme.brightText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Text(
                                _formatTime(_story!.messages.isNotEmpty
                                    ? _story!.messages.last.time
                                    : null),
                                style: TextStyle(
                                  color: _chatRead ? theme.subtitle : theme.primary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _story!.messages.isNotEmpty
                                ? _story!.messages.last.text
                                : 'Новое сообщение',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _chatRead ? theme.subtitle : theme.bodyText,
                              fontSize: 12,
                              fontWeight: _chatRead ? FontWeight.normal : FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: theme.mutedText),
                  ],
                ),
              ),
            ),
          )
        else
          KgePanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.forum_outlined, color: theme.primary, size: 35),
                const SizedBox(height: 12),
                Text(
                  'ЧАТЫ С КЛИЕНТАМИ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.brightText,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Пока нет переписок с клиентами. Вы ещё никому не писали.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.subtitle, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _showFullscreenImage(String assetPath) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Center(
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'Не удалось загрузить изображение.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: SafeArea(
                child: IconButton.filledTonal(
                  tooltip: 'Закрыть изображение',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xCC20172A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversation(KgeColorTheme theme) {
    final messages = _story?.messages ?? const <Message>[];
    final step = _currentStep;
    final choices = step?.choices ?? const <StoryChoice>[];
    final typing = _story?.storyTyping ?? false;
    // Treat the attached photo as part of the conversation history, not just
    // the active story step. This keeps Grab1 visible after leaving and
    // reopening the chat, and after progressing to the next story step.
    const persistentStoryImage = 'assets/kge/Grab1.png';
    const imageAfterText = 'Ближе к делу.';
    final imageAfterIndex = messages.lastIndexWhere(
      (message) => !message.isMine && message.text == imageAfterText,
    );
    final shouldShowImage = imageAfterIndex >= 0;
    final imageInsertIndex = shouldShowImage ? imageAfterIndex + 1 : -1;
    final imageCount = shouldShowImage ? 1 : 0;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _messageScrollController,
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
            itemCount: messages.length + imageCount + (typing ? 1 : 0),
            itemBuilder: (context, index) {
              if (shouldShowImage && index == imageInsertIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => _showFullscreenImage(persistentStoryImage),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          persistentStoryImage,
                          width: 280,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 280,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF100D18),
                              border: Border.all(color: theme.panelBorder),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              'Не удалось загрузить изображение.',
                              style: TextStyle(color: theme.subtitle),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              final typingIndex = messages.length + imageCount;
              if (typing && index == typingIndex) {
                return Padding(
                  padding: const EdgeInsets.only(left: 4, top: 8, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                      decoration: BoxDecoration(
                        color: const Color(0xFF100D18),
                        border: Border.all(color: theme.panelBorder),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'LIVEN печатает…',
                        style: TextStyle(color: theme.subtitle, fontSize: 12),
                      ),
                    ),
                  ),
                );
              }

              final messageIndex = shouldShowImage && index > imageInsertIndex
                  ? index - 1
                  : index;
              if (messageIndex < 0 || messageIndex >= messages.length) {
                return const SizedBox.shrink();
              }
              return _KgeMessageBubble(
                message: messages[messageIndex],
                theme: theme,
              );
            },
          ),
        ),
        if (choices.isNotEmpty && !(_story?.choiceLocked ?? true))
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: const BoxDecoration(
                color: Color(0xE606040B),
                border: Border(top: BorderSide(color: Color(0x443F2B52))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final choice in choices) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _selectChoice(choice),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.brightText,
                          side: BorderSide(color: theme.primary.withOpacity(0.75)),
                          backgroundColor: theme.primary.withOpacity(0.07),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(choice.text, textAlign: TextAlign.center),
                      ),
                    ),
                    if (choice != choices.last) const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final local = dateTime.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _LivenAvatar extends StatelessWidget {
  final double size;

  const _LivenAvatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        'assets/avatars/AvaLIVEN.jpg',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          color: const Color(0xFF180C23),
          child: Text('L', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: size * 0.45)),
        ),
      ),
    );
  }
}

class _KgeMessageBubble extends StatelessWidget {
  final Message message;
  final KgeColorTheme theme;

  const _KgeMessageBubble({required this.message, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final time = '${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}';
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(13, 10, 13, 7),
        decoration: BoxDecoration(
          color: isMine ? theme.primary.withOpacity(0.13) : const Color(0xFF100D18),
          border: Border.all(color: isMine ? theme.primary.withOpacity(0.45) : theme.panelBorder),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(isMine ? 15 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(message.text, style: TextStyle(color: theme.brightText, fontSize: 14, height: 1.4)),
            ),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(color: theme.subtitle, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class _MirrorMessageDialog extends StatefulWidget {
  const _MirrorMessageDialog();

  @override
  State<_MirrorMessageDialog> createState() => _MirrorMessageDialogState();
}

class _MirrorMessageDialogState extends State<_MirrorMessageDialog> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final theme = KgeStore.instance.colorTheme;
    const firstPage =
        'Большое спасибо, что скачали мою игру и провели в ней время! '
        'С этого момента KGE находится в вашем полном распоряжении. '
        'Но помните: каждое действие и даже бездействие оставляет последствия, '
        'и для каждого человека они могут быть разными.';
    const secondPage =
        'Помните: каждое ваше решение будет иметь последствия — '
        'как для вас, так и для окружающего мира. Приятной игры!';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: KgePanel(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, minHeight: 250),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.visibility_outlined, color: theme.primary, size: 21),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ОТРАЖЕНИЕ',
                      style: TextStyle(color: theme.primary, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _page == 0 ? firstPage : secondPage,
                style: TextStyle(color: theme.brightText, fontSize: 14, height: 1.65),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (_page == 1)
                    IconButton(
                      tooltip: 'Назад',
                      onPressed: () => setState(() => _page = 0),
                      icon: Icon(Icons.arrow_back, color: theme.secondaryText, size: 26),
                    ),
                  const Spacer(),
                  if (_page == 0)
                    IconButton(
                      tooltip: 'Далее',
                      onPressed: () => setState(() => _page = 1),
                      icon: Icon(Icons.arrow_forward, color: theme.primary, size: 28),
                    )
                  else
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(backgroundColor: theme.primary, foregroundColor: Colors.black),
                      child: const Text('Закрыть'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
