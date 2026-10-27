import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum KgeColorTheme {
  purple,
  blue,
  green,
  red,
}

extension KgeColorThemeData on KgeColorTheme {
  String get id {
    switch (this) {
      case KgeColorTheme.purple:
        return 'purple';
      case KgeColorTheme.blue:
        return 'blue';
      case KgeColorTheme.green:
        return 'green';
      case KgeColorTheme.red:
        return 'red';
    }
  }

  String get label {
    switch (this) {
      case KgeColorTheme.purple:
        return 'Фиолетовый';
      case KgeColorTheme.blue:
        return 'Синий';
      case KgeColorTheme.green:
        return 'Зелёный';
      case KgeColorTheme.red:
        return 'Красный';
    }
  }

  Color get primary {
    switch (this) {
      case KgeColorTheme.purple:
        return const Color(0xFFB45CFF);
      case KgeColorTheme.blue:
        return const Color(0xFF4C8DFF);
      case KgeColorTheme.green:
        return const Color(0xFF45D483);
      case KgeColorTheme.red:
        return const Color(0xFFFF5A62);
    }
  }

  Color get brightText {
    switch (this) {
      case KgeColorTheme.purple:
        return const Color(0xFFF2E7FF);
      case KgeColorTheme.blue:
        return const Color(0xFFE6F0FF);
      case KgeColorTheme.green:
        return const Color(0xFFE4FFF0);
      case KgeColorTheme.red:
        return const Color(0xFFFFE8EA);
    }
  }

  Color get bodyText {
    switch (this) {
      case KgeColorTheme.purple:
        return const Color(0xFFD2C1DD);
      case KgeColorTheme.blue:
        return const Color(0xFFC4D5EA);
      case KgeColorTheme.green:
        return const Color(0xFFC4DEC9);
      case KgeColorTheme.red:
        return const Color(0xFFE3C3C7);
    }
  }

  Color get secondaryText {
    switch (this) {
      case KgeColorTheme.purple:
        return const Color(0xFFCDBADB);
      case KgeColorTheme.blue:
        return const Color(0xFFB9C9DC);
      case KgeColorTheme.green:
        return const Color(0xFFB7D3BF);
      case KgeColorTheme.red:
        return const Color(0xFFDDB9BD);
    }
  }

  Color get mutedText {
    switch (this) {
      case KgeColorTheme.purple:
        return const Color(0xFF755A88);
      case KgeColorTheme.blue:
        return const Color(0xFF5A78A7);
      case KgeColorTheme.green:
        return const Color(0xFF4E8964);
      case KgeColorTheme.red:
        return const Color(0xFFA35A61);
    }
  }

  Color get subtitle {
    switch (this) {
      case KgeColorTheme.purple:
        return const Color(0xFF9D8DAF);
      case KgeColorTheme.blue:
        return const Color(0xFF8EA5C2);
      case KgeColorTheme.green:
        return const Color(0xFF8EAD99);
      case KgeColorTheme.red:
        return const Color(0xFFB9969A);
    }
  }

  Color get panelBorder {
    switch (this) {
      case KgeColorTheme.purple:
        return const Color(0x664F16A8);
      case KgeColorTheme.blue:
        return const Color(0x66507CFF);
      case KgeColorTheme.green:
        return const Color(0x6640B96E);
      case KgeColorTheme.red:
        return const Color(0x66D9414D);
    }
  }

  Color get panelGlow {
    switch (this) {
      case KgeColorTheme.purple:
        return const Color(0x243F00A8);
      case KgeColorTheme.blue:
        return const Color(0x24406CFF);
      case KgeColorTheme.green:
        return const Color(0x2430A85D);
      case KgeColorTheme.red:
        return const Color(0x24C51D2E);
    }
  }

  Color get topLine {
    switch (this) {
      case KgeColorTheme.purple:
        return const Color(0x884F16A8);
      case KgeColorTheme.blue:
        return const Color(0x88507CFF);
      case KgeColorTheme.green:
        return const Color(0x8840B96E);
      case KgeColorTheme.red:
        return const Color(0x88D9414D);
    }
  }

  Color get panelTint {
    switch (this) {
      case KgeColorTheme.purple:
        return const Color(0x121A0030);
      case KgeColorTheme.blue:
        return const Color(0x12101E40);
      case KgeColorTheme.green:
        return const Color(0x120D2A1B);
      case KgeColorTheme.red:
        return const Color(0x122E0C12);
    }
  }

