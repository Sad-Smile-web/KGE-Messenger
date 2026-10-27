import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageStore extends ChangeNotifier {
  static const String _languageKey = 'app_language';

  static LanguageStore? _instance;

  final SharedPreferences _prefs;
  String _languageCode;

  LanguageStore._(this._prefs, this._languageCode);

  static LanguageStore get instance {
    final value = _instance;
    if (value == null) {
      throw StateError(
        'LanguageStore.instance is not initialized. '
        'Call LanguageStore.load() before runApp().',
      );
    }
    return value;
  }

  static Future<LanguageStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_languageKey);
    final code = const {'ru', 'en', 'zh', 'es'}.contains(stored) ? stored! : 'ru';

    final store = LanguageStore._(prefs, code);
    _instance = store;

    return store;
  }

  String get code => _languageCode;
  bool get isEnglish => _languageCode == 'en';
  bool get isSpanish => _languageCode == 'es';
  bool get isChinese => _languageCode == 'zh';
  String get name => switch (_languageCode) {
        'en' => 'English',
        'zh' => '简体中文',
        'es' => 'Español',
        _ => 'Русский',
      };

  Future<void> setLanguage(String code) async {
    final next = const {'ru', 'en', 'zh', 'es'}.contains(code) ? code : 'ru';

    if (_languageCode == next) {
      return;
    }

    _languageCode = next;

    await _prefs.setString(_languageKey, next);
    notifyListeners();
  }
}
