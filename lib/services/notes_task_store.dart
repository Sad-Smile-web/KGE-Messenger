import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_store.dart';
import 'kge_store.dart';
import 'story_session_store.dart';
import 'app_localization.dart';

/// Story-task progress shown in the pinned Notes chat.
enum NotesTaskStage {
  readNiks,
  openKge,
  replyNiks,
  checkShop,
  replyShop,
  checkKge,
  completed,
}

class NotesTaskStore {
  NotesTaskStore._();

  static const String _lastSeenStageKey = 'notes_task_last_seen_stage';
  static final ChangeNotifier changes = ChangeNotifier();
  static int _lastSeenStage = -1;
  static Future<void>? _loadFuture;

  static Future<void> _ensureLoaded() {
    return _loadFuture ??= _loadLastSeenStage();
  }

  static Future<void> _loadLastSeenStage() async {
    final prefs = await SharedPreferences.getInstance();
    _lastSeenStage = prefs.getInt(_lastSeenStageKey) ?? -1;
    changes.notifyListeners();
  }

  /// True only when a task stage newer than the last opened task is active.
  static bool hasUnreadTask(NotesTaskStage stage) {
    if (_loadFuture == null) {
      unawaited(_ensureLoaded());
    }
    return stage != NotesTaskStage.completed && stage.index > _lastSeenStage;
  }

  /// Called when the player opens Notes. A later stage will light the badge
  /// again, while reopening the same task will not.
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSeenStageKey);
    _lastSeenStage = -1;
    _loadFuture = Future<void>.value();
    changes.notifyListeners();
  }

  static Future<void> markSeen(NotesTaskStage stage) async {
    await _ensureLoaded();
    if (stage.index <= _lastSeenStage) return;

    _lastSeenStage = stage.index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSeenStageKey, _lastSeenStage);
    changes.notifyListeners();
  }

  static NotesTaskStage stage({
    required ChatStore chatStore,
    required KgeStore kgeStore,
  }) {
    // During story typing stepId is temporarily null, so infer the in-flight
    // scene from the player's last reply rather than moving tasks backwards.
    if (!kgeStore.isInstalled) return NotesTaskStage.readNiks;

    final niks = chatStore.getChat('nika');
    if (niks == null) return NotesTaskStage.readNiks;

    final session = StorySessionStore.instance.getForChat(niks);
    var stepId = session.stepId;
    if (stepId == null) {
      final lastMine = session.messages.reversed.where((m) => m.isMine).firstOrNull;
      final reply = lastMine?.text.trim();
      if (reply == 'Ну тогда делай, что нужно.') {
        stepId = 'kge_update';
      } else if (reply == 'Я думал, что уже там состою.') {
        stepId = 'system_reply';
      } else if (reply == 'Да...' || reply == 'А у меня есть выбор?') {
        stepId = 'shop_agree_reply';
      } else if (reply == 'Чё, прям хакеров?)') {
        stepId = 'hackers_reply';
      } else {
        stepId = 'start';
      }
    }

    if (stepId == 'hackers_reply') {
      return kgeStore.shopUnlocked
          ? NotesTaskStage.checkShop
          : NotesTaskStage.replyNiks;
    }
    if (stepId == 'shop_followup' ||
        stepId == 'shop_agree_reply' ||
        stepId == 'system_reply') {
      return NotesTaskStage.replyShop;
    }
    if (stepId == 'kge_update') {
      return kgeStore.kgeNotesUnlocked
          ? NotesTaskStage.completed
          : NotesTaskStage.checkKge;
    }
    if (stepId == 'start' || stepId == 'app' || stepId == 'apk') {
      return NotesTaskStage.openKge;
    }
    return NotesTaskStage.replyNiks;
  }

  static bool isCompleted(int taskIndex, NotesTaskStage stage) =>
      taskIndex < stage.index;

  static String activeTask(NotesTaskStage stage) {
    if (stage == NotesTaskStage.completed) {
      return L10n.t('Все задания выполнены');
    }
    return L10n.t(taskLabels[stage.index]);
  }

  static const List<String> taskLabels = [
    'Прочитать, что написал Никс',
    'Открыть расширение KGE',
    'Ответить Никсу',
    'Проверьте магазин (перейдите в расширение KGE во вкладку «Операции»)',
    'Ответить Никсу',
    'Проверить KGE',
  ];
}
