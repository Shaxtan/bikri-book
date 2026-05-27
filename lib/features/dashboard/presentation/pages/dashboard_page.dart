import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/providers.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../../shared/services/pdf_export_service.dart';
import '../../../../shared/services/excel_export_service.dart';
import '../../../../shared/services/whatsapp_service.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnState = ref.watch(transactionProvider);
    final settings = ref.watch(settingsProvider);
    final txns = txnState.transactions;

    final todayTotal = txnState.todayTotal;
    final monthTotal = _getMonthTotal(txns);
    final totalCredit = txns
        .where((t) => t.type == TxnType.credit)
        .fold<double>(0, (s, t) => s + t.amount);
    final weekData = _getWeekData(txns);
    final topItems = _getTopItems(txns);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(settings.shopName),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart_outlined),
            tooltip: 'Export Excel',
            onPressed: () {
              ExcelExportService.exportTransactions(
                shopName: settings.shopName,
                transactions: txns,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share on WhatsApp',
            onPressed: () {
              final today = DateTime.now();
              final todayTxns = txns
                  .where((t) =>
                      t.createdAt.year == today.year &&
                      t.createdAt.month == today.month &&
                      t.createdAt.day == today.day)
                  .toList();
              WhatsAppService.shareDailyReport(
                shopName: settings.shopName,
                date: today,
                transactions: todayTxns,
                total: todayTotal,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export PDF',
            onPressed: () {
              final today = DateTime.now();
              final todayTxns = txns
                  .where((t) =>
                      t.createdAt.year == today.year &&
                      t.createdAt.month == today.month &&
                      t.createdAt.day == today.day)
                  .toList();
              PdfExportService.exportDailyReport(
                shopName: settings.shopName,
                date: today,
                transactions: todayTxns,
                total: todayTotal,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _greeting(),
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Today card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.today_outlined,
                    color: Colors.white70, size: 32),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Aaj ki Bikri',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(todayTotal),
                      style: GoogleFonts.robotoMono(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _MiniCard(
                    label: 'Is Mahine',
                    value: CurrencyFormatter.format(monthTotal),
                    color: AppColors.sale),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniCard(
                    label: 'Baaki Udhaari',
                    value: CurrencyFormatter.format(totalCredit),
                    color: AppColors.credit),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekly chart
          _WeeklyChart(weekData: weekData),
          const SizedBox(height: 16),

          // Top items
          if (topItems.isNotEmpty) ...[
            _TopItemsCard(items: topItems),
          ],
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Suprabhat! 🌅';
    if (h < 17) return 'Namaskar! ☀️';
    return 'Shubh Sandhya! 🌆';
  }

  List<_DayData> _getWeekData(List<TransactionModel> txns) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final day = DateTime(date.year, date.month, date.day);
      final total = txns
          .where((t) =>
              t.type == TxnType.sale &&
              t.createdAt.year == day.year &&
              t.createdAt.month == day.month &&
              t.createdAt.day == day.day)
          .fold<double>(0, (s, t) => s + t.amount);
      return _DayData(date: day, total: total);
    });
  }

  List<MapEntry<String, int>> _getTopItems(List<TransactionModel> txns) {
    final counts = <String, int>{};
    for (final t
        in txns.where((t) => t.type == TxnType.sale && t.itemName != null)) {
      counts[t.itemName!] = (counts[t.itemName!] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  double _getMonthTotal(List<TransactionModel> txns) {
    final now = DateTime.now();
    return txns
        .where((t) =>
            t.type == TxnType.sale &&
            t.createdAt.year == now.year &&
            t.createdAt.month == now.month)
        .fold<double>(0, (s, t) => s + t.amount);
  }
}

// ── Mini card ─────────────────────────────────────────────────────────────────

class _MiniCard extends StatelessWidget {
  const _MiniCard(
      {required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.robotoMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

// ── Weekly bar chart ──────────────────────────────────────────────────────────

class _DayData {
  const _DayData({required this.date, required this.total});
  final DateTime date;
  final double total;
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.weekData});
  final List<_DayData> weekData;

  @override
  Widget build(BuildContext context) {
    final maxTotal = weekData.isEmpty
        ? 1.0
        : weekData.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Is Hafte Ki Bikri',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weekData.map((d) {
                final isToday = d.date.day == today.day &&
                    d.date.month == today.month &&
                    d.date.year == today.year;
                final ratio = maxTotal == 0 ? 0.0 : d.total / maxTotal;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOut,
                            height: (ratio * 50) + (ratio > 0 ? 4 : 0),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.primaryPale,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('E').format(d.date).substring(0, 1),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isToday
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top items card ────────────────────────────────────────────────────────────

class _TopItemsCard extends StatelessWidget {
  const _TopItemsCard({required this.items});
  final List<MapEntry<String, int>> items;

  @override
  Widget build(BuildContext context) {
    final max = items.first.value;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Items',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(e.key,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: e.value / max,
                          backgroundColor: AppColors.primaryPale,
                          color: AppColors.primary,
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${e.value}x',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}