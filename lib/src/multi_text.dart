import 'package:flutter/material.dart';
import 'package:multi_text/src/fast_rich_text/views/fast_rich_text.dart';
import 'package:multi_text/src/multi_text_config.dart';
import 'package:multi_text/src/multi_text_symbol.dart';
import 'package:multi_text/src/multi_text_token.dart';

class MultiText extends StatefulWidget {
  const MultiText(
    this.text, {
    this.style,
    this.linkStyle,
    this.linkActiveStyle,
    this.tokens,
    this.textAlign,
    this.softWrap = true,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textHeightBehavior,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textDirection,
    this.onActivated,
    Key? key,
  }) : super(key: key);

  final String text;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final TextStyle? linkActiveStyle;

  final List<MultiTextTokenBase>? tokens;
  final TextAlign? textAlign;
  final bool softWrap;
  final TextOverflow overflow;
  final int? maxLines;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final double? textScaleFactor;
  final TextDirection? textDirection;

  final Function(String symbol, String text, List<String> args)? onActivated;

  // anything that could be a symbol, the backslash included
  static final _escapable = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);

  /// Escapes [text], so that nothing in it is taken as a token.
  static String escape(String text) {
    return text.replaceAllMapped(_escapable, (match) => '\\${match[0]}');
  }

  @override
  State<MultiText> createState() => _MultiTextState();
}

class _MultiTextState extends State<MultiText>
    implements MultiTextTokenContext {
  bool initialized = false;
  List<MultiTextSymbol> tokens = [];
  late MultiTextConfig config;

  @override
  TextStyle? get linkStyle {
    return config.linkStyle?.merge(widget.linkStyle) ?? widget.linkStyle;
  }

  @override
  TextStyle? get linkActiveStyle {
    return config.linkActiveStyle?.merge(widget.linkActiveStyle) ??
        widget.linkActiveStyle;
  }

  @override
  void onActivated(String symbol, String text, List<String> args) {
    widget.onActivated?.call(symbol, text, args);
  }

  @override
  void onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    config = MultiTextConfig.of(context);

    if (!initialized) {
      // tokens are not expected to change at runtime
      tokens = (widget.tokens ?? config.tokens)
          .map((e) => e.build(this))
          .toList();

      initialized = true;
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    for (var e in tokens) {
      e.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);

    return FastRichText(
      text: widget.text,
      textStyle: config.defaultStyle.merge(widget.style),
      textAlign: widget.textAlign ?? defaultStyle.textAlign ?? TextAlign.start,
      softWrap: widget.softWrap,
      maxLines: widget.maxLines,
      locale: widget.locale,
      strutStyle: widget.strutStyle,
      textHeightBehavior: widget.textHeightBehavior,
      overflow: widget.overflow,
      textScaleFactor: widget.textScaleFactor ?? config.textScaleFactor,
      textWidthBasis: widget.textWidthBasis,
      textDirection: widget.textDirection,
      useCustomParseSymbolsOnly: true,
      customSymbols: tokens,
    );
  }
}
