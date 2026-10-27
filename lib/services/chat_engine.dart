import '../models/chat.dart';
import 'app_localization.dart';

class ChatEngine {
  String replyFor(Chat chat, String userText) {
    final text = userText.trim().toLowerCase();

    if (chat.id == 'nika') {
      if (text.contains('привет') || text.contains('hello') || text == 'hi') return L10n.t('Привет. Да, я здесь.');
      if (text.contains('как') || text.contains('how')) return L10n.t('Нормально. А у тебя?');
      if (text.contains('пока') || text.contains('bye') || text.contains('goodbye')) return L10n.t('Пока. Напиши потом.');
      return L10n.t('Понял. Сейчас отвечу подробнее.');
    }

    if (chat.id == 'artem') {
      if (text.contains('файл') || text.contains('file')) return L10n.t('Да, скину чуть позже.');
      return L10n.t('Окей, посмотрю.');
    }

    if (chat.id == 'study') {
      return L10n.t('Принято. Я буду.');
    }

    if (chat.id == 'mama') {
      return L10n.t('Хорошо, не переживай.');
    }

    if (chat.id == 'dima') {
      return L10n.t('Сейчас не могу говорить. Напишу позже.');
    }

    if (chat.id == 'work') {
      return L10n.t('Принял. Спасибо.');
    }

    return L10n.t('Сообщение получено.');
  }
}
