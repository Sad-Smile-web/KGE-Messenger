import 'package:flutter/material.dart';
import '../services/app_localization.dart';

class MessageInput extends StatefulWidget {
  final ValueChanged<String> onSend;
  final bool enabled;

  const MessageInput({
    super.key,
    required this.onSend,
    this.enabled = false,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool get _hasText =>
      widget.enabled && _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _send() {
    if (!widget.enabled) return;

    final value = _controller.text.trim();
    if (value.isEmpty) return;

    widget.onSend(value);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputColor = widget.enabled
        ? Colors.white
        : const Color(0xFFF1F3F6);

    final hintColor = widget.enabled
        ? const Color(0xFF8D98A8)
        : const Color(0xFFABB4C0);

    final sendColor = _hasText
        ? const Color(0xFF1976F3)
        : const Color(0xFFE1E6ED);

    final sendIconColor = _hasText
        ? Colors.white
        : const Color(0xFFA6AFBA);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: widget.enabled ? () {} : null,
              icon: const Icon(Icons.attach_file_rounded),
              color: widget.enabled
                  ? const Color(0xFF677488)
                  : const Color(0xFFB5BDC8),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: L10n.t('Сообщение'),
                  hintStyle: TextStyle(color: hintColor),
                  filled: true,
                  fillColor: inputColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 6),
            Material(
              color: sendColor,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _hasText ? _send : null,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.send_rounded,
                    color: sendIconColor,
                    size: 21,
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
