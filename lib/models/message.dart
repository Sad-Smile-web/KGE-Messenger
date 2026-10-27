enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
}

class Message {
  final String id;
  final String text;
  final bool isMine;
  final DateTime time;
  MessageStatus status;

  Message({
    required this.id,
    required this.text,
    required this.isMine,
    required this.time,
    this.status = MessageStatus.read,
  });
}
