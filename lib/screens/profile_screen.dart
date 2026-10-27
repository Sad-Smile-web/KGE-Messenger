import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../services/profile_store.dart';
import '../services/language_store.dart';
import '../widgets/l10n_text.dart';
import '../widgets/language_picker.dart';
import '../services/app_localization.dart';


class ProfileScreen extends StatefulWidget {
  final ProfileStore profileStore;

  const ProfileScreen({
    super.key,
    required this.profileStore,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nicknameController =
  TextEditingController();

  late String _nickname;
  String? _avatarPath;

  bool _changingAvatar = false;
  bool _editingNickname = false;
  bool _savingNickname = false;

  @override
  void initState() {
    super.initState();

    _nickname = widget.profileStore.nickname;
    _avatarPath = widget.profileStore.avatarPath;

    _nicknameController.text = _nickname;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _changeAvatar() async {
    if (_changingAvatar) return;

    setState(() {
      _changingAvatar = true;
    });

    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );

      if (picked == null) {
        return;
      }

      final directory = await getApplicationDocumentsDirectory();

      final originalName = picked.name;
      final extensionIndex = originalName.lastIndexOf('.');

      final extension = extensionIndex >= 0
          ? originalName.substring(extensionIndex).toLowerCase()
          : '.jpg';

      final destination = File(
        '${directory.path}/profile_avatar$extension',
      );

      await picked.saveTo(destination.path);

      await widget.profileStore.saveProfile(
        nickname: _nickname,
        avatarPath: destination.path,
      );

      if (!mounted) return;

      setState(() {
        _avatarPath = destination.path;
      });
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Не удалось изменить фотографию.',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _changingAvatar = false;
      });
    }
  }

  void _startNicknameEditing() {
    _nicknameController.text = _nickname;

    setState(() {
      _editingNickname = true;
    });
  }

  void _cancelNicknameEditing() {
    _nicknameController.text = _nickname;

    FocusScope.of(context).unfocus();

    setState(() {
      _editingNickname = false;
    });
  }

  Future<void> _saveNickname() async {
    final value = _nicknameController.text.trim();

    if (value.isEmpty) {
      _showMessage(
        'Введите никнейм.',
      );
      return;
    }

    if (value.length < 2) {
      _showMessage(
        'Никнейм должен содержать минимум 2 символа.',
      );
      return;
    }

    if (value.length > 24) {
      _showMessage(
        'Никнейм должен содержать не более 24 символов.',
      );
      return;
    }

    if (_savingNickname) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _savingNickname = true;
    });

    try {
      await widget.profileStore.saveProfile(
        nickname: value,
        avatarPath: _avatarPath,
      );

      if (!mounted) return;

      setState(() {
        _nickname = value;
        _editingNickname = false;
        _savingNickname = false;
      });

      _showMessage(
        'Никнейм изменён.',
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _savingNickname = false;
      });

      _showMessage(
        'Не удалось изменить никнейм.',
      );
    }
  }

  void _showPasswordInfo() {
    _showMessage(
      'Пароль используется только при создании профиля.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: L10nText(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        _avatarPath != null && _avatarPath!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        title: const L10nText('Профиль',
          style: TextStyle(
            color: Color(0xFF18253A),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          24,
          20,
          32,
        ),
        children: [
          Center(
            child: GestureDetector(
              onTap: _changeAvatar,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE7EDF8),
                      border: Border.all(
                        color: Colors.white,
                        width: 5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A5474A8),
                          blurRadius: 18,
                          offset: Offset(0, 7),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: hasAvatar
                          ? Image.file(
                        File(_avatarPath!),
                        fit: BoxFit.cover,
                      )
                          : const Icon(
                        Icons.person_outline_rounded,
                        size: 64,
                        color: Color(0xFF9BAACA),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: 2,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF78A9FF),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: _changingAvatar
                          ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                          : const Icon(
                        Icons.edit_rounded,
                        size: 19,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          if (!_editingNickname)
            Center(
              child: L10nText(
                _nickname.isEmpty
                    ? 'Без никнейма'
                    : _nickname,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF18253A),
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

          if (!_editingNickname) ...[
            const SizedBox(height: 6),
            const Center(
              child: L10nText('Профиль пользователя',
                style: TextStyle(
                  color: Color(0xFF8A97AA),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          if (_editingNickname) ...[
            const SizedBox(height: 12),

            TextField(
              controller: _nicknameController,
              autofocus: true,
              maxLength: 24,
              enabled: !_savingNickname,
              textCapitalization: TextCapitalization.none,
              decoration: InputDecoration(
                hintText: L10n.t('Никнейм'),
                filled: true,
                fillColor: Colors.white,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color(0xFFD7E0EE),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color(0xFFD7E0EE),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color(0xFF78A9FF),
                    width: 1.5,
                  ),
                ),
              ),
              onSubmitted: (_) {
                _saveNickname();
              },
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _savingNickname
                        ? null
                        : _cancelNicknameEditing,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        0,
                        50,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const L10nText('Отмена',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _savingNickname
                        ? null
                        : _saveNickname,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(
                        0,
                        50,
                      ),
                      backgroundColor:
                      const Color(0xFF78A9FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _savingNickname
                        ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const L10nText('Сохранить',
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 30),

          _ProfileAction(
            icon: Icons.photo_camera_outlined,
            title: 'Изменить фотографию',
            subtitle: 'Выбрать фото из галереи',
            onTap: _changeAvatar,
          ),

          const SizedBox(height: 12),

          _ProfileAction(
            icon: Icons.edit_outlined,
            title: 'Изменить никнейм',
            subtitle: _nickname,
            onTap: _editingNickname
                ? _cancelNicknameEditing
                : _startNicknameEditing,
          ),

          const SizedBox(height: 12),

          _ProfileAction(
            icon: Icons.lock_outline_rounded,
            title: 'Пароль',
            subtitle: 'Скрыт',
            onTap: _showPasswordInfo,
          ),

          const SizedBox(height: 12),

          _ProfileAction(
            icon: Icons.language_rounded,
            title: 'Язык',
            subtitle: LanguageStore.instance.name,
            onTap: () async {
              await showLanguagePicker(context);
              if (!mounted) return;
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF5689E8),
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    L10nText(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF18253A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    L10nText(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8A97AA),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9AA7B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
