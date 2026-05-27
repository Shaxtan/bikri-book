import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/calculator_engine.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class CalculatorState {
  const CalculatorState({
    required this.displayValue,
    required this.expressionDisplay,
    this.justCalculated = false,
    this.result,
  });

  final String displayValue;
  final String expressionDisplay;
  final bool justCalculated;
  final double? result;

  /// The amount to show on the Save button
  double get saveAmount => result ?? double.tryParse(displayValue) ?? 0;

  /// Whether there's something meaningful to save
  bool get canSave => saveAmount != 0 && displayValue != '0';
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  CalculatorNotifier()
      : _engine = CalculatorEngine(),
        super(const CalculatorState(
          displayValue: '0',
          expressionDisplay: '',
        ));

  final CalculatorEngine _engine;

  CalculatorState _snap() => CalculatorState(
        displayValue: _engine.displayValue,
        expressionDisplay: _engine.expressionDisplay,
        justCalculated: _engine.justCalculated,
        result: _engine.result,
      );

  void pressDigit(String digit) {
    _engine.pressDigit(digit);
    state = _snap();
  }

  void pressDecimal() {
    _engine.pressDecimal();
    state = _snap();
  }

  void pressOperator(String op) {
    _engine.pressOperator(op);
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

  void pressDelete() {
    _engine.pressDelete();
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

  /// Called after a save — clears the calculator.
  void clearAfterSave() {
    _engine.pressAC();
    state = _snap();
  }

  /// Returns the expression label for storage, e.g. "120 + 250 + 80"
  String get exportExpression => _engine.exportLabel;
}

// ── Provider ──────────────────────────────────────────────────────────────────

final calculatorProvider =
    StateNotifierProvider<CalculatorNotifier, CalculatorState>(
        (_) => CalculatorNotifier());
