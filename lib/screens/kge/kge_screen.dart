import 'package:flutter/material.dart';

import '../../services/chat_store.dart';
import '../../services/kge_store.dart';
import '../../services/story_session_store.dart';
import '../../widgets/kge/kge_background.dart';
import 'kge_boot_overlay.dart';
import 'kge_setup_screen.dart';
import '../kge_shell.dart';
import '../../widgets/l10n_text.dart';
import '../../widgets/kge/kge_tutorial_overlay.dart';

class KgeScreen extends StatefulWidget {
  final KgeStore kgeStore;
  final ChatStore store;

  const KgeScreen({
    super.key,
    required this.kgeStore,
    required this.store,
  });

  @override
  State<KgeScreen> createState() => _KgeScreenState();
}

class _KgeScreenState extends State<KgeScreen> {
  bool _booting = true;
  bool _setupRequired = false;
  bool _postSetupStarted = false;
  bool _notificationVisible = false;
  bool _notificationTriggered = false;
  String _notificationText = 'Ну как? Правда зачёт?';
  bool _tutorialVisible = false;

  @override
  void initState() {
    super.initState();
    _setupRequired = !widget.kgeStore.isAccountConfigured;
  }

  Future<void> _finishBoot() async {
    if (!mounted) return;

    setState(() {
      _booting = false;
    });

    if (!_setupRequired) {
      _startPostSetupFlow();
    }
  }

  Future<void> _startPostSetupFlow() async {
    if (_postSetupStarted) return;

    // До первичной регистрации KGE таймер уведомления Никс не запускается.
    if (!widget.kgeStore.isAccountConfigured) return;

    _postSetupStarted = true;

    await Future<void>.delayed(
      const Duration(seconds: 5),
    );

    if (!mounted) return;

    // Защита от ситуации, когда аккаунт был сброшен во время ожидания.
    if (!widget.kgeStore.isAccountConfigured) return;

    final niks = widget.store.getChat('nika');

    if (niks == null) {
      return;
    }

    final advanced =
        await StorySessionStore.instance.advanceNiksAfterKge(niks);

    if (!mounted) return;

    if (advanced) {
      _showNiksNotification('Ну как? Правда зачёт?');
    }
  }

  Future<void> _finishSetup() async {
    if (!mounted) return;

    if (!widget.kgeStore.isAccountConfigured) {
      return;
    }

    setState(() {
      _setupRequired = false;
      _tutorialVisible = true;
    });
  }

  void _showNiksNotification(String text) {
    if (!mounted) return;

    setState(() {
      _notificationText = text;
      _notificationTriggered = true;
      _notificationVisible = true;
    });
  }

  void _closeNotification() {
    if (!mounted) return;

    setState(() {
      _notificationVisible = false;
    });
  }

  void _closeTutorial() {
    if (!mounted) return;

    setState(() {
      _tutorialVisible = false;
    });

    _startPostSetupFlow();
  }

  void _exitKge() {
    if (!mounted) return;

    Navigator.pop(
      context,
      _notificationTriggered,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020107),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const KgeBackground(),

          AnimatedOpacity(
            opacity: _booting ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOut,
            child: KgeShell(
              kgeStore: widget.kgeStore,
              chatStore: widget.store,
              onNiksNotification: _showNiksNotification,
              onExit: _exitKge,
            ),
          ),

          if (_booting)
            Positioned.fill(
              child: KgeBootOverlay(
                onFinished: _finishBoot,
              ),
            ),

          if (!_booting && _setupRequired)
            Positioned.fill(
              child: KgeSetupScreen(
                kgeStore: widget.kgeStore,
                onCompleted: _finishSetup,
                onCancel: _exitKge,
              ),
            ),

          if (_notificationVisible)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 14,
              right: 14,
              child: _NiksKgeNotification(
                message: _notificationText,
                onClose: _closeNotification,
              ),
            ),

          if (_tutorialVisible)
            Positioned.fill(
              child: KgeTutorialOverlay(
                onClose: _closeTutorial,
              ),
            ),
        ],
      ),
    );
  }
}

class _NiksKgeNotification extends StatefulWidget {
  final String message;
  final VoidCallback onClose;

  const _NiksKgeNotification({
    required this.message,
    required this.onClose,
  });

  @override
  State<_NiksKgeNotification> createState() =>
      _NiksKgeNotificationState();
}

class _NiksKgeNotificationState extends State<_NiksKgeNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        final value = Curves.easeOutCubic.transform(
          _animationController.value,
        );

        return Transform.translate(
          offset: Offset(0, -30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Material(
              color: Colors.transparent,
              elevation: 18,
              shadowColor: const Color(0x66000000),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 13, 8, 13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFDCE6F4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
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
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          L10nText('Никс',
                            style: TextStyle(
                              color: Color(0xFF18253A),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 3),
                          L10nText(
                            widget.message,
                            style: TextStyle(
                              color: Color(0xFF6F7E92),
                              fontSize: 13,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onClose,
                      child: const L10nText('Закрыть',
                        style: TextStyle(
                          color: Color(0xFF1976F3),
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
                      ),
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
