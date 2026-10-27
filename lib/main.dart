import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'app.dart';
import 'services/chat_store.dart';
import 'services/kge_store.dart';
import 'services/language_store.dart';
import 'services/profile_store.dart';
import 'services/story_session_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPaintBaselinesEnabled = false;
  debugPaintSizeEnabled = false;
  debugPaintPointersEnabled = false;

  final profileStore = await ProfileStore.load();
  await LanguageStore.load();
  final kgeStore = await KgeStore.load();
  final chatStore = ChatStore();

  await chatStore.load();
  await StorySessionStore.instance.load();

  runApp(
    SvyazApp(
      store: chatStore,
      profileStore: profileStore,
      kgeStore: kgeStore,
    ),
  );
}
