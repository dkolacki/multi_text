import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:multi_text/src/fast_rich_text/models/symbol_params.dart';
import 'package:multi_text/src/multi_text_token.dart';
import 'package:multi_text/src/multi_text_value.dart';

class MultiTextSymbol implements SymbolParams {
  MultiTextSymbol({
    required String symbol,
    InlineSpan Function(
      String text,
      TextStyle style,
      List<String> args,
    )? spanBuilder,
    TextStyle Function(TextStyle style)? styleBuilder,
  }) {
    symbolCharacter = symbol;
    style = styleBuilder;
    builder = (spanBuilder != null)
        ? (text, style) {
            final value = MultiTextValue(text);
            return spanBuilder(value.text, style, value.args);
          }
        : null;
  }

  @override
  late final String symbolCharacter;
  @override
  late final TextStyle Function(TextStyle source)? style;
  @override
  late final InlineSpan Function(String text, TextStyle style)? builder;

  void dispose() {}

  @override
  List<Object> get props => [symbolCharacter];

  @override
  bool? get stringify => true;
}

class MultiTextLinkSymbol implements MultiTextSymbol {
  MultiTextLinkSymbol({
    required String symbol,
    required MultiTextTokenContext context,
  }) : _context = context {
    symbolCharacter = symbol;
    style = null;

    builder = (source, style) {
      return TextSpan(
        text: MultiTextValue(source).text,
        style: _styleOf(style, isActive: _press.source == source),
        recognizer: _recognizerOf(source),
      );
    };
  }

  static const _pressedHold = Duration(milliseconds: 120);
  static const _dimmedOpacity = .5;

  final MultiTextTokenContext _context;
  final Map<String, TapGestureRecognizer> _recognizers = {};

  final _press = _LinkPress();

  TextStyle _styleOf(TextStyle textStyle, {required bool isActive}) {
    final linkStyle = textStyle.merge(_context.linkStyle);
    if (!isActive) return linkStyle;

    final activeStyle = _context.linkActiveStyle;
    if (activeStyle != null) return linkStyle.merge(activeStyle);

    return linkStyle.copyWith(
      color: linkStyle.color?.withValues(alpha: _dimmedOpacity),
    );
  }

  TapGestureRecognizer _recognizerOf(String source) {
    return _recognizers.putIfAbsent(source, () {
      final value = MultiTextValue(source);

      return _LinkTapGestureRecognizer(
        onPointerDown: () {
          _press.releaseTimer?.cancel();
          _setPressed(source);
        },
        onRejected: _release,
      )
        ..onTapUp = (_) {
          _press.releaseTimer?.cancel();
          _press.releaseTimer = Timer(_pressedHold, () => _setPressed(null));
        }
        ..onTapCancel = _release
        ..onTap = () {
          _context.onActivated(symbolCharacter, value.text, value.args);
        };
    });
  }

  void _release() {
    _press.releaseTimer?.cancel();
    _setPressed(null);
  }

  void _setPressed(String? source) {
    if (_press.source == source) return;

    _press.source = source;
    _context.onChanged();
  }

  @override
  late final String symbolCharacter;
  @override
  late final TextStyle Function(TextStyle source)? style;
  @override
  late final InlineSpan Function(String text, TextStyle style)? builder;

  @override
  void dispose() {
    _press.releaseTimer?.cancel();
    for (final recognizer in _recognizers.values) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  List<Object> get props => [symbolCharacter];

  @override
  bool? get stringify => true;
}

class _LinkPress {
  String? source;
  Timer? releaseTimer;
}

/// Reports a touch right away.
///
/// [onTapDown] waits until the tap wins against the other gestures, which
/// takes [kPressTimeout] whenever anything else listens for the same pointer.
class _LinkTapGestureRecognizer extends TapGestureRecognizer {
  _LinkTapGestureRecognizer({
    required this.onPointerDown,
    required this.onRejected,
  });

  final VoidCallback onPointerDown;
  final VoidCallback onRejected;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    onPointerDown();
    super.addAllowedPointer(event);
  }

  @override
  void rejectGesture(int pointer) {
    super.rejectGesture(pointer);
    onRejected();
  }
}
