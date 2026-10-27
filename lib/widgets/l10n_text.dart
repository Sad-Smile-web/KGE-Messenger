import 'package:flutter/material.dart';

import '../services/app_localization.dart';
import '../services/language_store.dart';

class L10nText extends StatelessWidget {
  final String russian;
  final String? english;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;
  final TextDirection? textDirection;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final StrutStyle? strutStyle;
  final String? semanticsLabel;
  final TextScaler? textScaler;

  const L10nText(
    this.russian, {
    super.key,
    this.english,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.textDirection,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.strutStyle,
    this.semanticsLabel,
    this.textScaler,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LanguageStore.instance,
      builder: (context, _) {
        return Text(
          L10n.t(russian, english),
          style: style,
          textAlign: textAlign,
          overflow: overflow,
          maxLines: maxLines,
          softWrap: softWrap,
          textDirection: textDirection,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
          strutStyle: strutStyle,
          semanticsLabel: semanticsLabel,
          textScaler: textScaler,
        );
      },
    );
  }
}
