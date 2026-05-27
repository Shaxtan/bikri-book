import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';
import '../../data/models/customer_model.dart';
import '../../../../shared/services/pdf_export_service.dart';

class CustomerDetailPage extends ConsumerWidget {
  const CustomerDetailPage({
    super.key,
    required this.customer,
    required this.balance,
  });

  final CustomerModel customer;
  final double balance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnState = ref.watch(transactionProvider);
    final customerTxns = txnState.transactions
        .where((t) =>
            t.customerName?.toLowerCase() == customer.name.toLowerCase())
        .toList();

    final totalSales = customerTxns
        .where((t) => t.type == TxnType.sale)
        .fold<double>(0, (s, t) => s + t.amount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export Khata',
            onPressed: () => PdfExportService.exportCustomerReport(
              customer: customer,
              transactions: customerTxns,
              balance: balance,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header card
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryPale,
                  child: Text(
                    customer.name[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 26,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.name,
                          style: GoogleFonts.notoSans(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      if (customer.phone != null)
                        Text(customer.phone!,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Baaki Udhaari',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textTertiary)),
                    Text(
                      CurrencyFormatter.format(balance),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: balance > 0
                            ? AppColors.credit
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 0.5),

          // Stats
          Container(
            color: AppColors.surface,
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                _StatChip(
                    label: 'Total Txns',
                    value: '${customerTxns.length}'),
                const SizedBox(width: 12),
                _StatChip(
                    label: 'Total Sales',
                    value: CurrencyFormatter.format(totalSales)),
              ],
            ),
          ),
          const Divider(height: 0.5),

          // Transactions list
          Expanded(
            child: customerTxns.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions for this customer yet.',
                      style:
                          TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    itemCount: customerTxns.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 0.5, indent: 66),
                    itemBuilder: (context, i) => TransactionTile(
                      txn: customerTxns[i],
                      onDelete: () => ref
                          .read(transactionProvider.notifier)
                          .delete(customerTxns[i].txnId),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryPale,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontSize: 15)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}