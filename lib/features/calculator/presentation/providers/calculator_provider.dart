import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/calculator_engine.dart';

class CalculatorState {
  const CalculatorState({
    this.expression = '',
    this.liveResult = '',
    this.justCalculated = false,
    this.result,
    this.canSave = false,
    this.cursorPos = 0,
  });

  final String expression;
  final String liveResult;
  final bool justCalculated;
  final double? result;
  final bool canSave;
  final int cursorPos;

  double get saveAmount =>
      result ?? (double.tryParse(liveResult) ?? 0);
}

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  CalculatorNotifier()
      : _engine = CalculatorEngine(),
        super(const CalculatorState());

  final CalculatorEngine _engine;

  CalculatorState _snap() => CalculatorState(
        expression: _engine.expression,
        liveResult: _engine.liveResult,
        justCalculated: _engine.justCalculated,
        result: _engine.result,
        canSave: _engine.canSave,
        cursorPos: _engine.cursorPos,
      );

  void pressDigit(String d) {
    _engine.insertAtCursor(d);
    state = _snap();
  }

  void pressDecimal() {
    final before = _engine.expression.substring(0, _engine.cursorPos);
    final parts = before.split(RegExp(r'\s+[+\-×÷]\s+'));
    if (!parts.last.contains('.')) {
      _engine.insertAtCursor('.');
      state = _snap();
    }
  }

  void pressOperator(String op) {
    _engine.insertOperatorAtCursor(op);
    state = _snap();
  }

  void pressBackspace() {
    _engine.backspace();
    state = _snap();
  }

  void pressEquals() {
    _engine.pressEquals();
    state = _snap();
  }

  void pressAC() {
    _engine.pressAC();
    state = _snap();
  }

  void pressPercent() {
    _engine.pressPercent();
    state = _snap();
  }

  void pressToggleSign() {
    _engine.pressToggleSign();
    state = _snap();
  }

  void setCursorPos(int pos) {
    _engine.setCursorPos(pos);
    state = _snap();
  }

  void clearAfterSave() {
    _engine.pressAC();
    state = _snap();
  }

  String get exportExpression => _engine.exportLabel;
}

final calculatorProvider =
    StateNotifierProvider<CalculatorNotifier, CalculatorState>(
        (_) => CalculatorNotifier());