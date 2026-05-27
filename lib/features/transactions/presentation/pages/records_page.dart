import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_tile.dart';

class RecordsPage extends ConsumerStatefulWidget {
  const RecordsPage({super.key});

  @override
  ConsumerState<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends ConsumerState<RecordsPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionProvider);
    final transactions = state.filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export coming in next update!')),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (q) =>
                  ref.read(transactionProvider.notifier).setSearchQuery(q),
              decoration: InputDecoration(
                hintText: 'Cheez ya customer dhundo...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref
                              .read(transactionProvider.notifier)
                              .setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),

          // ── Summary strip ──────────────────────────────────
          if (state.searchQuery.isEmpty)
            _SummaryStrip(todayTotal: state.todayTotal),

          // ── List ───────────────────────────────────────────
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : transactions.isEmpty
                    ? _EmptyState(hasQuery: state.searchQuery.isNotEmpty)
                    : _TransactionList(
                        transactions: transactions,
                        onDelete: (txnId) => _handleDelete(txnId),
                      ),
          ),
        ],
      ),
    );
  }

  void _handleDelete(String txnId) async {
    await ref.read(transactionProvider.notifier).delete(txnId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Record deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () =>
                ref.read(transactionProvider.notifier).restore(txnId),
          ),
        ),
      );
    }
  }
}

// ── Summary strip ─────────────────────────────────────────────────────────────

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.todayTotal});
  final double todayTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryPale,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.today_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          const Text(
            "Aaj ki Bikri:",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            CurrencyFormatter.format(todayTotal),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Transaction list grouped by date ─────────────────────────────────────────

class _TransactionList extends StatelessWidget {
  const _TransactionList({
    required this.transactions,
    required this.onDelete,
  });

  final List<TransactionModel> transactions;
  final ValueChanged<String> onDelete;

  static final _dateFormat = DateFormat('d MMM, EEEE');

  /// Groups transactions by calendar date (local).
  Map<DateTime, List<TransactionModel>> _groupByDate(
      List<TransactionModel> txns) {
    final map = <DateTime, List<TransactionModel>>{};
    for (final t in txns) {
      final key = DateTime(
          t.createdAt.year, t.createdAt.month, t.createdAt.day);
      (map[key] ??= []).add(t);
    }
    return map;
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return 'Aaj';
    if (date == yesterday) return 'Kal';
    return _dateFormat.format(date);
  }

  double _dayTotal(List<TransactionModel> dayTxns) {
    double total = 0;
    for (final t in dayTxns) {
      if (t.type == TxnType.sale) total += t.amount;
      if (t.type == TxnType.expense) total -= t.amount;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(transactions);
    final sortedDates = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, i) {
        final date = sortedDates[i];
        final dayTxns = grouped[date]!;
        final total = _dayTotal(dayTxns);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DailySectionHeader(
              label: _dateLabel(date),
              total: total,
            ),
            const Divider(height: 0.5),
            ...dayTxns.map((txn) => Column(
                  children: [
                    TransactionTile(
                      txn: txn,
                      onDelete: () => onDelete(txn.txnId),
                    ),
                    const Divider(height: 0.5, indent: 66),
                  ],
                )),
          ],
        );
      },
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasQuery});
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasQuery ? Icons.search_off : Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            hasQuery
                ? 'No results found'
                : 'Abhi koi record nahi.\nBikri karo aur Save dabao!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
