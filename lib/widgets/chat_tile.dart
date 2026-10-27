import 'package:flutter/material.dart';

import '../models/chat.dart';
import '../services/story_session_store.dart';
import '../services/app_localization.dart';
import 'l10n_text.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
  });

  bool get _isStoryChat => chat.id == 'nika';

  @override
  Widget build(BuildContext context) {
    final storySession = _isStoryChat
        ? StorySessionStore.instance.getForChat(chat)
        : null;

    final messages = storySession?.messages ?? chat.messages;

    final last = messages.isNotEmpty
        ? messages.last
        : chat.lastMessage;

    final preview = last?.text ?? 'Нет сообщений';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        child: Row(
          children: [
            _Avatar(
              chat: chat,
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: L10nText(
                          chat.name,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: const TextStyle(
                            color:
                            Color(0xFF101827),
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Text(
                        _formatTime(
                          last?.time,
                        ),
                        style: TextStyle(
                          color:
                          chat.unreadCount > 0
                              ? const Color(
                            0xFF1976F3,
                          )
                              : const Color(
                            0xFF8B95A7,
                          ),
                          fontSize: 12,
                          fontWeight:
                          chat.unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: L10nText(
                          preview,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                            last?.isMine == true
                                ? const Color(
                              0xFF657186,
                            )
                                : const Color(
                              0xFF7C8799,
                            ),
                            fontSize: 14,
                          ),
                        ),
                      ),

                      if (chat.unreadCount > 0) ...[
                        const SizedBox(
                          width: 8,
                        ),

                        Container(
                          width: 22,
                          height: 22,
                          alignment:
                          Alignment.center,
                          decoration:
                          const BoxDecoration(
                            color:
                            Color(0xFF1976F3),
                            shape:
                            BoxShape.circle,
                          ),
                          child: Text(
                            chat.unreadCount > 99
                                ? '99+'
                                : '${chat.unreadCount}',
                            style:
                            const TextStyle(
                              color:
                              Colors.white,
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? value) {
    if (value == null) {
      return '';
    }

    final now = DateTime.now();

    final sameDay =
        now.year == value.year &&
            now.month == value.month &&
            now.day == value.day;

    if (!sameDay) {
      return L10n.t('Вчера');
    }

    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }
}

class _Avatar extends StatelessWidget {
  final Chat chat;

  const _Avatar({
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    final bg = chat.type == ChatType.group
        ? const Color(0xFF48617C)
        : const Color(0xFFDDE4EE);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
          ),
          alignment: Alignment.center,
          child: chat.type == ChatType.group
              ? const Icon(Icons.people_alt_rounded, color: Colors.white, size: 25)
              : L10nText(
                  L10n.chatInitials(chat.name),
                  style: const TextStyle(
                    color: Color(0xFF213044),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),

        if (chat.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF18B65B,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
