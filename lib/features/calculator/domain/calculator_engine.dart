class CalculatorEngine {
  String _expr = '';
  double? _result;
  bool _justCalculated = false;
  int _cursorPos = 0;

  String get expression => _expr;
  int get cursorPos => _cursorPos;
  bool get justCalculated => _justCalculated;
  double? get result => _justCalculated ? _result : null;

  bool get canSave {
    if (_justCalculated) return (_result ?? 0) != 0;
    final lr = liveResult;
    if (lr.isEmpty) return false;
    return (double.tryParse(lr) ?? 0) != 0;
  }

  double get saveAmount {
    if (_justCalculated && _result != null) return _result!;
    return double.tryParse(liveResult) ?? 0;
  }

  String get exportLabel =>
      _justCalculated ? '$_expr = ${_fmt(_result!)}' : _expr;

  /// Live running total shown below expression as user types
  String get liveResult {
    if (_justCalculated) return _fmt(_result!);
    if (_expr.trim().isEmpty) return '';
    // Remove trailing incomplete operator before evaluating
    final cleaned = _expr
        .trim()
        .replaceAll(RegExp(r'\s+[+\-×÷]\s*$'), '')
        .trim();
    if (cleaned.isEmpty) return '';
    try {
      final r = _evaluateExpression(cleaned);
      if (!r.isNaN && !r.isInfinite) return _fmt(r);
    } catch (_) {}
    return '';
  }

  // ── Insert at cursor ──────────────────────────────────────────

  void insertAtCursor(String char) {
    if (_justCalculated) {
      _expr = char;
      _cursorPos = 1;
      _result = null;
      _justCalculated = false;
      return;
    }
    _expr =
        _expr.substring(0, _cursorPos) + char + _expr.substring(_cursorPos);
    _cursorPos += char.length;
  }

  void insertOperatorAtCursor(String op) {
    if (_justCalculated) {
      final res = _fmt(_result!);
      _expr = '$res $op ';
      _cursorPos = _expr.length;
      _result = null;
      _justCalculated = false;
      return;
    }
    if (_expr.isEmpty) return;

    final before = _expr.substring(0, _cursorPos);
    final after = _expr.substring(_cursorPos);
    final trailingOp = RegExp(r'\s+[+\-×÷]\s*$');
    final cleaned = trailingOp.hasMatch(before)
        ? before.replaceFirst(trailingOp, '')
        : before;
    final token = ' $op ';
    _expr = cleaned + token + after;
    _cursorPos = cleaned.length + token.length;
  }

  void setCursorPos(int pos) {
    _cursorPos = pos.clamp(0, _expr.length);
  }

  // ── Backspace ─────────────────────────────────────────────────

  void backspace() {
    if (_justCalculated) {
      _expr = '';
      _cursorPos = 0;
      _result = null;
      _justCalculated = false;
      return;
    }
    if (_expr.isEmpty || _cursorPos == 0) return;

    final before = _expr.substring(0, _cursorPos);
    final after = _expr.substring(_cursorPos);

    // Remove entire " OP " chunk as one unit
    final opChunk = RegExp(r' [+\-×÷] $');
    if (opChunk.hasMatch(before)) {
      final match = opChunk.firstMatch(before)!;
      _expr = before.substring(0, match.start) + after;
      _cursorPos = match.start;
    } else {
      _expr = before.substring(0, before.length - 1) + after;
      _cursorPos -= 1;
    }
  }

  // ── Special ops ───────────────────────────────────────────────

  void pressPercent() {
    final last = _lastNumber();
    if (last.isEmpty) return;
    final val = double.tryParse(last);
    if (val == null) return;
    final pct = _fmt(val / 100);
    final idx = _expr.lastIndexOf(last);
    if (idx >= 0) {
      _expr =
          _expr.substring(0, idx) + pct + _expr.substring(idx + last.length);
      _cursorPos = (idx + pct.length).clamp(0, _expr.length);
    }
  }

  void pressToggleSign() {
    final last = _lastNumber();
    if (last.isEmpty || last == '0') return;
    final idx = _expr.lastIndexOf(last);
    if (idx < 0) return;
    final toggled =
        last.startsWith('-') ? last.substring(1) : '-$last';
    _expr = _expr.substring(0, idx) +
        toggled +
        _expr.substring(idx + last.length);
    _cursorPos = (idx + toggled.length).clamp(0, _expr.length);
  }

  void pressEquals() {
    if (_expr.trim().isEmpty) return;
    if (_justCalculated) return;
    try {
      final r = _evaluateExpression(_expr.trim());
      if (!r.isNaN && !r.isInfinite) {
        _result = r;
        _justCalculated = true;
        _cursorPos = _expr.length;
      }
    } catch (_) {}
  }

  void pressAC() {
    _expr = '';
    _cursorPos = 0;
    _result = null;
    _justCalculated = false;
  }

  // ── Expression evaluator ──────────────────────────────────────

  double _evaluateExpression(String expr) {
    expr = expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-');
    final tokens = _tokenize(expr);
    if (tokens.isEmpty) return 0;
    return _evalTokens(tokens);
  }

  List<dynamic> _tokenize(String expr) {
    final result = <dynamic>[];
    int i = 0;
    while (i < expr.length) {
      final ch = expr[i];
      if (ch == ' ') {
        i++;
        continue;
      }
      if (RegExp(r'[0-9.]').hasMatch(ch)) {
        var num = '';
        while (
            i < expr.length && RegExp(r'[0-9.]').hasMatch(expr[i])) {
          num += expr[i++];
        }
        result.add(double.tryParse(num) ?? 0.0);
      } else if (ch == '-' &&
          (result.isEmpty || result.last is String)) {
        var num = '-';
        i++;
        while (
            i < expr.length && RegExp(r'[0-9.]').hasMatch(expr[i])) {
          num += expr[i++];
        }
        result.add(double.tryParse(num) ?? 0.0);
      } else if ('+-*/'.contains(ch)) {
        result.add(ch);
        i++;
      } else {
        i++;
      }
    }
    return result;
  }

  double _evalTokens(List<dynamic> tokens) {
    final tok = List<dynamic>.from(tokens);
    // Pass 1: × and ÷
    int i = 1;
    while (i < tok.length - 1) {
      if (tok[i] == '*' || tok[i] == '/') {
        final a = (tok[i - 1] as num).toDouble();
        final b = (tok[i + 1] as num).toDouble();
        final r = tok[i] == '*'
            ? a * b
            : (b == 0 ? double.nan : a / b);
        tok.replaceRange(i - 1, i + 2, [r]);
      } else {
        i += 2;
      }
    }
    // Pass 2: + and -
    double result = (tok[0] as num).toDouble();
    for (int j = 1; j < tok.length - 1; j += 2) {
      final b = (tok[j + 1] as num).toDouble();
      if (tok[j] == '+') result += b;
      if (tok[j] == '-') result -= b;
    }
    return result;
  }

  String _lastNumber() {
    if (_expr.isEmpty) return '';
    final parts = _expr.split(RegExp(r'\s+[+\-×÷]\s+'));
    for (int i = parts.length - 1; i >= 0; i--) {
      final p = parts[i].trim();
      if (p.isNotEmpty) return p;
    }
    return '';
  }

  String _fmt(double n) {
    if (n.isNaN) return 'Error';
    if (n.isInfinite) return n > 0 ? '∞' : '-∞';
    if (n == n.truncateToDouble() && n.abs() < 1e15) {
      return n.toInt().toString();
    }
    String s = n.toStringAsFixed(8);
    s = s
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    return s;
  }
}