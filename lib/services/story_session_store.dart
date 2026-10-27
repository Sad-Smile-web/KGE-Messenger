import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat.dart';
import '../models/message.dart';

class StorySessionState {
  final List<Message> messages;

  String? stepId;

  bool storyTyping;
  bool choiceLocked;
  bool showKgeFile;

  StorySessionState({
    required this.messages,
    this.stepId,
    this.storyTyping = false,
    this.choiceLocked = false,
    this.showKgeFile = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'messages': messages
          .map(
            (message) => {
          'id': message.id,
          'text': message.text,
          'isMine': message.isMine,
          'time': message.time.toIso8601String(),
          'status': message.status.name,
        },
      )
          .toList(),
      'stepId': stepId,
      'showKgeFile': showKgeFile,
    };
  }

  static StorySessionState? fromJson(
      Map<String, dynamic> json,
      ) {
    try {
      final messages = <Message>[];

      final rawMessages = json['messages'];

      if (rawMessages is List) {
        for (final item in rawMessages) {
          if (item is! Map) continue;

          final map =
          Map<String, dynamic>.from(item);

          final statusName =
          map['status']?.toString();

          MessageStatus? status;

          for (final value in MessageStatus.values) {
            if (value.name == statusName) {
              status = value;
              break;
            }
          }

          if (status == null) continue;

          final time = DateTime.tryParse(
            map['time']?.toString() ?? '',
          );

          if (time == null) continue;

          messages.add(
            Message(
              id: map['id']?.toString() ?? '',
              text: map['text']?.toString() ?? '',
              isMine: map['isMine'] == true,
              time: time,
              status: status,
            ),
          );
        }
      }

      if (messages.isEmpty) {
        return null;
      }

      return StorySessionState(
        messages: messages,
        stepId: json['stepId']?.toString(),
        showKgeFile: json['showKgeFile'] == true,
      );
    } catch (_) {
      return null;
    }
  }
}

class StorySessionStore extends ChangeNotifier {
  StorySessionStore._();

  static final StorySessionStore instance =
  StorySessionStore._();

  static const String _keyPrefix =
      'story_session_';
  static const String _badEndingPendingKey =
      'story_bad_ending_pending';

  final Map<String, StorySessionState> _sessions =
  <String, StorySessionState>{};

  SharedPreferences? _prefs;

  bool _loaded = false;

  bool get badEndingPending =>
      _prefs?.getBool(_badEndingPendingKey) ?? false;

  Future<void> markBadEndingPending() async {
    if (!_loaded) await load();
    await _prefs!.setBool(_badEndingPendingKey, true);
    notifyListeners();
  }

  Future<void> clearBadEndingPending() async {
    if (!_loaded) await load();
    await _prefs!.remove(_badEndingPendingKey);
    notifyListeners();
  }

  /// Clears saved conversations/story progress for a full restart while
  /// leaving app preferences such as the selected language untouched.
  Future<void> resetAll() async {
    if (!_loaded) await load();
    _sessions.clear();
    final keys = _prefs!.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyPrefix) ||
          key == _badEndingPendingKey ||
          key == 'kge_liven_chat_created' ||
          key == 'kge_liven_chat_read' ||
          key == 'kge_liven_chat_deleted') {
        await _prefs!.remove(key);
      }
    }
    notifyListeners();
  }

  Future<void> load() async {
    if (_loaded) return;

    _prefs =
    await SharedPreferences.getInstance();

    _loaded = true;
  }

  /// Returns a previously saved story session without creating a new one.
  /// Used by KGE news to check whether LIVEN has assigned the first task.
  StorySessionState? getByChatId(String chatId) {
    final existing = _sessions[chatId];
    if (existing != null) return existing;
    if (_prefs == null) return null;

    final saved = _prefs!.getString('$_keyPrefix$chatId');
    if (saved == null || saved.isEmpty) return null;

    try {
      final decoded = jsonDecode(saved);
      if (decoded is Map) {
        final restored = StorySessionState.fromJson(
          Map<String, dynamic>.from(decoded),
        );
        if (restored != null) {
          _sessions[chatId] = restored;
          return restored;
        }
      }
    } catch (_) {
      // Ignore a damaged story save and keep the news locked.
    }
    return null;
  }

  StorySessionState getForChat(Chat chat) {
    final existing = _sessions[chat.id];

    if (existing != null) {
      return existing;
    }

    StorySessionState? restored;

    if (_prefs != null) {
      final saved = _prefs!.getString(
        '$_keyPrefix${chat.id}',
      );

      if (saved != null && saved.isNotEmpty) {
        try {
          final decoded = jsonDecode(saved);

          if (decoded is Map) {
            restored =
                StorySessionState.fromJson(
                  Map<String, dynamic>.from(decoded),
                );
          }
        } catch (_) {
          restored = null;
        }
      }
    }

    final session = restored ??
        StorySessionState(
          messages:
          List<Message>.from(chat.messages),
          stepId: chat.id == 'nika'
              ? 'start'
              : chat.id == 'kge_liven'
                  ? 'liven_who'
                  : null,
        );

    _sessions[chat.id] = session;

    return session;
  }

  Future<void> saveForChat(
      String chatId,
      ) async {
    if (!_loaded) {
      await load();
    }

    final session = _sessions[chatId];

    if (session == null) return;

    await _prefs!.setString(
      '$_keyPrefix$chatId',
      jsonEncode(
        session.toJson(),
      ),
    );

    notifyListeners();
  }

  Future<void> clearForChat(
      String chatId,
      ) async {
    _sessions.remove(chatId);

    if (!_loaded) {
      await load();
    }

    await _prefs!.remove(
      '$_keyPrefix$chatId',
    );

    notifyListeners();
  }

  Future<bool> advanceNiksAfterKge(
      Chat chat,
      ) async {
    if (chat.id != 'nika') {
      return false;
    }

    final session =
    getForChat(chat);

    if (session.stepId != 'apk' ||
        !session.showKgeFile) {
      return false;
    }

    session.messages.add(
      Message(
        id:
        'story-kge-${DateTime.now().microsecondsSinceEpoch}',
        text:
        'Ну как? Правда зачёт?',
        isMine: false,
        time: DateTime.now(),
        status: MessageStatus.read,
      ),
    );

    session.stepId =
    'kge_followup';

    session.showKgeFile = false;
    session.storyTyping = false;
    session.choiceLocked = false;

    await saveForChat(chat.id);

    // Очень важно:
    // уведомляем ChatListScreen и другие слушатели,
    // что сюжет Никса изменился.
    notifyListeners();

    return true;
  }

  Future<bool> triggerAfterShopChecked(
      Chat chat,
      ) async {
    if (chat.id != 'nika') {
      return false;
    }

    final session = getForChat(chat);

    if (session.stepId != 'hackers_reply') {
      return false;
    }

    final firstTime = DateTime.now();

    session.messages.add(
      Message(
        id: 'story-kge-shop-${firstTime.microsecondsSinceEpoch}',
        text: 'Ну что?',
        isMine: false,
        time: firstTime,
        status: MessageStatus.read,
      ),
    );

    final secondTime = DateTime.now();

    session.messages.add(
      Message(
        id: 'story-kge-shop-${secondTime.microsecondsSinceEpoch}',
        text: 'Готов наконец-то заняться делом?',
        isMine: false,
        time: secondTime,
        status: MessageStatus.read,
      ),
    );

    session.stepId = 'shop_followup';
    session.storyTyping = false;
    session.choiceLocked = false;

    await saveForChat(chat.id);
    notifyListeners();

    return true;
  }

}