import 'package:flutter/material.dart';
import 'package:multi_text/src/multi_text_scope.dart';
import 'package:multi_text/src/multi_text_token.dart';

class MultiTextConfig {
  MultiTextConfig({
    required this.tokens,
    required this.defaultStyle,
    required this.textScaleFactor,
    this.linkStyle,
    this.linkActiveStyle,
  });

  final List<MultiTextTokenBase> tokens;
  final TextStyle defaultStyle;
  final double textScaleFactor;
  final TextStyle? linkStyle;
  final TextStyle? linkActiveStyle;

  MultiTextConfig copyWith({
    List<MultiTextTokenBase>? tokens,
    TextStyle? defaultStyle,
    double? textScaleFactor,
    TextStyle? linkStyle,
    TextStyle? linkActiveStyle,
  }) {
    return MultiTextConfig(
      tokens: tokens ?? this.tokens,
      defaultStyle: defaultStyle ?? this.defaultStyle,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      linkStyle: linkStyle ?? this.linkStyle,
      linkActiveStyle: linkActiveStyle ?? this.linkActiveStyle,
    );
  }

  static MultiTextConfig of(BuildContext context) {
    final MultiTextScope? scope =
        context.dependOnInheritedWidgetOfExactType<MultiTextScope>();

    return scope?.config ??
        MultiTextConfig(
          tokens: [],
          defaultStyle: const TextStyle(),
          textScaleFactor: MediaQuery.of(context).textScaleFactor,
        );
  }
}
