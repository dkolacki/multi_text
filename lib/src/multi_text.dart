import 'package:flutter/material.dart';
import 'package:multi_text/src/fast_rich_text/views/fast_rich_text.dart';
import 'package:multi_text/src/multi_text_config.dart';
import 'package:multi_text/src/multi_text_token.dart';

class MultiText extends StatelessWidget {
  const MultiText(
    this.text, {
    this.style,
    this.tokens,
    this.textAlign = TextAlign.start,
    this.softWrap = true,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textHeightBehavior,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textDirection,
    Key? key,
  }) : super(key: key);

  final String text;
  final TextStyle? style;
  final List<MultiTextToken>? tokens;
  final TextAlign textAlign;
  final bool softWrap;
  final TextOverflow overflow;
  final int? maxLines;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final double? textScaleFactor;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    final config = MultiTextConfig.of(context).copyWith(
      tokens: tokens,
      defaultStyle: style,
      textScaleFactor: textScaleFactor,
    );

    return FastRichText(
      text: text,
      textStyle: config.defaultStyle,
      textAlign: textAlign,
      softWrap: softWrap,
      maxLines: maxLines,
      locale: locale,
      strutStyle: strutStyle,
      textHeightBehavior: textHeightBehavior,
      overflow: overflow,
      textScaleFactor: config.textScaleFactor,
      textWidthBasis: textWidthBasis,
      textDirection: textDirection,
      useCustomParseSymbolsOnly: true,
      customSymbols: config.tokens,
    );
  }
}
