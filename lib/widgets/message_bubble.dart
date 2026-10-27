import 'package:flutter/material.dart';

import '../models/message.dart';
import 'l10n_text.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: EdgeInsets.only(
          left: isMine ? 60 : 12,
          right: isMine ? 12 : 60,
          bottom: 8,
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 12, 7),
        decoration: BoxDecoration(
          color: isMine
              ? const Color(0xFFD2E7FF)
              : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 18),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: L10nText(
                message.text,
                style: const TextStyle(
                  color: Color(0xFF182334),
                  fontSize: 16,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatTime(message.time),
              style: const TextStyle(
                color: Color(0xFF8994A5),
                fontSize: 10,
              ),
            ),
            if (isMine) ...[
              const SizedBox(width: 3),
              Icon(
                message.status == MessageStatus.sending
                    ? Icons.schedule_rounded
                    : Icons.done_all_rounded,
                size: 15,
                color: const Color(0xFF3A85D8),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}
