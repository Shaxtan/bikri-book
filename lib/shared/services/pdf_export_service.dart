import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/customers/data/models/customer_model.dart';
import '../../features/transactions/data/models/transaction_model.dart';

abstract final class PdfExportService {
  static final _dateFmt = DateFormat('dd MMM yyyy');
  static final _shortDate = DateFormat('dd/MM/yy');

  static Future<void> exportDailyReport({
    required String shopName,
    required DateTime date,
    required List<TransactionModel> transactions,
    required double total,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#1A7F4B'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(shopName,
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text('Daily Report — ${_dateFmt.format(date)}',
                    style: const pw.TextStyle(
                        color: PdfColors.white, fontSize: 12)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Summary row
          pw.Row(children: [
            _summaryBox('Total Sales', CurrencyFormatter.format(total)),
            pw.SizedBox(width: 12),
            _summaryBox('Records', '${transactions.length}'),
          ]),
          pw.SizedBox(height: 20),

          // Table header
          pw.Container(
            color: PdfColor.fromHex('#E8F5E9'),
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: pw.Row(children: [
              pw.Expanded(
                  flex: 3,
                  child: pw.Text('Item',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 11))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text('Customer',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 11))),
              pw.Expanded(
                  flex: 1,
                  child: pw.Text('Type',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 11))),
              pw.Text('Amount',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 11)),
            ]),
          ),

          // Rows
          ...transactions.map((t) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8, vertical: 5),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom: pw.BorderSide(
                          color: PdfColor.fromHex('#E0E0E0'),
                          width: 0.5)),
                ),
                child: pw.Row(children: [
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text(t.itemName ?? '—',
                          style: const pw.TextStyle(fontSize: 11))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text(t.customerName ?? '—',
                          style: const pw.TextStyle(fontSize: 11))),
                  pw.Expanded(
                      flex: 1,
                      child: pw.Text(_typeLabel(t.type),
                          style: const pw.TextStyle(fontSize: 11))),
                  pw.Text(CurrencyFormatter.format(t.amount),
                      style: const pw.TextStyle(fontSize: 11)),
                ]),
              )),

          pw.SizedBox(height: 16),

          // Total
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#E8F5E9'),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 13)),
                pw.Text(CurrencyFormatter.format(total),
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 13,
                        color: PdfColor.fromHex('#1A7F4B'))),
              ],
            ),
          ),
          pw.Spacer(),
          pw.Text('Generated by Bikri-Book',
              style: const pw.TextStyle(
                  fontSize: 9, color: PdfColors.grey)),
        ],
      ),
    ));

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          '${shopName.replaceAll(' ', '_')}_${DateFormat('dd-MM-yyyy').format(date)}.pdf',
    );
  }

  static Future<void> exportCustomerReport({
    required CustomerModel customer,
    required List<TransactionModel> transactions,
    required double balance,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#1A7F4B'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Customer Khata',
                    style: const pw.TextStyle(
                        color: PdfColors.white, fontSize: 13)),
                pw.Text(customer.name,
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold)),
                if (customer.phone != null)
                  pw.Text(customer.phone!,
                      style: const pw.TextStyle(
                          color: PdfColors.white, fontSize: 12)),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
              'Outstanding Balance: ${CurrencyFormatter.format(balance)}',
              style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#FF8F00'))),
          pw.SizedBox(height: 16),
          pw.Text('Transaction History',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 13)),
          pw.SizedBox(height: 8),
          ...transactions.map((t) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(children: [
                  pw.Text(_shortDate.format(t.createdAt),
                      style: const pw.TextStyle(
                          fontSize: 11, color: PdfColors.grey)),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                      child: pw.Text(t.itemName ?? '—',
                          style: const pw.TextStyle(fontSize: 11))),
                  pw.Text(CurrencyFormatter.format(t.amount),
                      style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: t.type == TxnType.credit
                              ? PdfColor.fromHex('#FF8F00')
                              : PdfColor.fromHex('#1A7F4B'))),
                ]),
              )),
          pw.Spacer(),
          pw.Text('Generated by Bikri-Book',
              style: const pw.TextStyle(
                  fontSize: 9, color: PdfColors.grey)),
        ],
      ),
    ));

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${customer.name.replaceAll(' ', '_')}_khata.pdf',
    );
  }

  static pw.Widget _summaryBox(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#E8F5E9'),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: const pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey)),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#1A7F4B'))),
          ],
        ),
      ),
    );
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
}