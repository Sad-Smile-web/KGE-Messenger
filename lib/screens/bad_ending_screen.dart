import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/app_localization.dart';
import '../widgets/l10n_text.dart';

/// Финальная сцена после отказа от KGE.
/// Тексты концовки локализуются выбранным языком интерфейса.
class BadEndingScreen extends StatefulWidget {
  final Future<void> Function() onRestart;

  const BadEndingScreen({super.key, required this.onRestart});

  @override
  State<BadEndingScreen> createState() => _BadEndingScreenState();
}

class _BadEndingScreenState extends State<BadEndingScreen> {
  static const List<String> _texts = [
    'Расширение удалилось... Я много думал: правильно ли я поступил? С одной стороны, я мог бы вылечить маму от смертельной болезни. С другой — теперь я могу проводить с ней больше времени, сколько бы ни было отведено ей судьбой...',
    'Прошло три месяца с тех пор, как расширение удалили из моего мессенджера. Я уже почти забыл о нём, но вчера в новостях увидел, что моего друга опознали как убитого... Моя мать умерла месяц назад. Мы многое успели сделать, но мне кажется, что могли бы сделать ещё больше...',
    'Наверное...',
    'Я всё сделал правильно...',
    'Ведь так?..',
  ];

  int _stage = 0;
  int _typedCharacters = 0;
  String _visibleText = '';
  bool _fadeOut = false;
  bool _showNext = false;
  bool _restartInProgress = false;
  Timer? _typingTimer;
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startTyping();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _advanceTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startTyping() {
    _typingTimer?.cancel();
    if (_stage >= _texts.length) return;

    final text = L10n.t(_texts[_stage]);
    var position = 0;
    setState(() {
      _typedCharacters = 0;
      _visibleText = '';
      _showNext = false;
      _fadeOut = false;
    });

    _typingTimer = Timer.periodic(const Duration(milliseconds: 52), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      position++;
      setState(() {
        _typedCharacters = position;
        _visibleText = text.substring(0, position > text.length ? text.length : position);
      });

      if (position >= text.length) {
        timer.cancel();
        _onTypingComplete();
      }
    });
  }

  void _onTypingComplete() {
    if (!mounted) return;
    if (_stage == 0 || _stage == 1) {
      setState(() => _showNext = true);
      return;
    }

    final delay = _stage == 1
        ? const Duration(milliseconds: 2400)
        : const Duration(milliseconds: 1650);
    _advanceTimer?.cancel();
    _advanceTimer = Timer(delay, () {
      if (!mounted) return;
      if (_stage == _texts.length - 1) {
        _transitionTo(_texts.length);
      } else {
        _transitionTo(_stage + 1);
      }
    });
  }

  Future<void> _continueStory() async {
    if ((_stage != 0 && _stage != 1) || !_showNext) return;
    _advanceTimer?.cancel();
    await _transitionTo(_stage + 1);
  }

  Future<void> _transitionTo(int nextStage) async {
    if (!mounted) return;
    _typingTimer?.cancel();
    setState(() {
      _fadeOut = true;
      _showNext = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 480));
    if (!mounted) return;

    setState(() {
      _stage = nextStage;
      _visibleText = '';
      _typedCharacters = 0;
      _fadeOut = false;
    });

    if (_stage < _texts.length) {
      _startTyping();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAchievement = _stage >= _texts.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: AnimatedOpacity(
          opacity: _fadeOut ? 0 : 1,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
          child: isAchievement ? _buildAchievement() : _buildStoryText(),
        ),
      ),
    );
  }

  Widget _buildStoryText() {
    final isLongText = _stage <= 1;
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Text(
                _visibleText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFE7E7E7),
                  fontSize: isLongText ? 19 : 24,
                  height: 1.65,
                  letterSpacing: 0.15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        if (_showNext)
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Center(
              child: SizedBox(
                width: 190,
                child: OutlinedButton(
                  onPressed: _continueStory,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE7E7E7),
                    side: const BorderSide(color: Color(0xFF777777)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const L10nText('Продолжить', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAchievement() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x333D9FFF),
                  blurRadius: 36,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Color(0x225F2D91),
                  blurRadius: 58,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 25, 24, 23),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF11141B),
                    Color(0xFF08090E),
                    Color(0xFF0B0B12),
                  ],
                ),
                border: Border.all(color: const Color(0xFF394A60), width: 1.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111E2A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF4BDCF3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x334BDCF3),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium_outlined,
                          color: Color(0xFF72E9F7),
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 13),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            L10nText(
                              'KGE  //  STORY ARCHIVE',
                              style: TextStyle(
                                color: Color(0xFF72E9F7),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 5),
                            L10nText(
                              'ДОСТИЖЕНИЕ ПОЛУЧЕНО',
                              style: TextStyle(
                                color: Color(0xFFB8C2D0),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF72E9F7),
                        size: 21,
                      ),
                    ],
                  ),
                  const SizedBox(height: 23),
                  Container(
                    height: 1,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x0072E9F7),
                          Color(0xFF72E9F7),
                          Color(0xFF9D72FF),
                          Color(0x009D72FF),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 23),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151522),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: const Color(0xFF5D477C)),
                    ),
                    child: const L10nText(
                      'КОНЦОВКА 1 ИЗ ???',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFC5A5FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const L10nText(
                    'Не самый лучший исход, но, наверное, самый правильный…',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFF0F3F8),
                      fontSize: 21,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 17),
                  const L10nText(
                    'Спасибо за игру!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF72E9F7),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _restartInProgress
                          ? null
                          : () async {
                              setState(() => _restartInProgress = true);
                              await widget.onRestart();
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF72E9F7),
                        foregroundColor: const Color(0xFF061016),
                        disabledBackgroundColor: const Color(0xFF34434B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      child: const L10nText('Начать с начала'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