  Color get innerBorder {
    switch (this) {
      case KgeColorTheme.purple:
        return const Color(0x1F9A43D6);
      case KgeColorTheme.blue:
        return const Color(0x1F5689E8);
      case KgeColorTheme.green:
        return const Color(0x1F45B76D);
      case KgeColorTheme.red:
        return const Color(0x1FD94D59);
    }
  }

  Color get filterColor {
    switch (this) {
      case KgeColorTheme.purple:
        return const Color(0xFF7020A8);
      case KgeColorTheme.blue:
        return const Color(0xFF2563D8);
      case KgeColorTheme.green:
        return const Color(0xFF1C8D57);
      case KgeColorTheme.red:
        return const Color(0xFFB42D39);
    }
  }

  Color get centerGlow {
    switch (this) {
      case KgeColorTheme.purple:
        return const Color(0x553F0A68);
      case KgeColorTheme.blue:
        return const Color(0x553A55A8);
      case KgeColorTheme.green:
        return const Color(0x55358A5A);
      case KgeColorTheme.red:
        return const Color(0x55A33642);
    }
  }

  Color get scanline {
    switch (this) {
      case KgeColorTheme.purple:
        return const Color(0x553F00FF);
      case KgeColorTheme.blue:
        return const Color(0x55538BFF);
      case KgeColorTheme.green:
        return const Color(0x5548D985);
      case KgeColorTheme.red:
        return const Color(0x55FF4B57);
    }
  }

  Color get grid {
    switch (this) {
      case KgeColorTheme.purple:
        return const Color(0x1200FFFF);
      case KgeColorTheme.blue:
        return const Color(0x123C8DFF);
      case KgeColorTheme.green:
        return const Color(0x1245E28B);
      case KgeColorTheme.red:
        return const Color(0x12FF5560);
    }
  }

  Color get marker {
    switch (this) {
      case KgeColorTheme.purple:
        return const Color(0x553C1A70);
      case KgeColorTheme.blue:
        return const Color(0x55426BB2);
      case KgeColorTheme.green:
        return const Color(0x553D8C59);
      case KgeColorTheme.red:
        return const Color(0x55A43A45);
    }
  }
}

class KgeStore extends ChangeNotifier {
  static const String _installedKey = 'kge_installed';
  static const String _themeKey = 'kge_color_theme';
  static const String _accountConfiguredKey = 'kge_account_configured';
  static const String _loginKey = 'kge_login';
  static const String _passwordKey = 'kge_password';
  static const String _shopUnlockedKey = 'kge_shop_unlocked';
  static const String _shopNoticeSeenKey = 'kge_shop_notice_seen';
  static const String _locationTutorialPendingKey =
      'kge_location_tutorial_pending';
  static const String _kgeNotesUnlockedKey = 'kge_notes_unlocked';
  static const String _kgeNotesTutorialSeenKey = 'kge_notes_tutorial_seen';
  static const String _kgeChatsCheckedKey = 'kge_chats_checked';
  static const String _mirrorMessageSeenKey = 'kge_mirror_message_seen';
  static const String _newbiePackPurchasedKey = 'kge_newbie_pack_purchased';
  static const String _newbiePackInstalledKey = 'kge_newbie_pack_installed';

  static KgeStore? _instance;

  final SharedPreferences _prefs;

  KgeStore._(this._prefs);

  static KgeStore get instance {
    final store = _instance;
    if (store == null) {
      throw StateError(
        'KgeStore.instance is not initialized. '
        'Call KgeStore.load() before runApp().',
      );
    }
    return store;
  }

