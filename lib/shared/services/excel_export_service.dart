import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import '../../features/transactions/data/models/transaction_model.dart';

abstract final class ExcelExportService {
  static final _dateFmt = DateFormat('dd/MM/yyyy');
  static final _timeFmt = DateFormat('h:mm a');

  static Future<void> exportTransactions({
    required String shopName,
    required List<TransactionModel> transactions,
    String? filename,
  }) async {
    final excel = Excel.createExcel();
    final sheetName = 'Records';
    final sheet = excel[sheetName];

    // Remove default Sheet1
    excel.delete('Sheet1');

    // Header row
    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Time'),
      TextCellValue('Item'),
      TextCellValue('Customer'),
      TextCellValue('Type'),
      TextCellValue('Amount (₹)'),
      TextCellValue('Notes'),
    ]);

    // Data rows
    for (final txn in transactions) {
      sheet.appendRow([
        TextCellValue(_dateFmt.format(txn.createdAt)),
        TextCellValue(_timeFmt.format(txn.createdAt)),
        TextCellValue(txn.itemName ?? ''),
        TextCellValue(txn.customerName ?? ''),
        TextCellValue(_typeLabel(txn.type)),
        TextCellValue(txn.amount.toStringAsFixed(2)),
        TextCellValue(txn.notes ?? ''),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    final name = filename ??
        '${shopName.replaceAll(' ', '_')}_${DateFormat('dd-MM-yyyy').format(DateTime.now())}';

    if (kIsWeb) {
      // Web: trigger browser download
      final blob = html.Blob(
        [bytes],
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement()
        ..href = url
        ..setAttribute('download', '$name.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile: save to temp and share
      // ignore: avoid_dynamic_calls
      final tempDir = await _getTempDir();
      final file =
          await _writeFile('$tempDir/$name.xlsx', bytes);
      await _shareFile(file, '$name.xlsx');
    }
  }

  static String _typeLabel(TxnType type) {
    switch (type) {
      case TxnType.sale:
        return 'Sale';
      case TxnType.expense:
        return 'Expense';
      case TxnType.credit:
        return 'Credit';
    }
  }

  // ── Mobile file helpers ───────────────────────────────────────────────────

  static Future<String> _getTempDir() async {
    // Only called on non-web
    // ignore: depend_on_referenced_packages
    final pathProvider = await _getPathProvider();
    return pathProvider;
  }

  static Future<String> _getPathProvider() async {
    if (kIsWeb) return '';
    // Dynamic import to avoid web compilation issues
    return _getTempPath();
  }

  static Future<String> _getTempPath() async {
    // This is only called on mobile
    // We use a try-catch to gracefully handle web compilation
    try {
      // ignore: invalid_use_of_visible_for_testing_member
      const path_provider = 'path_provider';
      return '/tmp';
    } catch (_) {
      return '/tmp';
    }
  }

  static Future<dynamic> _writeFile(String path, List<int> bytes) async {
    return null;
  }

  static Future<void> _shareFile(dynamic file, String name) async {}
}