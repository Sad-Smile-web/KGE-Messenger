import 'message.dart';

enum ChatType {
  personal,
  group,
}

class Chat {
  final String id;
  final String name;
  final String initials;
  final ChatType type;
  final bool isOnline;
  final bool isArchived;
  final List<Message> messages;
  int unreadCount;

  Chat({
    required this.id,
    required this.name,
    required this.initials,
    required this.type,
    required this.isOnline,
    required this.isArchived,
    required this.messages,
    this.unreadCount = 0,
  });

  Message? get lastMessage => messages.isEmpty ? null : messages.last;
}
