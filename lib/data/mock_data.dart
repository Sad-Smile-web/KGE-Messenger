import '../models/chat.dart';
import '../models/message.dart';

DateTime _todayAt(int hour, int minute) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}

List<Chat> createInitialChats() {
  return [
    Chat(
      id: 'nika',
      name: 'Никс',
      initials: 'Н',
      type: ChatType.personal,
      isOnline: true,
      isArchived: false,
      unreadCount: 2,
      messages: [
        Message(
          id: 'nika-1',
          text: 'Привет!',
          isMine: false,
          time: _todayAt(12, 24),
          status: MessageStatus.read,
        ),
        Message(
          id: 'nika-2',
          text: 'Живой?',
          isMine: false,
          time: _todayAt(12, 28),
          status: MessageStatus.read,
        ),
      ],
    ),
    Chat(
      id: 'artem',
      name: 'Артём',
      initials: 'А',
      type: ChatType.personal,
      isOnline: false,
      isArchived: false,
      unreadCount: 1,
      messages: [
        Message(
          id: 'artem-1',
          text: 'Так что там у тебя случилось?',
          isMine: false,
          time: _todayAt(11, 50),
          status: MessageStatus.read,
        ),
        Message(
          id: 'artem-2',
          text: 'Меня недавно взламывали, пришлось все чаты почистить.',
          isMine: true,
          time: _todayAt(11, 51),
          status: MessageStatus.read,
        ),
        Message(
          id: 'artem-3',
          text: 'Фига, жаль.',
          isMine: false,
          time: _todayAt(11, 52),
          status: MessageStatus.read,
        ),
        Message(
          id: 'artem-4',
          text: 'Надеюсь, что в этой версии «Связь» прокачала свою безопасность.',
          isMine: true,
          time: _todayAt(11, 53),
          status: MessageStatus.read,
        ),
      ],
    ),
    Chat(
      id: 'study',
      name: 'Учёба',
      initials: 'У',
      type: ChatType.group,
      isOnline: false,
      isArchived: false,
      unreadCount: 6,
      messages: [
        Message(
          id: 'study-1',
          text: 'Народ, во сколько сегодня начинаем?',
          isMine: false,
          time: _todayAt(9, 47),
          status: MessageStatus.read,
        ),
        Message(
          id: 'study-2',
          text: 'Кто уже сделал практическую?',
          isMine: false,
          time: _todayAt(10, 03),
          status: MessageStatus.read,
        ),
        Message(
          id: 'study-3',
          text: 'Скиньте, пожалуйста, задание ещё раз.',
          isMine: false,
          time: _todayAt(10, 21),
          status: MessageStatus.read,
        ),
        Message(
          id: 'study-4',
          text: 'Я сегодня немного задержусь.',
          isMine: false,
          time: _todayAt(10, 38),
          status: MessageStatus.read,
        ),
        Message(
          id: 'study-5',
          text: 'Кто-нибудь знает, что будет на следующей паре?',
          isMine: false,
          time: _todayAt(11, 02),
          status: MessageStatus.read,
        ),
      ],
    ),
    Chat(
      id: 'mama',
      name: 'Мама',
      initials: 'М',
      type: ChatType.personal,
      isOnline: false,
      isArchived: false,
      unreadCount: 0,
      messages: [
        Message(
          id: 'mama-1',
          text: 'Хорошо, не забудь поесть.',
          isMine: false,
          time: _todayAt(9, 18),
          status: MessageStatus.read,
        ),
      ],
    ),
    Chat(
      id: 'work',
      name: 'Работа',
      initials: 'Р',
      type: ChatType.group,
      isOnline: false,
      isArchived: false,
      unreadCount: 0,
      messages: [
        Message(
          id: 'work-1',
          text: 'Мы отказываем вам в предоставлении работы',
          isMine: false,
          time: DateTime.now().subtract(const Duration(days: 1)),
          status: MessageStatus.delivered,
        ),
      ],
    ),
    Chat(
      id: 'archive',
      name: 'Архивные',
      initials: 'А',
      type: ChatType.group,
      isOnline: false,
      isArchived: true,
      unreadCount: 0,
      messages: [
        Message(
          id: 'archive-1',
          text: 'Старые сообщения',
          isMine: false,
          time: DateTime.now().subtract(const Duration(days: 3)),
          status: MessageStatus.read,
        ),
      ],
    ),
  ];
}
