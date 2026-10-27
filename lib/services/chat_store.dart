import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_data.dart';
import '../models/chat.dart';
import '../models/message.dart';
import 'chat_engine.dart';

class ChatStore extends ChangeNotifier {
  static const String _storageKey = 'saved_chats';

  final ChatEngine _engine = ChatEngine();

  final List<Chat> _chats = <Chat>[];
  final Set<String> _typingChats = <String>{};

  SharedPreferences? _prefs;

  bool _loaded = false;

  ChatStore();

  List<Chat> get chats => List.unmodifiable(_chats);

  bool get isLoaded => _loaded;

  bool isTyping(String chatId) {
    return _typingChats.contains(chatId);
  }

  Chat? getChat(String id) {
    for (final chat in _chats) {
      if (chat.id == id) {
        return chat;
      }
    }

    return null;
  }

  Future<void> removeChat(String chatId) async {
    final before = _chats.length;
    _chats.removeWhere((chat) => chat.id == chatId);
    _typingChats.remove(chatId);
    if (_chats.length == before) return;

    await _save();
    notifyListeners();
  }

  Future<void> load() async {
    if (_loaded) return;

    _prefs = await SharedPreferences.getInstance();

    final saved = _prefs!.getString(_storageKey);

    _chats.clear();

    if (saved == null || saved.isEmpty) {
      _chats.addAll(
        createInitialChats(),
      );
    } else {
      try {
        final decoded = jsonDecode(saved);

        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              final chat = _chatFromJson(
                Map<String, dynamic>.from(item),
              );

              if (chat != null) {
                _chats.add(chat);
              }
            }
          }
        }

