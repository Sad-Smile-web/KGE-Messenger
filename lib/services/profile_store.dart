import 'package:shared_preferences/shared_preferences.dart';

class ProfileStore {
  static const _registeredKey = 'profile_registered';
  static const _nicknameKey = 'profile_nickname';
  static const _firstNameKey = 'profile_first_name';
  static const _lastNameKey = 'profile_last_name';
  static const _passwordKey = 'profile_password';
  static const _avatarPathKey = 'profile_avatar_path';
  static const _reputationKey = 'profile_reputation';
  static const _welcomeShownKey = 'welcome_notification_shown';

  static ProfileStore? _instance;

  final SharedPreferences _prefs;

  ProfileStore._(this._prefs);

  static ProfileStore get instance {
    final store = _instance;
    if (store == null) {
      throw StateError(
        'ProfileStore.instance is not initialized. '
        'Call ProfileStore.load() before runApp().',
      );
    }
    return store;
  }

  static Future<ProfileStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final store = ProfileStore._(prefs);
    _instance = store;
    return store;
  }

  bool get isRegistered => _prefs.getBool(_registeredKey) ?? false;

  String get firstName {
    final value = _prefs.getString(_firstNameKey);
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }

    final legacy = _prefs.getString(_nicknameKey) ?? '';
    final parts = legacy.trim().split(RegExp(r'\s+'));
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first;
    }

    return '';
  }

  String get lastName {
    final value = _prefs.getString(_lastNameKey);
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }

    final legacy = _prefs.getString(_nicknameKey) ?? '';
    final parts = legacy.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return parts.sublist(1).join(' ');
    }

    return '';
  }

  String get fullName {
    final first = firstName;
    final last = lastName;

    if (first.isEmpty) return last;
    if (last.isEmpty) return first;
    return '$first $last';
  }

  // Старый getter сохраняем для существующих экранов.
  String get nickname => fullName;

  String get password => _prefs.getString(_passwordKey) ?? '';

  int get reputation => _prefs.getInt(_reputationKey) ?? 0;

  bool get welcomeNotificationShown =>
      _prefs.getBool(_welcomeShownKey) ?? false;

  Future<void> markWelcomeNotificationShown() async {
    await _prefs.setBool(_welcomeShownKey, true);
  }

  String? get avatarPath {
    final value = _prefs.getString(_avatarPathKey);
    return value == null || value.isEmpty ? null : value;
  }

  Future<void> saveProfile({
    String? nickname,
    String? firstName,
    String? lastName,
    String? password,
    String? avatarPath,
  }) async {
    var resolvedFirstName = firstName?.trim() ?? '';
    var resolvedLastName = lastName?.trim() ?? '';

    // Поддержка старого формата профиля с одним никнеймом.
    if (resolvedFirstName.isEmpty &&
        resolvedLastName.isEmpty &&
        nickname != null &&
        nickname.trim().isNotEmpty) {
      final parts = nickname.trim().split(RegExp(r'\s+'));
      resolvedFirstName = parts.first;
      if (parts.length > 1) {
        resolvedLastName = parts.sublist(1).join(' ');
      }
    }

    if (resolvedFirstName.isNotEmpty) {
      await _prefs.setString(_firstNameKey, resolvedFirstName);
    } else {
      await _prefs.remove(_firstNameKey);
    }

    if (resolvedLastName.isNotEmpty) {
      await _prefs.setString(_lastNameKey, resolvedLastName);
    } else {
      await _prefs.remove(_lastNameKey);
    }

    final combinedName = [
      resolvedFirstName,
      resolvedLastName,
    ].where((value) => value.isNotEmpty).join(' ');

    if (combinedName.isNotEmpty) {
      await _prefs.setString(_nicknameKey, combinedName);
    } else {
      await _prefs.remove(_nicknameKey);
    }

    if (password != null && password.isNotEmpty) {
      await _prefs.setString(_passwordKey, password);
    }

    if (avatarPath == null || avatarPath.isEmpty) {
      await _prefs.remove(_avatarPathKey);
    } else {
      await _prefs.setString(_avatarPathKey, avatarPath);
    }

    // Репутация у нового профиля начинается с нуля.
    if (!_prefs.containsKey(_reputationKey)) {
      await _prefs.setInt(_reputationKey, 0);
    }

    await _prefs.setBool(_registeredKey, true);
  }

  Future<void> reset() async {
    await _prefs.remove(_registeredKey);
    await _prefs.remove(_nicknameKey);
    await _prefs.remove(_firstNameKey);
    await _prefs.remove(_lastNameKey);
    await _prefs.remove(_passwordKey);
    await _prefs.remove(_avatarPathKey);
    await _prefs.remove(_reputationKey);
    await _prefs.remove(_welcomeShownKey);
  }
}
