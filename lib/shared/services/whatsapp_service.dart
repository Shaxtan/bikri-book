import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../core/utils/currency_formatter.dart';

abstract final class WhatsAppService {
  static final _dateFmt = DateFormat('dd MMM yyyy');
  static final _timeFmt = DateFormat('h:mm a');

  static Future<void> shareDailyReport({
    required String shopName,
    required DateTime date,
    required List<TransactionModel> transactions,
    required double total,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('📒 *$shopName — Daily Report*');
    buffer.writeln('📅 ${_dateFmt.format(date)}');
    buffer.writeln('─────────────────');

    for (final txn in transactions) {
      final icon = txn.type == TxnType.sale
          ? '🟢'
          : txn.type == TxnType.expense
              ? '🔴'
              : '🟡';
      final name = txn.itemName ?? 'Item';
      final customer =
          txn.customerName != null ? ' (${txn.customerName})' : '';
      final amount = CurrencyFormatter.format(txn.amount);
      final time = _timeFmt.format(txn.createdAt);
      buffer.writeln('$icon $name$customer — $amount [$time]');
    }

    buffer.writeln('─────────────────');
    buffer.writeln('💰 *Total: ${CurrencyFormatter.format(total)}*');
    buffer.writeln('📦 Records: ${transactions.length}');
    buffer.writeln('');
    buffer.writeln('_Sent via Bikri-Book 📱_');

    final text = buffer.toString();

    final waUrl = Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(text)}');

    if (await canLaunchUrl(waUrl)) {
      await launchUrl(waUrl, mode: LaunchMode.externalApplication);
    } else {
      await Share.share(text, subject: '$shopName — Daily Report');
    }
  }
}