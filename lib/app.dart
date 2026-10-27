import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'screens/chat_list_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/kge/kge_screen.dart';
import 'screens/bad_ending_screen.dart';
import 'services/notes_task_store.dart';
import 'screens/profile_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/search_screen.dart';
import 'services/chat_store.dart';
import 'services/kge_store.dart';
import 'services/profile_store.dart';
import 'services/story_session_store.dart';
import 'services/language_store.dart';
import 'theme/app_theme.dart';

class SvyazApp extends StatefulWidget {
  final ChatStore store;
  final ProfileStore profileStore;
  final KgeStore kgeStore;

  const SvyazApp({
    super.key,
    required this.store,
    required this.profileStore,
    required this.kgeStore,
  });

  @override
  State<SvyazApp> createState() => _SvyazAppState();
}

class _SvyazAppState extends State<SvyazApp> {
  late bool _registered;
  bool _restartRegistrationRoute = false;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _registered = widget.profileStore.isRegistered;
  }

  void _finishRegistration() {
    setState(() {
      _registered = true;
    });

    // After a full restart, registration is a pushed route rather than the
    // MaterialApp's initial home, so replace it explicitly with the chat list.
    if (_restartRegistrationRoute) {
      _restartRegistrationRoute = false;
      _navigatorKey.currentState?.pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) => _RootBackHandler(
            child: ChatListScreen(
              store: widget.store,
              kgeStore: widget.kgeStore,
              profileStore: widget.profileStore,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _showBadEnding() async {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => BadEndingScreen(onRestart: _restartProgress),
      ),
    );
  }

  Future<void> _restartProgress() async {
    // Reset story and game progress while preserving app preferences such as language.
    await StorySessionStore.instance.resetAll();
    await NotesTaskStore.reset();
    await widget.store.clearSavedChats();
    await widget.kgeStore.uninstall();
    await widget.profileStore.reset();

    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      'kge_liven_chat_created',
      'kge_liven_chat_read',
      'kge_liven_chat_deleted',
    ]) {
      await prefs.remove(key);
    }

    if (!mounted) return;
    setState(() {
      _registered = false;
      _restartRegistrationRoute = true;
    });

    final navigator = _navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(
          builder: (_) => _RootBackHandler(
            child: RegistrationScreen(
              profileStore: widget.profileStore,
              onCompleted: _finishRegistration,
            ),
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LanguageStore.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Svyaz',
          theme: AppTheme.light(),
          navigatorKey: _navigatorKey,
          home: _registered
              ? _RootBackHandler(
                  child: ChatListScreen(
                    store: widget.store,
                    kgeStore: widget.kgeStore,
                    profileStore: widget.profileStore,
                  ),
                )
              : _RootBackHandler(
                  child: RegistrationScreen(
                    profileStore: widget.profileStore,
                    onCompleted: _finishRegistration,
                  ),
                ),
          onGenerateRoute: (settings) {
            if (settings.name == '/search') {
              return MaterialPageRoute<void>(
                builder: (_) => SearchScreen(
                  store: widget.store,
                ),
              );
            }

            if (settings.name == '/profile') {
              return MaterialPageRoute<void>(
                builder: (_) => ProfileScreen(
                  profileStore: widget.profileStore,
                ),
              );
            }

            if (settings.name == '/kge') {
              return MaterialPageRoute<void>(
                builder: (_) => KgeScreen(
                  kgeStore: widget.kgeStore,
                  store: widget.store,
                ),
              );
            }

            if (settings.name == '/chat' &&
                settings.arguments is String) {
              final chat = widget.store.getChat(
                settings.arguments as String,
              );

              if (chat != null) {
                return MaterialPageRoute<void>(
                  builder: (_) => ChatScreen(
                    store: widget.store,
                    kgeStore: widget.kgeStore,
                    chat: chat,
                    onBadEndingExit: _showBadEnding,
                  ),
                );
              }
            }

            return MaterialPageRoute<void>(
              builder: (_) {
                return _registered
                    ? ChatListScreen(
                        store: widget.store,
                        kgeStore: widget.kgeStore,
                        profileStore: widget.profileStore,
                      )
                    : RegistrationScreen(
                        profileStore: widget.profileStore,
                        onCompleted: _finishRegistration,
                      );
              },
            );
          },
        );
      },
    );
  }
}

/// On the initial route, keep the Flutter Activity alive when Back is pressed.
/// This avoids tearing down the engine on exit; nested routes still pop normally.
class _RootBackHandler extends StatelessWidget {
  const _RootBackHandler({required this.child});

  static const MethodChannel _channel = MethodChannel(
    'com.example.watchdogs_ui/app_lifecycle',
  );

  final Widget child;

  Future<void> _moveTaskToBack() async {
    try {
      await _channel.invokeMethod<bool>('moveTaskToBack');
    } catch (error) {
      debugPrint('Could not move Svyaz task to background: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _moveTaskToBack();
        }
      },
      child: child,
    );
  }
}
