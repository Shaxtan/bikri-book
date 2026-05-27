/// Pure Dart calculator engine.
/// No Flutter dependencies — fully unit-testable in isolation.
///
/// Behaviour mirrors the standard Android (AOSP) calculator:
///   • Operator chain:  120 [+] 250 [+] 80 [=]  → 450
///   • Repeat equals:  [=] again repeats the last operation
///   • Percentage:     20 [%] → 0.2
///   • The expression line shows what was typed; the display shows the current value.
class CalculatorEngine {
  // ── Internal state ────────────────────────────────────────────
  double _operand1 = 0;
  double _lastOperand = 0;    // for repeat-equals
  String? _pendingOp;         // + − × ÷
  String? _lastOp;            // for repeat-equals
  String _currentInput = '0';
  String _expressionDisplay = '';
  bool _newOperandExpected = false; // after pressing an operator or =
  bool _justCalculated = false;
  double? _result;

  // ── Public getters ────────────────────────────────────────────

  /// The main large number shown on screen.
  String get displayValue => _currentInput;

  /// The small expression shown above the main display.
  /// Shows the running expression while typing; shows "expr =" after [=].
  String get expressionDisplay => _expressionDisplay;

  /// The numeric result of the last completed calculation (null if none yet).
  double? get result => _justCalculated ? _result : null;

  /// True once [=] has been pressed; resets on next digit or operator input.
  bool get justCalculated => _justCalculated;

  /// The raw double of whatever is currently on the display.
  double get currentValue => double.tryParse(_currentInput) ?? 0;

  // ── Digit & decimal input ─────────────────────────────────────

  void pressDigit(String digit) {
    assert(digit.length == 1 && '0123456789'.contains(digit));

    if (_justCalculated || _newOperandExpected) {
      _currentInput = digit == '0' ? '0' : digit;
      _justCalculated = false;
      _newOperandExpected = false;
    } else {
      if (_currentInput == '0') {
        _currentInput = digit;
      } else if (_currentInput == '-0') {
        _currentInput = '-$digit';
      } else if (_currentInput.replaceAll('-', '').replaceAll('.', '').length < 12) {
        _currentInput += digit;
      }
    }
  }

  void pressDecimal() {
    if (_justCalculated || _newOperandExpected) {
      _currentInput = '0.';
      _justCalculated = false;
      _newOperandExpected = false;
      return;
    }
    if (!_currentInput.contains('.')) {
      _currentInput += '.';
    }
  }

  // ── Operator input ────────────────────────────────────────────

  void pressOperator(String op) {
    assert(['+', '−', '×', '÷'].contains(op));

    final current = double.tryParse(_currentInput) ?? 0;

    if (_pendingOp != null && !_newOperandExpected) {
      // Chain: evaluate the pending op first, then set new pending op
      final r = _applyOp(_operand1, _pendingOp!, current);
      _result = r;
      _operand1 = r;
      _expressionDisplay = '${_expressionDisplay}$_currentInput $op ';
      _currentInput = _formatResult(r);
    } else {
      _operand1 = current;
      _expressionDisplay = '$_currentInput $op ';
    }

    _pendingOp = op;
    _newOperandExpected = true;
    _justCalculated = false;
  }

  // ── Equals ────────────────────────────────────────────────────

  void pressEquals() {
    final current = double.tryParse(_currentInput) ?? 0;

    if (_justCalculated) {
      // Repeat last operation
      if (_lastOp != null) {
        final r = _applyOp(currentValue, _lastOp!, _lastOperand);
        _result = r;
        _expressionDisplay = '$_currentInput ${_lastOp!} ${_formatResult(_lastOperand)} =';
        _currentInput = _formatResult(r);
        _operand1 = r;
      }
      return;
    }

    if (_pendingOp == null) return;

    _lastOp = _pendingOp;
    _lastOperand = current;

    final r = _applyOp(_operand1, _pendingOp!, current);
    _result = r;
    _expressionDisplay = '${_expressionDisplay}$_currentInput =';
    _currentInput = _formatResult(r);
    _pendingOp = null;
    _newOperandExpected = false;
    _justCalculated = true;
  }

  // ── Special operations ────────────────────────────────────────

  /// All-Clear: resets everything.
  void pressAC() {
    _operand1 = 0;
    _lastOperand = 0;
    _pendingOp = null;
    _lastOp = null;
    _currentInput = '0';
    _expressionDisplay = '';
    _newOperandExpected = false;
    _justCalculated = false;
    _result = null;
  }

  /// Delete last character (backspace). After [=], behaves like AC.
  void pressDelete() {
    if (_justCalculated) {
      pressAC();
      return;
    }
    if (_newOperandExpected) return; // nothing typed yet after operator
    if (_currentInput.length > 1) {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      // If only '-' is left, clear to '0'
      if (_currentInput == '-') _currentInput = '0';
    } else {
      _currentInput = '0';
    }
  }

  /// Converts current value to percentage (divides by 100).
  void pressPercent() {
    final val = double.tryParse(_currentInput);
    if (val == null) return;
    _currentInput = _formatResult(val / 100);
    _justCalculated = false;
  }

  /// Toggles the sign of the current input.
  void pressToggleSign() {
    if (_currentInput == '0') return;
    if (_currentInput.startsWith('-')) {
      _currentInput = _currentInput.substring(1);
    } else {
      _currentInput = '-$_currentInput';
    }
  }

  // ── Helpers ───────────────────────────────────────────────────

  double _applyOp(double a, String op, double b) {
    switch (op) {
      case '+': return a + b;
      case '−': return a - b;
      case '×': return a * b;
      case '÷': return b == 0 ? double.nan : a / b;
      default: return b;
    }
  }

  String _formatResult(double n) {
    if (n.isNaN) return 'Error';
    if (n.isInfinite) return n > 0 ? '∞' : '-∞';
    // If integer-valued, show without decimal point
    if (n == n.truncateToDouble() && n.abs() < 1e15) {
      return n.toInt().toString();
    }
    // Strip trailing zeros after decimal
    String s = n.toStringAsFixed(8);
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  /// Returns a human-readable export string, e.g. "120 + 250 + 80 = 450"
  String get exportLabel {
    if (_expressionDisplay.isEmpty) return _currentInput;
    if (_justCalculated) return _expressionDisplay;
    return '${_expressionDisplay.trimRight()}';
  }
}
