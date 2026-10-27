import 'package:flutter/material.dart';

import '../services/app_localization.dart';
import '../services/chat_store.dart';
import '../services/kge_store.dart';
import '../services/language_store.dart';
import '../services/notes_task_store.dart';
import '../services/story_session_store.dart';
import '../widgets/l10n_text.dart';

class NotesScreen extends StatelessWidget {
  final ChatStore chatStore;
  final KgeStore kgeStore;

  const NotesScreen({
    super.key,
    required this.chatStore,
    required this.kgeStore,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        chatStore,
        kgeStore,
        StorySessionStore.instance,
        LanguageStore.instance,
      ]),
      builder: (context, _) {
        final stage = NotesTaskStore.stage(
          chatStore: chatStore,
          kgeStore: kgeStore,
        );
        // Opening or viewing a newly advanced task clears its unread badge.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            NotesTaskStore.markSeen(stage);
          }
        });

        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              tooltip: L10n.t('Назад'),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            titleSpacing: 0,
            title: const Row(
              children: [
                _NotesHeaderIcon(),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    L10nText('Заметки',
                      style: TextStyle(
                        color: Color(0xFF101827),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    L10nText('Сюжетные задания',
                      style: TextStyle(
                        color: Color(0xFF7D899A),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(18, 17, 18, 17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFDDE5F0),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 18,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.push_pin_rounded,
                          color: Color(0xFF1976F3),
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        const L10nText('Закреплено',
                          style: TextStyle(
                            color: Color(0xFF1976F3),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_completedCount(stage)}',
                          style: const TextStyle(
                            color: Color(0xFF92A0B2),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const L10nText('Следи за этими заданиями, чтобы понимать, что делать дальше.',
                      style: TextStyle(
                        color: Color(0xFF5F6D80),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (stage.index > 0) ...[
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    splashColor: const Color(0x141976F3),
                    highlightColor: Colors.transparent,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3F8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE0E6EF)),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 15),
                      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      leading: const Icon(Icons.task_alt_rounded, color: Color(0xFF8492A6)),
                      title: const L10nText('Выполненные задания',
                        style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF536176)),
                      ),
                      subtitle: Text(
                        '${L10n.t('Выполнено:')} ${stage.index}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF8492A6)),
                      ),
                      children: List.generate(stage.index, (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _TaskRow(
                          label: NotesTaskStore.taskLabels[index],
                          completed: true,
                          active: false,
                        ),
                      )),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (stage != NotesTaskStage.completed)
                _TaskMessageCard(label: NotesTaskStore.activeTask(stage)),
              if (stage == NotesTaskStage.completed)
                const _TaskMessageCard(
                  label: 'Здесь пока ничего нет (полазай пока в расширении KGE)',
                ),
            ],
          ),
        );
      },
    );
  }

  int _completedCount(NotesTaskStage stage) => stage.index;

}

class _TaskMessageCard extends StatelessWidget {
  final String label;
  const _TaskMessageCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 15, 17, 17),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFF8DBBFA), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x151976F3), blurRadius: 14, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.notifications_active_rounded, color: Color(0xFF1976F3), size: 17),
            const SizedBox(width: 7),
            const Expanded(child: L10nText('НОВОЕ ЗАДАНИЕ',
              style: TextStyle(color: Color(0xFF1976F3), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.1),
            )),
            const L10nText('СИСТЕМА', style: TextStyle(color: Color(0xFF6F91BD), fontSize: 9, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 10),
          L10nText(label, style: const TextStyle(color: Color(0xFF172A43), fontSize: 15, height: 1.4, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const L10nText('Сообщение системы заданий', style: TextStyle(color: Color(0xFF6683A9), fontSize: 11)),
        ],
      ),
    );
  }
}

class _NotesHeaderIcon extends StatelessWidget {
  const _NotesHeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFD5E5FA),
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.sticky_note_2_outlined,
        color: Color(0xFF1976F3),
        size: 20,
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final String label;
  final bool completed;
  final bool active;

  const _TaskRow({
    required this.label,
    required this.completed,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final Color background = completed
        ? const Color(0xFFF1F3F6)
        : active
            ? Colors.white
            : const Color(0xFFFAFBFD);

    final Color border = completed
        ? const Color(0xFFE1E5EB)
        : active
            ? const Color(0xFFBDD8FF)
            : const Color(0xFFE6EBF2);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? const Color(0xFFD8DDE5)
                  : active
                      ? const Color(0xFFEAF3FF)
                      : Colors.transparent,
              border: Border.all(
                color: completed
                    ? const Color(0xFFC5CBD4)
                    : active
                        ? const Color(0xFF8EB9F5)
                        : const Color(0xFFC9D2DE),
                width: 1.4,
              ),
            ),
            child: completed
                ? const Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: Color(0xFF7A8595),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: L10nText(
              label,
              style: TextStyle(
                color: completed
                    ? const Color(0xFFA0A9B6)
                    : active
                        ? const Color(0xFF1B2737)
                        : const Color(0xFF667386),
                fontSize: 15,
                fontWeight: active
                    ? FontWeight.w700
                    : FontWeight.w600,
                height: 1.3,
                decoration: completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: const Color(0xFF9BA5B2),
                decorationThickness: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
