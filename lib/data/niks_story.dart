class StoryChoice {
  final String id;
  final String text;

  const StoryChoice({
    required this.id,
    required this.text,
  });
}

class StoryStep {
  final String id;
  final List<String> messages;
  final List<StoryChoice> choices;
  final bool showKgeApk;
  final bool unlockShop;
  final String? imageAsset;
  /// Exact incoming message after which an attached image should appear.
  final String? imageAfterMessageText;

  // Если true, между двумя соседними сообщениями
  // сначала показывается «печатает...».
  final bool typingBetweenMessages;

  final Duration typingDelay;

  const StoryStep({
    required this.id,
    this.messages = const [],
    this.choices = const [],
    this.showKgeApk = false,
    this.unlockShop = false,
    this.imageAsset,
    this.imageAfterMessageText,
    this.typingBetweenMessages = false,
    this.typingDelay = const Duration(
      milliseconds: 1200,
    ),
  });
}

class NiksStory {
  static const List<StoryStep> steps = [
    // ================================================================
    // НАЧАЛО
    // ================================================================

    StoryStep(
      id: 'start',
      choices: [
        StoryChoice(
          id: 'greeting',
          text: 'Здаров',
        ),
        StoryChoice(
          id: 'what',
          text: 'Чё те?',
        ),
      ],
    ),

    // ================================================================
    // ПРИЛОЖЕНИЕ
    // ================================================================

    StoryStep(
      id: 'app',
      messages: [
        'Я тут рылся и нашёл одну приложуху.',
      ],
      choices: [
        StoryChoice(
          id: 'virus',
          text: 'Очередной вирусняк какой-нибудь?',
        ),
      ],
    ),

    // ================================================================
    // KGE.APK
    // ================================================================

    StoryStep(
      id: 'apk',
      messages: [
        'Нееее чел, чекай.',
      ],
      showKgeApk: true,
    ),

    // ================================================================
    // ПОСЛЕ ПРОСМОТРА KGE
    // ================================================================

    StoryStep(
      id: 'kge_followup',
      messages: [
        'Ну как? Правда зачёт?',
      ],
      choices: [
        StoryChoice(
          id: 'kge_what_is_this',
          text: 'Что за хрень ты мне скинул?',
        ),
        StoryChoice(
          id: 'kge_legal',
          text: 'Это вообще законно?',
        ),
      ],
    ),

    // ================================================================
    // ВЕТКА «ЭТО ВООБЩЕ ЗАКОННО?»
    // ================================================================

    StoryStep(
      id: 'kge_legal_reply',
      messages: [
        'Незаконно это нихрена!',
        'Попробуй полазать в нём, может, понравится.',
      ],
      typingBetweenMessages: true,
      typingDelay: Duration(
        milliseconds: 900,
      ),
      choices: [
        StoryChoice(
          id: 'experience_question',
          text: 'И как давно ты таким занимаешься?',
        ),
      ],
    ),

    // ================================================================
    // ВЕТКА «ЧТО ЗА ХРЕНЬ ТЫ МНЕ СКИНУЛ?»
    // ================================================================

    StoryStep(
      id: 'kge_what_reply',
      messages: [
        'Да ладно тебе.',
        'Попробуй полазать в нём, может, понравится.',
      ],
      typingBetweenMessages: true,
      typingDelay: Duration(
        milliseconds: 900,
      ),
      choices: [
        StoryChoice(
          id: 'experience_question',
          text: 'И как давно ты таким занимаешься?',
        ),
      ],
    ),

    // ================================================================
    // ОПЫТ НИКСА
    // ================================================================

    StoryStep(
      id: 'experience_answer',
      messages: [
        'Достаточно :)',
      ],
      choices: [
        StoryChoice(
          id: 'hesitation',
          text: 'Не думаю, что мне стоит лезть сюда.',
        ),
      ],
    ),

    // ================================================================
    // ПРЕДУПРЕЖДЕНИЕ
    // ================================================================

    StoryStep(
      id: 'warning',
      messages: [
        'Уже поздно о чём-то думать. Твой ID засветился здесь, и тебе придётся научиться хакингу, чтобы отбиваться от мудил.',
      ],
      choices: [
        StoryChoice(
          id: 'retort',
          text: 'От таких, как ты, что ли?',
        ),
      ],
    ),

    // ================================================================
    // ФИНАЛЬНАЯ МИНИ-СЦЕНА
    // ================================================================

    StoryStep(
      id: 'final_reply',
      messages: [
        'Очень смешно.',
        'Я вообще-то серьёзно.',
      ],
      typingBetweenMessages: true,
      typingDelay: Duration(
        milliseconds: 1200,
      ),
      choices: [
        StoryChoice(
          id: 'serious_reply',
          text: 'Так я тоже.',
        ),
      ],
    ),

    StoryStep(
      id: 'serious_reply',
      messages: [
        'В общем, развлекайся.',
      ],
      choices: [
        StoryChoice(
          id: 'reputation_question',
          text: 'Я тут посмотрел. Что означает «репутация»?',
        ),
      ],
    ),

    StoryStep(
      id: 'reputation_answer',
      messages: [
        'Если кратко, то это твой рейтинг в мире «хакеров».',
      ],
      choices: [
        StoryChoice(
          id: 'hackers_question',
          text: 'Чё, прям хакеров?)',
        ),
      ],
    ),

    StoryStep(
      id: 'hackers_reply',
      messages: [
        'Рад, что ты веселишься. В общем, развлекайся.',
        'Не забудь заглянуть в магазин KGE, я зарегал тебя там!',
      ],
      typingBetweenMessages: true,
      typingDelay: Duration(
        milliseconds: 1200,
      ),
      unlockShop: true,
    ),

    // ================================================================
    // ПОСЛЕ ПРОВЕРКИ МАГАЗИНА
    // ================================================================

    StoryStep(
      id: 'shop_followup',
      messages: [
        'Ну что?',
        'Готов наконец-то заняться делом?',
      ],
      choices: [
        StoryChoice(
          id: 'shop_yes',
          text: 'Да...',
        ),
        StoryChoice(
          id: 'shop_choice',
          text: 'А у меня есть выбор?',
        ),
      ],
      typingBetweenMessages: true,
      typingDelay: Duration(
        milliseconds: 1200,
      ),
    ),

    StoryStep(
      id: 'shop_agree_reply',
      messages: [
        'Вот и отлично.',
        'Я добавляю тебя в систему.',
      ],
      choices: [
        StoryChoice(
          id: 'system_question',
          text: 'Я думал, что уже там состою.',
        ),
      ],
      typingBetweenMessages: true,
      typingDelay: Duration(
        milliseconds: 1200,
      ),
    ),

    StoryStep(
      id: 'system_reply',
      messages: [
        'Лишь поверхностно...',
        'В общем... Это не важно, пора заняться делом!',
      ],
      choices: [
        StoryChoice(
          id: 'start_work',
          text: 'Ну тогда делай, что нужно.',
        ),
      ],
      typingBetweenMessages: true,
      typingDelay: Duration(
        milliseconds: 1200,
      ),
    ),

    StoryStep(
      id: 'kge_update',
      messages: [
        'Расширение «KGE» обновлено.',
        'Проверяй.',
      ],
      typingBetweenMessages: true,
      typingDelay: Duration(
        milliseconds: 1200,
      ),
    ),

    // Альтернативная ветка после отказа от предложения LIVEN.
    StoryStep(
      id: 'kge_removed_niks_start',
      choices: [
        StoryChoice(id: 'kge_removed_niks_reply', text: 'Да так…'),
      ],
    ),
    StoryStep(
      id: 'kge_removed_niks_followup',
      choices: [
        StoryChoice(
          id: 'kge_removed_niks_final_choice',
          text: 'Думаю, мне лучше отказаться от всего этого мира.',
        ),
      ],
    ),
    StoryStep(
      id: 'kge_removed_niks_final',
      messages: [
        'Что ж, если ты так решил, я никак не могу на тебя повлиять.',
      ],
    ),

  ];

