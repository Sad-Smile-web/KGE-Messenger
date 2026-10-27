import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../services/profile_store.dart';
import '../services/language_store.dart';
import '../widgets/l10n_text.dart';
import '../widgets/language_picker.dart';
import '../services/app_localization.dart';


class RegistrationScreen extends StatefulWidget {
  final ProfileStore profileStore;
  final VoidCallback onCompleted;

  const RegistrationScreen({
    super.key,
    required this.profileStore,
    required this.onCompleted,
  });

  @override
  State<RegistrationScreen> createState() =>
      _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _firstNameController =
      TextEditingController();
  final TextEditingController _lastNameController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final ImagePicker _imagePicker = ImagePicker();

  String? _avatarPath;
  bool _obscurePassword = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _firstNameController.text = widget.profileStore.firstName;
    _lastNameController.text = widget.profileStore.lastName;
    _avatarPath = widget.profileStore.avatarPath;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    if (_saving) return;

    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );

      if (picked == null || !mounted) return;

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

      if (!mounted) return;

      setState(() {
        _avatarPath = destination.path;
      });
    } catch (_) {
      if (!mounted) return;
      _showMessage('Не удалось выбрать фотографию.');
    }
  }

  Future<void> _createProfile() async {
    if (_saving) return;

    FocusScope.of(context).unfocus();

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final password = _passwordController.text;

    if (firstName.isEmpty) {
      _showMessage('Введите имя.');
      _firstNameFocus.requestFocus();
      return;
    }

    if (firstName.length < 2 || firstName.length > 24) {
      _showMessage('Имя должно содержать от 2 до 24 символов.');
      _firstNameFocus.requestFocus();
      return;
    }

    if (lastName.isEmpty) {
      _showMessage('Введите фамилию.');
      _lastNameFocus.requestFocus();
      return;
    }

    if (lastName.length < 2 || lastName.length > 32) {
      _showMessage('Фамилия должна содержать от 2 до 32 символов.');
      _lastNameFocus.requestFocus();
      return;
    }

    if (password.isEmpty) {
      _showMessage('Создайте пароль.');
      _passwordFocus.requestFocus();
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await widget.profileStore.saveProfile(
        firstName: firstName,
        lastName: lastName,
        password: password,
        avatarPath: _avatarPath,
      );

      if (!mounted) return;
      widget.onCompleted();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage('Не удалось создать профиль.');
    }
  }

  Future<void> _chooseLanguage() async {
    await showLanguagePicker(context);

    if (!mounted) return;
    setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: L10nText(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FD),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: _RegistrationBackground(),
            ),
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 24, 20, keyboardOpen ? 36 : 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 470),
                    child: _RegistrationCard(
                      firstNameController: _firstNameController,
                      lastNameController: _lastNameController,
                      passwordController: _passwordController,
                      firstNameFocus: _firstNameFocus,
                      lastNameFocus: _lastNameFocus,
                      passwordFocus: _passwordFocus,
                      avatarPath: _avatarPath,
                      saving: _saving,
                      obscurePassword: _obscurePassword,
                      onPickAvatar: _pickAvatar,
                      onTogglePassword: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      onCreate: _createProfile,
                      selectedLanguage: LanguageStore.instance.code,
                      onChooseLanguage: _chooseLanguage,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RegistrationBackground extends StatelessWidget {
  const _RegistrationBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFF),
            Color(0xFFEAF2FF),
            Color(0xFFF7F9FF),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _GlowCircle(
              size: 260,
              color: Color(0x5578A9FF),
            ),
          ),
          Positioned(
            left: -110,
            bottom: -120,
            child: _GlowCircle(
              size: 320,
              color: Color(0x3D9BBEFF),
            ),
          ),
          Positioned(
            top: 120,
            left: -80,
            child: _GlowCircle(
              size: 150,
              color: Color(0x2678A9FF),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.28,
            spreadRadius: size * 0.04,
          ),
        ],
      ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController passwordController;
  final FocusNode firstNameFocus;
  final FocusNode lastNameFocus;
  final FocusNode passwordFocus;
  final String? avatarPath;
  final bool saving;
  final bool obscurePassword;
  final VoidCallback onPickAvatar;
  final VoidCallback onTogglePassword;
  final VoidCallback onCreate;
  final String selectedLanguage;
  final VoidCallback onChooseLanguage;

  const _RegistrationCard({
    required this.firstNameController,
    required this.lastNameController,
    required this.passwordController,
    required this.firstNameFocus,
    required this.lastNameFocus,
    required this.passwordFocus,
    required this.avatarPath,
    required this.saving,
    required this.obscurePassword,
    required this.onPickAvatar,
    required this.onTogglePassword,
    required this.onCreate,
    required this.selectedLanguage,
    required this.onChooseLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x257A96BF),
            blurRadius: 35,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: L10nText('Связь',
                  style: TextStyle(
                    color: Color(0xFF152238),
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              _LanguageButton(
                selectedLanguage: selectedLanguage,
                onTap: onChooseLanguage,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const L10nText('Создайте свой профиль',
            style: TextStyle(
              color: Color(0xFF73839A),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 22),
          _AvatarPicker(
            avatarPath: avatarPath,
            enabled: !saving,
            onTap: onPickAvatar,
          ),
          const SizedBox(height: 8),
          const L10nText('Фотография профиля',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8B99AD),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 24),
          _FieldLabel('Имя'),
          const SizedBox(height: 7),
          _RegistrationField(
            controller: firstNameController,
            focusNode: firstNameFocus,
            hint: 'Например, Алексей',
            icon: Icons.person_outline_rounded,
            enabled: !saving,
            capitalization: TextCapitalization.words,
            action: TextInputAction.next,
            onSubmitted: (_) => lastNameFocus.requestFocus(),
          ),
          const SizedBox(height: 15),
          _FieldLabel('Фамилия'),
          const SizedBox(height: 7),
          _RegistrationField(
            controller: lastNameController,
            focusNode: lastNameFocus,
            hint: 'Например, Арсенович',
            icon: Icons.badge_outlined,
            enabled: !saving,
            capitalization: TextCapitalization.words,
            action: TextInputAction.next,
            onSubmitted: (_) => passwordFocus.requestFocus(),
          ),
          const SizedBox(height: 15),
          _FieldLabel('Пароль'),
          const SizedBox(height: 7),
          _RegistrationField(
            controller: passwordController,
            focusNode: passwordFocus,
            hint: 'Создайте пароль',
            icon: Icons.lock_outline_rounded,
            enabled: !saving,
            obscureText: obscurePassword,
            action: TextInputAction.done,
            onTogglePassword: onTogglePassword,
            onSubmitted: (_) => onCreate(),
          ),
          const SizedBox(height: 20),
          _CreateButton(
            loading: saving,
            enabled: !saving,
            onTap: onCreate,
          ),
          const SizedBox(height: 11),
          const L10nText('Пароль используется для локального профиля приложения.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9BA8BA),
              fontSize: 10,
              height: 1.35,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String selectedLanguage;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.selectedLanguage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F6FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFBFD6F7),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1478A9FF),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.language_rounded,
                color: Color(0xFF4A88EB),
                size: 18,
              ),
              const SizedBox(width: 6),
              const L10nText('Язык',
                english: 'Language',
                style: TextStyle(
                  color: Color(0xFF2D70D8),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(width: 6),
              L10nText('|' ,
                style: TextStyle(
                  color: Color(0xFFB6C8E2),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                selectedLanguage.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF6F8FBE),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(width: 3),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF6D8EBE),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFF0F6FF)
                : const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xFF9CBFF2)
                  : const Color(0xFFE2E9F2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1A2940),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? const Color(0xFF4A88EB)
                      : Colors.white,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF4A88EB)
                        : const Color(0xFFC7D3E3),
                    width: 1.4,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 15,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return L10nText(
      text,
      style: const TextStyle(
        color: Color(0xFF3B4B62),
        fontSize: 12,
        fontWeight: FontWeight.w800,
        decoration: TextDecoration.none,
      ),
    );
  }
}

