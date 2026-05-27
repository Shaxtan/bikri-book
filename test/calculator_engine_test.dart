import 'package:flutter_test/flutter_test.dart';
import 'package:bikri_book/features/calculator/domain/calculator_engine.dart';

void main() {
  late CalculatorEngine calc;

  setUp(() => calc = CalculatorEngine());

  group('CalculatorEngine — basic operations', () {
    test('Initial state shows 0', () {
      expect(calc.displayValue, '0');
      expect(calc.expressionDisplay, '');
    });

    test('Digit input', () {
      calc.pressDigit('1');
      calc.pressDigit('2');
      calc.pressDigit('0');
      expect(calc.displayValue, '120');
    });

    test('Simple addition: 120 + 250 = 370', () {
      _type(calc, '120');
      calc.pressOperator('+');
      _type(calc, '250');
      calc.pressEquals();
      expect(calc.displayValue, '370');
    });

    test('Chained addition: 120 + 250 + 80 = 450', () {
      _type(calc, '120');
      calc.pressOperator('+');
      _type(calc, '250');
      calc.pressOperator('+');
      _type(calc, '80');
      calc.pressEquals();
      expect(calc.displayValue, '450');
      expect(calc.result, 450);
    });

    test('Subtraction: 500 − 125 = 375', () {
      _type(calc, '500');
      calc.pressOperator('−');
      _type(calc, '125');
      calc.pressEquals();
      expect(calc.displayValue, '375');
    });

    test('Multiplication: 12 × 15 = 180', () {
      _type(calc, '12');
      calc.pressOperator('×');
      _type(calc, '15');
      calc.pressEquals();
      expect(calc.displayValue, '180');
    });

    test('Division: 100 ÷ 4 = 25', () {
      _type(calc, '100');
      calc.pressOperator('÷');
      _type(calc, '4');
      calc.pressEquals();
      expect(calc.displayValue, '25');
    });

    test('Division by zero shows Error', () {
      _type(calc, '10');
      calc.pressOperator('÷');
      _type(calc, '0');
      calc.pressEquals();
      expect(calc.displayValue, 'Error');
    });
  });

  group('Special operations', () {
    test('AC clears everything', () {
      _type(calc, '123');
      calc.pressAC();
      expect(calc.displayValue, '0');
      expect(calc.expressionDisplay, '');
    });

    test('Decimal input: 12.5', () {
      _type(calc, '12');
      calc.pressDecimal();
      calc.pressDigit('5');
      expect(calc.displayValue, '12.5');
    });

    test('Percentage: 50% = 0.5', () {
      _type(calc, '50');
      calc.pressPercent();
      expect(calc.displayValue, '0.5');
    });

    test('Toggle sign: 100 → -100 → 100', () {
      _type(calc, '100');
      calc.pressToggleSign();
      expect(calc.displayValue, '-100');
      calc.pressToggleSign();
      expect(calc.displayValue, '100');
    });

    test('Delete removes last digit', () {
      _type(calc, '123');
      calc.pressDelete();
      expect(calc.displayValue, '12');
    });

    test('Delete on single digit → 0', () {
      calc.pressDigit('5');
      calc.pressDelete();
      expect(calc.displayValue, '0');
    });
  });

  group('Edge cases', () {
    test('New input after = replaces display', () {
      _type(calc, '10');
      calc.pressOperator('+');
      _type(calc, '5');
      calc.pressEquals();
      calc.pressDigit('9');
      expect(calc.displayValue, '9');
    });

    test('justCalculated is true after =', () {
      _type(calc, '5');
      calc.pressOperator('+');
      _type(calc, '3');
      calc.pressEquals();
      expect(calc.justCalculated, isTrue);
    });

    test('Export label after chained calculation', () {
      _type(calc, '120');
      calc.pressOperator('+');
      _type(calc, '250');
      calc.pressOperator('+');
      _type(calc, '80');
      calc.pressEquals();
      expect(calc.exportLabel, contains('120'));
      expect(calc.exportLabel, contains('250'));
      expect(calc.exportLabel, contains('80'));
    });
  });
}

/// Helper: type each character of a string as digit presses.
void _type(CalculatorEngine c, String s) {
  for (final ch in s.split('')) {
    if (ch == '.') {
      c.pressDecimal();
    } else {
      c.pressDigit(ch);
    }
  }
}