  static StoryStep? getStep(String id) {
    for (final step in steps) {
      if (step.id == id) {
        return step;
      }
    }

    return null;
  }

  static String? getNextStep(String choiceId) {
    switch (choiceId) {
    // --------------------------------------------------------------
    // НАЧАЛО
    // --------------------------------------------------------------

      case 'greeting':
      case 'what':
        return 'app';

    // --------------------------------------------------------------
    // ПРИЛОЖЕНИЕ
    // --------------------------------------------------------------

      case 'virus':
        return 'apk';

    // --------------------------------------------------------------
    // ПОСЛЕ KGE
    // --------------------------------------------------------------

      case 'kge_legal':
        return 'kge_legal_reply';

      case 'kge_what_is_this':
        return 'kge_what_reply';

    // --------------------------------------------------------------
    // ОБЩАЯ ВЕТКА
    // --------------------------------------------------------------

      case 'experience_question':
        return 'experience_answer';

      case 'hesitation':
        return 'warning';

      case 'retort':
        return 'final_reply';

      case 'serious_reply':
        return 'serious_reply';

      case 'reputation_question':
        return 'reputation_answer';

      case 'hackers_question':
        return 'hackers_reply';

      case 'shop_yes':
      case 'shop_choice':
        return 'shop_agree_reply';

      case 'system_question':
        return 'system_reply';

      case 'start_work':
        return 'kge_update';

      case 'kge_removed_niks_reply':
        return 'kge_removed_niks_followup';

      case 'kge_removed_niks_final_choice':
        return 'kge_removed_niks_final';

      default:
        return null;
    }
  }
}