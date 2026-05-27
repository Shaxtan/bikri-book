import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.txn,
    required this.onDelete,
  });

  final TransactionModel txn;
  final VoidCallback onDelete;

  static final _timeFormat = DateFormat('h:mm a');

  Color get _amountColor {
    switch (txn.type) {
      case TxnType.sale:
        return AppColors.sale;
      case TxnType.expense:
        return AppColors.expense;
      case TxnType.credit:
        return AppColors.credit;
    }
  }

  Color get _iconBg {
    switch (txn.type) {
      case TxnType.sale:
        return AppColors.saleChipBg;
      case TxnType.expense:
        return AppColors.expenseChipBg;
      case TxnType.credit:
        return AppColors.creditChipBg;
    }
  }

  IconData get _icon {
    switch (txn.type) {
      case TxnType.sale:
        return Icons.shopping_bag_outlined;
      case TxnType.expense:
        return Icons.arrow_downward_rounded;
      case TxnType.credit:
        return Icons.access_time_outlined;
    }
  }

  String get _amountPrefix {
    switch (txn.type) {
      case TxnType.sale:
        return '+';
      case TxnType.expense:
        return '−';
      case TxnType.credit:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(txn.txnId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.expense,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete record?'),
            content: Text(
              'Delete "${txn.itemName ?? 'this record'}" (${CurrencyFormatter.format(txn.amount)})?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.expense),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // ── Icon ───────────────────────────────────────
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 18, color: _amountColor),
            ),
            const SizedBox(width: 12),

            // ── Info ────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn.itemName ?? 'Record',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _buildSubtitle(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Amount ──────────────────────────────────────
            Text(
              '$_amountPrefix${CurrencyFormatter.format(txn.amount)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _amountColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    parts.add(_timeFormat.format(txn.createdAt));
    if (txn.customerName != null) parts.add(txn.customerName!);
    if (txn.type == TxnType.credit) parts.add('Udhaari');
    return parts.join(' · ');
  }
}

// ── Daily section header ──────────────────────────────────────────────────────

class DailySectionHeader extends StatelessWidget {
  const DailySectionHeader({
    super.key,
    required this.label,
    required this.total,
  });

  final String label;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Text(
            CurrencyFormatter.format(total),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
