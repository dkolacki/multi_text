import 'package:flutter/material.dart';
import 'package:multi_text/src/multi_text_symbol.dart';

abstract class MultiTextTokenContext {
  TextStyle? get linkStyle;
  TextStyle? get linkActiveStyle;

  void onActivated(String symbol, String text, List<String> args);

  // Asks for a rebuild, after the look of a token has changed.
  void onChanged();
}

abstract class MultiTextTokenBase {
  const MultiTextTokenBase({
    required this.symbol,
  });

  final String symbol;

  MultiTextSymbol build(MultiTextTokenContext context);
}

class MultiTextToken extends MultiTextTokenBase {
  const MultiTextToken({
    required super.symbol,
    this.styleBuilder,
    this.spanBuilder,
  });

  final TextStyle Function(TextStyle style)? styleBuilder;
  final InlineSpan Function(
    String text,
    TextStyle style,
    List<String> args,
  )? spanBuilder;

  @override
  MultiTextSymbol build(MultiTextTokenContext context) {
    return MultiTextSymbol(
      symbol: symbol,
      spanBuilder: spanBuilder,
      styleBuilder: styleBuilder,
    );
  }
}

class MultiTextLinkToken extends MultiTextTokenBase {
  const MultiTextLinkToken({required super.symbol});

  @override
  MultiTextSymbol build(MultiTextTokenContext context) {
    return MultiTextLinkSymbol(symbol: symbol, context: context);
  }
}