  static Future<KgeStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final store = KgeStore._(prefs);
    _instance = store;
    return store;
  }

  bool get isInstalled =>
      _prefs.getBool(_installedKey) ?? false;

  bool get isAccountConfigured =>
      _prefs.getBool(_accountConfiguredKey) ?? false;

  String get login => _prefs.getString(_loginKey) ?? '';

  String get accountPassword =>
      _prefs.getString(_passwordKey) ?? '';

  bool get shopUnlocked =>
      _prefs.getBool(_shopUnlockedKey) ?? false;

  bool get shopNoticeSeen =>
      _prefs.getBool(_shopNoticeSeenKey) ?? false;

  bool get locationTutorialPending =>
      _prefs.getBool(_locationTutorialPendingKey) ?? false;

  bool get kgeNotesUnlocked =>
      _prefs.getBool(_kgeNotesUnlockedKey) ?? false;

  bool get kgeNotesTutorialSeen =>
      _prefs.getBool(_kgeNotesTutorialSeenKey) ?? false;

  bool get kgeChatsChecked =>
      _prefs.getBool(_kgeChatsCheckedKey) ?? false;

  bool get mirrorMessageSeen =>
      _prefs.getBool(_mirrorMessageSeenKey) ?? false;

  bool get newbiePackPurchased =>
      _prefs.getBool(_newbiePackPurchasedKey) ?? false;

  bool get newbiePackInstalled =>
      _prefs.getBool(_newbiePackInstalledKey) ?? false;

  Future<void> purchaseAndInstallNewbiePack() async {
    if (newbiePackInstalled) return;
    // The starter pack is free and is installed immediately after purchase.
    await _prefs.setBool(_newbiePackPurchasedKey, true);
    await _prefs.setBool(_newbiePackInstalledKey, true);
    notifyListeners();
  }

  Future<void> markMirrorMessageSeen() async {
    if (mirrorMessageSeen) return;
    await _prefs.setBool(_mirrorMessageSeenKey, true);
    notifyListeners();
  }

  KgeColorTheme get colorTheme {
    final saved = _prefs.getString(_themeKey);

    switch (saved) {
      case 'blue':
        return KgeColorTheme.blue;
      case 'green':
        return KgeColorTheme.green;
      case 'red':
        return KgeColorTheme.red;
      case 'purple':
      default:
        return KgeColorTheme.purple;
    }
  }

  Future<void> setColorTheme(KgeColorTheme theme) async {
    if (colorTheme == theme) return;

    await _prefs.setString(_themeKey, theme.id);
    notifyListeners();
  }

  Future<void> configureAccount({
    required String login,
    required String password,
  }) async {
    await _prefs.setString(_loginKey, login.trim());
    await _prefs.setString(_passwordKey, password);
    await _prefs.setBool(_accountConfiguredKey, true);
    notifyListeners();
  }

  Future<void> install() async {
    if (isInstalled) return;

    await _prefs.setBool(_installedKey, true);
    await _prefs.setBool(_locationTutorialPendingKey, true);
    notifyListeners();
  }

  Future<void> unlockShop() async {
    if (shopUnlocked) return;

    await _prefs.setBool(_shopUnlockedKey, true);
    notifyListeners();
  }

  Future<void> markShopNoticeSeen() async {
    if (shopNoticeSeen) return;

    await _prefs.setBool(_shopNoticeSeenKey, true);
    notifyListeners();
  }

  Future<void> markLocationTutorialSeen() async {
    if (!locationTutorialPending) return;

    await _prefs.setBool(_locationTutorialPendingKey, false);
    notifyListeners();
  }

  Future<void> unlockKgeNotes() async {
    if (kgeNotesUnlocked) return;
    await _prefs.setBool(_kgeNotesUnlockedKey, true);
    notifyListeners();
  }

  Future<void> markKgeNotesTutorialSeen() async {
    if (kgeNotesTutorialSeen) return;
    await _prefs.setBool(_kgeNotesTutorialSeenKey, true);
    notifyListeners();
  }

  Future<void> markKgeChatsChecked() async {
    if (kgeChatsChecked) return;
    await _prefs.setBool(_kgeChatsCheckedKey, true);
    notifyListeners();
  }

  Future<void> uninstall() async {
    await _prefs.remove(_installedKey);
    await _prefs.remove(_accountConfiguredKey);
    await _prefs.remove(_loginKey);
    await _prefs.remove(_passwordKey);
    await _prefs.remove(_shopUnlockedKey);
    await _prefs.remove(_shopNoticeSeenKey);
    await _prefs.remove(_locationTutorialPendingKey);
    await _prefs.remove(_kgeNotesUnlockedKey);
    await _prefs.remove(_kgeNotesTutorialSeenKey);
    await _prefs.remove(_kgeChatsCheckedKey);
    await _prefs.remove(_mirrorMessageSeenKey);
    await _prefs.remove(_newbiePackPurchasedKey);
    await _prefs.remove(_newbiePackInstalledKey);
    notifyListeners();
  }
}
