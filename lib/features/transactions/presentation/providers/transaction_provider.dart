import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/local_transaction_datasource.dart';
import '../../data/models/transaction_model.dart';
import '../../../../core/providers.dart';
import '../../../../core/services/firestore_sync_service.dart';

class TransactionState {
  const TransactionState({
    this.transactions = const [],
    this.todayTotal = 0,
    this.isLoading = false,
    this.searchQuery = '',
    this.lastSavedId,
  });

  final List<TransactionModel> transactions;
  final double todayTotal;
  final bool isLoading;
  final String searchQuery;
  final String? lastSavedId;

  List<TransactionModel> get filtered {
    if (searchQuery.isEmpty) return transactions;
    final q = searchQuery.toLowerCase();
    return transactions.where((t) {
      final item = (t.itemName ?? '').toLowerCase();
      final customer = (t.customerName ?? '').toLowerCase();
      return item.contains(q) || customer.contains(q);
    }).toList();
  }

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    double? todayTotal,
    bool? isLoading,
    String? searchQuery,
    String? lastSavedId,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      todayTotal: todayTotal ?? this.todayTotal,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      lastSavedId: lastSavedId ?? this.lastSavedId,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier(this._ds, this._shopId)
      : super(const TransactionState()) {
    _loadAll();
  }

  final LocalTransactionDatasource _ds;
  final String _shopId;

  Future<void> _loadAll() async {
    state = state.copyWith(isLoading: true);
    final txns = await _ds.getAll(_shopId);
    final todayTotal = await _ds.getTodayTotal(_shopId);
    state = state.copyWith(
      transactions: txns,
      todayTotal: todayTotal,
      isLoading: false,
    );
  }

  Future<void> save({
    required double amount,
    required String expression,
    required TxnType type,
    String? itemName,
    String? customerName,
    String? notes,
  }) async {
    final txn = TransactionModel(
      txnId: const Uuid().v4(),
      shopId: _shopId,
      amount: amount,
      expression: expression,
      typeIndex: type.index,
      itemName:
          itemName?.trim().isEmpty == true ? null : itemName?.trim(),
      customerName: customerName?.trim().isEmpty == true
          ? null
          : customerName?.trim(),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      createdAt: DateTime.now(),
    );

    // 1. Save locally first
    await _ds.save(txn);

    // 2. Push to Firestore in background (non-blocking)
    FirestoreSyncService.instance.pushTransaction(txn);

    await _loadAll();
    state = state.copyWith(lastSavedId: txn.txnId);
  }

  Future<void> delete(String txnId) async {
    await _ds.softDelete(txnId);
    FirestoreSyncService.instance.softDeleteTransaction(txnId);
    await _loadAll();
  }

  Future<void> restore(String txnId) async {
    await _ds.restore(txnId);
    await _loadAll();
  }

  void setSearchQuery(String q) {
    state = state.copyWith(searchQuery: q);
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  final ds = ref.watch(localTransactionDsProvider);
  final settings = ref.watch(settingsProvider);
  return TransactionNotifier(ds, settings.shopId);
});