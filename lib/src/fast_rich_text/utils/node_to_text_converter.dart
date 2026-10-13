import 'package:flutter/material.dart';

import '../models/parsed_node.dart';
import '../models/symbol_params.dart';
import 'parser.dart';
import 'string_to_node_parser.dart';

class NodeToTextConverter {
  final List<SymbolParams> symbols;

  /// the original text
  final String text;

  /// default text style
  final TextStyle defaultTextStyle;

  final Parser _parser;

  final List<String> _symbolChars;

  NodeToTextConverter({
    required this.symbols,
    required this.defaultTextStyle,
    required this.text,
  })  : _symbolChars = symbols.map((e) => e.symbolCharacter).toList(),
        _parser = Parser(
          text: text,
          symbols: symbols.map((e) => e.symbolCharacter).toList(),
          stringToNodeParser: StringToNodeParser.it,
        );

  InlineSpan convert() {
    // generate the [ParsedNode] first
    final parsedNode = _parser.parse();
    return _textSpanFromNode(parsedNode);
  }

  // mutually recursive with [_buildTextSpanChildren()]
  InlineSpan _textSpanFromNode(ParsedNode node) {
    if (node.children.isEmpty) {
      final string = _getCleanedString(node.startIndex, node.endIndex + 1);
      final symbolParams = _getSymbolParamsOf(node.symbol);

      if (symbolParams?.builder != null) {
        return symbolParams!.builder!(string, defaultTextStyle);
      } else {
        return TextSpan(
          text: string,
          style:
              symbolParams?.style?.call(defaultTextStyle) ?? defaultTextStyle,
        );
      }
    } else {
      return TextSpan(
        text: '',
        children: _buildTextSpanChildren(
          start: node.startIndex,
          end: node.endIndex,
          nodeChildren: node.children,
        ),
        style: symbols
                .firstWhere((element) => element.symbolCharacter == node.symbol)
                .style
                ?.call(defaultTextStyle) ??
            defaultTextStyle,
      );
    }
  }

  String _getCleanedString(int startIndex, int endIndex) {
    final buffer = StringBuffer();

    for (int i = startIndex; i < endIndex; i++) {
      final char = text[i];

      if (char == '\\' && i + 1 < endIndex) {
        buffer.write(text[++i]);
      } else if (!_symbolChars.contains(char)) {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }

  List<InlineSpan> _buildTextSpanChildren({
    required int start,
    required int end,
    required List<ParsedNode> nodeChildren,
  }) {
    List<InlineSpan> children = [];

    ParsedNode lastNode = const ParsedNode(startIndex: 0, endIndex: 0);

    String string = _getCleanedString(start, nodeChildren.first.startIndex);

    children.add(
      TextSpan(
        text: string,
        style: _defaultSymbol?.style?.call(defaultTextStyle),
      ),
    );

    for (ParsedNode child in nodeChildren) {
      if (child == nodeChildren.first) {
        children.add(_textSpanFromNode(child));
        lastNode = child;
      } else {
        String string =
            _getCleanedString(lastNode.endIndex, child.startIndex + 1);

        children.add(
          TextSpan(
            text: string,
            style: _defaultSymbol?.style?.call(defaultTextStyle),
          ),
        );

        children.add(_textSpanFromNode(child));

        lastNode = child;
      }
    }

    string = _getCleanedString(lastNode.endIndex, end + 1);

    children.add(
      TextSpan(
        text: string,
        style: _defaultSymbol?.style?.call(defaultTextStyle),
      ),
    );
    // }

    return children;
  }

  SymbolParams? get _defaultSymbol => _getSymbolParamsOf('');

  SymbolParams? _getSymbolParamsOf(String symbolChar) {
    try {
      return symbols.firstWhere(
        (element) => element.symbolCharacter == symbolChar,
      );
    } catch (e) {
      return null;
    }
  }
}