        if (_chats.isEmpty) {
          _chats.addAll(
            createInitialChats(),
          );
        }
      } catch (_) {
        // Если сохранение повреждено,
        // возвращаем первоначальные данные.
        _chats
          ..clear()
          ..addAll(
            createInitialChats(),
          );
      }
    }

    // Миграция с предыдущей версии: LIVEN теперь относится только к чатам
    // внутри KGE, поэтому удаляем старую запись из обычного мессенджера.
    final hadLegacyLiven = _chats.any((chat) => chat.id == 'liven');
    if (hadLegacyLiven) {
      _chats.removeWhere((chat) => chat.id == 'liven');
      if (_chats.isEmpty) {
        _chats.addAll(createInitialChats());
      }
      await _save();
    }

    _loaded = true;

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = _prefs ??
        await SharedPreferences.getInstance();

    _prefs = prefs;

    final data = _chats
        .map(_chatToJson)
        .toList();

    await prefs.setString(
      _storageKey,
      jsonEncode(data),
    );
  }

  Future<void> clearSavedChats() async {
    _chats
      ..clear()
      ..addAll(
        createInitialChats(),
      );

    await _save();

    notifyListeners();
  }

  void markRead(String chatId) {
    final chat = getChat(chatId);

    if (chat == null ||
        chat.unreadCount == 0) {
      return;
    }

    chat.unreadCount = 0;

    unawaited(_save());

    notifyListeners();
  }

  void addIncomingMessage(
      String chatId,
      String text,
      ) {
    final chat = getChat(chatId);
    final cleanText = text.trim();

    if (chat == null || cleanText.isEmpty) {
      return;
    }

    final now = DateTime.now();

    chat.messages.add(
      Message(
        id: '${chatId}-incoming-${now.microsecondsSinceEpoch}',
        text: cleanText,
        isMine: false,
        time: now,
        status: MessageStatus.read,
      ),
    );

    chat.unreadCount += 1;
    _moveToTop(chat);

    unawaited(_save());
    notifyListeners();
  }

  void sendMessage(
      String chatId,
      String text,
      ) {
    final chat = getChat(chatId);
    final cleanText = text.trim();

    if (chat == null ||
        cleanText.isEmpty) {
      return;
    }

    final now = DateTime.now();

    final message = Message(
      id:
      '${chatId}-${now.microsecondsSinceEpoch}',
      text: cleanText,
      isMine: true,
      time: now,
      status: MessageStatus.sent,
    );

    chat.messages.add(message);

    _moveToTop(chat);

    unawaited(_save());

    notifyListeners();

    _typingChats.add(chat.id);

    notifyListeners();

    Timer(
      const Duration(
        milliseconds: 1200,
      ),
          () {
        final currentChat =
        getChat(chatId);

        if (currentChat == null) {
          _typingChats.remove(chatId);
          notifyListeners();
          return;
        }

        _typingChats.remove(chatId);

        final reply =
        _engine.replyFor(
          currentChat,
          cleanText,
        );

        currentChat.messages.add(
          Message(
            id:
            '${chatId}-reply-${DateTime.now().microsecondsSinceEpoch}',
            text: reply,
            isMine: false,
            time: DateTime.now(),
            status: MessageStatus.read,
          ),
        );

        currentChat.unreadCount += 1;

        _moveToTop(currentChat);

        unawaited(_save());

        notifyListeners();
      },
    );
  }

  void _moveToTop(Chat chat) {
    _chats.remove(chat);
    _chats.insert(0, chat);
  }

  // ========================================================================
  // СЕРИАЛИЗАЦИЯ CHAT
  // ========================================================================

  Map<String, dynamic> _chatToJson(
      Chat chat,
      ) {
    return {
      'id': chat.id,
      'name': chat.name,
      'initials': chat.initials,
      'type': chat.type.name,
      'isOnline': chat.isOnline,
      'isArchived': chat.isArchived,
      'unreadCount': chat.unreadCount,
      'messages': chat.messages
          .map(_messageToJson)
          .toList(),
    };
  }

  Chat? _chatFromJson(
      Map<String, dynamic> json,
      ) {
    try {
      final typeName =
      json['type']?.toString();

      final type = ChatType.values
          .where(
            (value) =>
        value.name == typeName,
      )
          .firstOrNull;

      if (type == null) {
        return null;
      }

      final rawMessages =
      json['messages'];

      final messages =
      <Message>[];

      if (rawMessages is List) {
        for (final item
        in rawMessages) {
          if (item is Map) {
            final message =
            _messageFromJson(
              Map<String, dynamic>.from(
                item,
              ),
            );

            if (message != null) {
              messages.add(message);
            }
          }
        }
      }

      return Chat(
        id: json['id']?.toString() ?? '',
        name:
        json['name']?.toString() ??
            '',
        initials:
        json['initials']
            ?.toString() ??
            '',
        type: type,
        isOnline:
        json['isOnline'] == true,
        isArchived:
        json['isArchived'] == true,
        unreadCount:
        _readInt(
          json['unreadCount'],
        ),
        messages: messages,
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _messageToJson(
      Message message,
      ) {
    return {
      'id': message.id,
      'text': message.text,
      'isMine': message.isMine,
      'time':
      message.time?.toIso8601String(),
      'status':
      message.status.name,
    };
  }

  Message? _messageFromJson(
      Map<String, dynamic> json,
      ) {
    try {
      final statusName =
      json['status']?.toString();

      final status = MessageStatus.values
          .where(
            (value) =>
        value.name == statusName,
      )
          .firstOrNull;

      if (status == null) {
        return null;
      }

      DateTime? time;

      final rawTime =
      json['time']?.toString();

      if (rawTime != null &&
          rawTime.isNotEmpty) {
        time = DateTime.tryParse(
          rawTime,
        );
      }

      return Message(
        id: json['id']?.toString() ?? '',
        text:
        json['text']?.toString() ??
            '',
        isMine:
        json['isMine'] == true,
        time: time ?? DateTime.now(),
        status: status,
      );
    } catch (_) {
      return null;
    }
  }

  int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }
}