class _RegistrationField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final bool enabled;
  final bool obscureText;
  final TextCapitalization capitalization;
  final TextInputAction action;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTogglePassword;

  const _RegistrationField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    required this.enabled,
    this.obscureText = false,
    this.capitalization = TextCapitalization.none,
    required this.action,
    this.onSubmitted,
    this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      textCapitalization: capitalization,
      textInputAction: action,
      style: const TextStyle(
        color: Color(0xFF17243A),
        fontSize: 15,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.none,
      ),
      cursorColor: const Color(0xFF4A88EB),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF6F9FE),
        hintText: L10n.t(hint),
        hintStyle: const TextStyle(
          color: Color(0xFFA2AEBD),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF6E95D2),
          size: 20,
        ),
        suffixIcon: onTogglePassword == null
            ? null
            : IconButton(
                onPressed: enabled ? onTogglePassword : null,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF8190A7),
                  size: 20,
                ),
              ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFDCE5F1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFDCE5F1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF7AA8F5),
            width: 1.3,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE6EBF2),
          ),
        ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  final String? avatarPath;
  final bool enabled;
  final VoidCallback onTap;

  const _AvatarPicker({
    required this.avatarPath,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        avatarPath != null && avatarPath!.isNotEmpty;

    return Center(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 118,
              height: 118,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFFDCE8FA),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1878A9FF),
                    blurRadius: 22,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: hasAvatar
                    ? Image.file(
                        File(avatarPath!),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: const Color(0xFFEEF4FD),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF86A2CC),
                          size: 44,
                        ),
                      ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4A88EB),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33709EEA),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  const _CreateButton({
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF78A9FF),
                Color(0xFF5A91EE),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3578A9FF),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: loading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : const L10nText('Создать профиль',
                      key: ValueKey('label'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.1,
                        decoration: TextDecoration.none,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
