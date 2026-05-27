import 'package:intl/intl.dart';

/// Formats numbers as Indian Rupee amounts.
/// Uses Indian numbering system: 1,23,456.00
abstract final class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _formatterDecimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// ₹1,23,456  (no decimals if whole number)
  static String format(double amount) {
    if (amount == amount.truncateToDouble()) {
      return _formatter.format(amount);
    }
    return _formatterDecimal.format(amount);
  }

  /// 1,23,456  (no ₹ symbol, for display inside calculator)
  static String formatCompact(double amount) {
    return format(amount).replaceFirst('₹', '').trim();
  }

  /// Used for the main calculator display: strips trailing zeros from decimals
  static String formatDisplay(double amount) {
    if (amount.isNaN || amount.isInfinite) return 'Error';
    if (amount == amount.truncateToDouble()) {
      return amount.toInt().toString();
    }
    // Up to 8 decimal places, strip trailing zeros
    String s = amount.toStringAsFixed(8);
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return s;
  }
}
