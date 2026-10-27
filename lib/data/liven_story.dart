import 'niks_story.dart';

/// Сюжетная цепочка LIVEN. Новые тексты оставлены только на русском.
class LivenStory {
  static const List<StoryStep> steps = [
    StoryStep(
      id: 'liven_who',
      choices: [
        StoryChoice(id: 'liven_ask_who', text: 'Ты кто?'),
      ],
    ),
    StoryStep(
      id: 'liven_offer',
      messages: ['Много вопросов, быстрее решай.'],
      choices: [
        StoryChoice(
          id: 'liven_accept_offer',
          text: 'Ладно... Говори, что там у тебя.',
        ),
        StoryChoice(
          id: 'liven_refuse_offer',
          text: 'Нет, пожалуй, откажусь.',
        ),
      ],
    ),
    StoryStep(
      id: 'liven_work_in_development',
      messages: ['Эта часть линии ещё в разработке.'],
      choices: [
        StoryChoice(
          id: 'liven_accept_offer',
          text: 'Ладно... Говори, что там у тебя.',
        ),
        StoryChoice(
          id: 'liven_refuse_offer',
          text: 'Нет, пожалуй, откажусь.',
        ),
      ],
    ),
    StoryStep(
      id: 'liven_accept_intro',
      messages: ['Ты сделал правильный выбор!'],
      choices: [
        StoryChoice(id: 'liven_hope', text: 'Надеюсь...'),
      ],
    ),
    StoryStep(
      id: 'liven_job_intro',
      messages: [
        'Недавно мне предложили довольно простой заказ, но я не захотел мараться об него.',
        'Потом мне написал один человек и порекомендовал тебя.',
        'Это отличный шанс проверить твои способности и решить, давать ли тебе «полный» доступ к функциям расширения KGE.',
        'Так.',
        'Ближе к делу.',
        'Эти уроды ограбили магазин нашего заказчика.',
        'Твоя задача — тщательно проанализировать фотографию и выявить любые зацепки. Приложение сделает всё остальное.',
        'Понял?',
      ],
      imageAsset: 'assets/kge/Grab1.png',
      imageAfterMessageText: 'Ближе к делу.',
      choices: [
        StoryChoice(id: 'liven_understood_task', text: 'В общих чертах...'),
      ],
      typingBetweenMessages: true,
      typingDelay: Duration(milliseconds: 1500),
    ),
    StoryStep(
      id: 'liven_job_done',
      messages: ['Дерзай!'],
    ),
    StoryStep(
      id: 'liven_confirm_refusal',
      messages: ['Ты уверен? Я могу поднять тебе рейтинг.'],
      choices: [
        StoryChoice(
          id: 'liven_yes_sure',
          text: 'Да, уверен',
        ),
        StoryChoice(
          id: 'liven_not_sure',
          text: 'Нет, не уверен',
        ),
      ],
    ),
];

  static StoryStep? getStep(String id) {
    for (final step in steps) {
      if (step.id == id) return step;
    }
    return null;
  }

  static String? getNextStep(String choiceId) {
    switch (choiceId) {
      case 'liven_ask_who':
        return 'liven_offer';
      case 'liven_accept_offer':
        return 'liven_accept_intro';
      case 'liven_hope':
        return 'liven_job_intro';
      case 'liven_understood_task':
        return 'liven_job_done';
      case 'liven_refuse_offer':
        return 'liven_confirm_refusal';
      case 'liven_not_sure':
        // При сомнении LIVEN снова предлагает оба исходных варианта.
        return 'liven_offer';
      default:
        return null;
    }
  }
}
