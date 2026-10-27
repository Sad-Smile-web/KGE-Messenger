import 'package:flutter/material.dart';

import '../../services/kge_store.dart';
import '../../widgets/kge/kge_panel.dart';
import '../../widgets/l10n_text.dart';
import '../../services/app_localization.dart';
import '../../services/language_store.dart';


class KgeSetupScreen extends StatefulWidget {
  final KgeStore kgeStore;
  final Future<void> Function() onCompleted;
  final VoidCallback onCancel;

  const KgeSetupScreen({
    super.key,
    required this.kgeStore,
    required this.onCompleted,
    required this.onCancel,
  });

  @override
  State<KgeSetupScreen> createState() => _KgeSetupScreenState();
}

class _KgeSetupScreenState extends State<KgeSetupScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _loginFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _saving = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _loginFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;

    FocusScope.of(context).unfocus();

    final login = _loginController.text.trim();
    final password = _passwordController.text;

    if (login.isEmpty) {
      _showMessage('Введите логин.');
      _loginFocus.requestFocus();
      return;
    }

    if (login.length < 2) {
      _showMessage('Логин должен содержать минимум 2 символа.');
      _loginFocus.requestFocus();
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
      await widget.kgeStore.configureAccount(
        login: login,
        password: password,
      );
      await widget.onCompleted();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage('Не удалось завершить настройку KGE.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: L10nText(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([KgeStore.instance, LanguageStore.instance]),
      builder: (context, _) {
        final theme = KgeStore.instance.colorTheme;

        return Material(
          color: const Color(0xD4020107),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: KgePanel(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.primary.withOpacity(0.10),
                                border: Border.all(
                                  color: theme.primary.withOpacity(0.75),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primary.withOpacity(0.25),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: L10nText('K',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  L10nText('ПЕРВИЧНАЯ ИНИЦИАЛИЗАЦИЯ',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  L10nText('Настройка доступа к KGE',
                                    style: TextStyle(
                                      color: const Color(0xFFB9A9C5),
                                      fontSize: 11,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _saving ? null : widget.onCancel,
                              tooltip: L10n.t('Выйти'),
                              icon: Icon(
                                Icons.close_rounded,
                                color: theme.bodyText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        L10nText('Первый запуск KGE. Введите логин и создайте пароль.',
                          style: TextStyle(
                            color: const Color(0xFFE7DDF0),
                            fontSize: 13,
                            height: 1.45,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _KgeField(
                          controller: _loginController,
                          focusNode: _loginFocus,
                          label: 'Логин',
                          icon: Icons.person_outline_rounded,
                          enabled: !_saving,
                          obscureText: false,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _passwordFocus.requestFocus(),
                        ),
                        const SizedBox(height: 10),
                        _KgeField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          label: 'Создать пароль',
                          icon: Icons.lock_outline_rounded,
                          enabled: !_saving,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onToggleVisibility: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          onSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 16),
                        _KgeSetupButton(
                          loading: _saving,
                          enabled: !_saving,
                          onTap: _submit,
                        ),
                        const SizedBox(height: 12),
                        L10nText('Данные сохраняются только внутри приложения и используются как элемент интерфейса KGE.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFFA99AB6),
                            fontSize: 10,
                            height: 1.4,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _KgeField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final IconData icon;
  final bool enabled;
  final bool obscureText;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onToggleVisibility;

  const _KgeField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.icon,
    required this.enabled,
    required this.obscureText,
    required this.textInputAction,
    this.onSubmitted,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KgeStore.instance.colorTheme;

    return Material(
      color: Colors.transparent,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        obscureText: obscureText,
        textInputAction: textInputAction,
        cursorColor: theme.primary,
        cursorWidth: 2,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          decoration: TextDecoration.none,
        ),
        textCapitalization: label == 'Логин'
            ? TextCapitalization.none
            : TextCapitalization.sentences,
        autocorrect: false,
        enableSuggestions: label == 'Логин',
        selectionControls: materialTextSelectionControls,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xF0120C1E),
          labelText: L10n.t(label),
          labelStyle: const TextStyle(
            color: Color(0xFFCFC0DD),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
          floatingLabelStyle: TextStyle(
            color: theme.primary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.none,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.primary.withOpacity(0.42),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.primary.withOpacity(0.42),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.primary.withOpacity(0.95),
              width: 1.4,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.primary.withOpacity(0.20),
              width: 1,
            ),
          ),
          prefixIcon: Icon(
            icon,
            color: theme.primary,
            size: 21,
          ),
          suffixIcon: onToggleVisibility == null
              ? null
              : IconButton(
                  onPressed: enabled ? onToggleVisibility : null,
                  tooltip: L10n.t(obscureText ? 'Показать пароль' : 'Скрыть пароль'),
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class _KgeSetupButton extends StatelessWidget {
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  const _KgeSetupButton({
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KgeStore.instance.colorTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: theme.primary.withOpacity(0.13),
            border: Border.all(
              color: theme.primary.withOpacity(0.72),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primary.withOpacity(0.16),
                blurRadius: 18,
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: loading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : const L10nText('Продолжить',
                      key: ValueKey('label'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
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
