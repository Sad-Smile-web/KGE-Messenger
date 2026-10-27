import 'package:flutter/material.dart';

import '../models/chat.dart';
import '../services/chat_store.dart';
import '../widgets/l10n_text.dart';
import '../services/app_localization.dart';
import '../services/language_store.dart';


class SearchScreen extends StatefulWidget {
  final ChatStore store;

  const SearchScreen({super.key, required this.store});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Chat> get _results {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) return widget.store.chats.where((c) => !c.isArchived).toList();

    return widget.store.chats.where((chat) {
      if (chat.isArchived) return false;
      if (L10n.t(chat.name).toLowerCase().contains(query)) return true;
      final last = L10n.t(chat.lastMessage?.text ?? '').toLowerCase();
      return last.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.store, LanguageStore.instance]),
      builder: (context, _) {
        final results = _results;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: L10n.t('Поиск'),
                filled: true,
                fillColor: Color(0xFFF1F4F9),
                prefixIcon: Icon(Icons.search_rounded),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              ),
            ),
          ),
          body: results.isEmpty
              ? const Center(
                  child: L10nText('Ничего не найдено',
                    style: TextStyle(
                      color: Color(0xFF8A95A6),
                      fontSize: 15,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(top: 6, bottom: 20),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 84,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final chat = results[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      leading: _SearchAvatar(chat: chat),
                      title: L10nText(
                        chat.name,
                        style: const TextStyle(
                          color: Color(0xFF121826),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: L10nText(
                        chat.lastMessage?.text ?? 'Нет сообщений',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        widget.store.markRead(chat.id);
                        Navigator.pushNamed(
                          context,
                          '/chat',
                          arguments: chat.id,
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}

class _SearchAvatar extends StatelessWidget {
  final Chat chat;

  const _SearchAvatar({required this.chat});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: chat.type == ChatType.group
            ? const Color(0xFF48617C)
            : const Color(0xFFDDE4EE),
      ),
      child: chat.type == ChatType.group
          ? const Icon(Icons.people_alt_rounded, color: Colors.white)
          : L10nText(
              chat.initials,
              style: const TextStyle(
                color: Color(0xFF253248),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
