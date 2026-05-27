import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/services/hive_service.dart';
import '../models/transaction_model.dart';

class LocalTransactionDatasource {
  Box<Map> get _box => HiveService.instance.transactionsBox;

  Future<void> save(TransactionModel txn) async {
    await _box.put(txn.txnId, txn.toMap());
  }

  Future<TransactionModel?> getById(String txnId) async {
    final data = _box.get(txnId);
    if (data == null) return null;
    return TransactionModel.fromMap(data);
  }

  Future<void> softDelete(String txnId) async {
    final existing = _box.get(txnId);
    if (existing != null) {
      final txn =
          TransactionModel.fromMap(existing).copyWith(isDeleted: true);
      await _box.put(txnId, txn.toMap());
    }
  }

  Future<void> restore(String txnId) async {
    final existing = _box.get(txnId);
    if (existing != null) {
      final txn =
          TransactionModel.fromMap(existing).copyWith(isDeleted: false);
      await _box.put(txnId, txn.toMap());
    }
  }

  Future<List<TransactionModel>> getAll(String shopId) async {
    final all = _box.values
        .map((m) => TransactionModel.fromMap(m))
        .where((t) => t.shopId == shopId && !t.isDeleted)
        .toList();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  Future<double> getTodayTotal(String shopId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final txns = _box.values
        .map((m) => TransactionModel.fromMap(m))
        .where((t) =>
            t.shopId == shopId &&
            !t.isDeleted &&
            t.type == TxnType.sale &&
            t.createdAt.isAfter(startOfDay) &&
            t.createdAt.isBefore(endOfDay))
        .toList();
    return txns.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  Future<List<TransactionModel>> search(String shopId, String query) async {
    final q = query.toLowerCase();
    final all = await getAll(shopId);
    return all.where((t) {
      final item = (t.itemName ?? '').toLowerCase();
      final customer = (t.customerName ?? '').toLowerCase();
      return item.contains(q) || customer.contains(q);
    }).toList();
  }

  /// Migrates all records from oldShopId to newShopId (called once on first login)
  Future<void> migrateShopId(String oldShopId, String newShopId) async {
    if (oldShopId == newShopId) return;
    final toMigrate = _box.values
        .map((m) => TransactionModel.fromMap(m))
        .where((t) => t.shopId == oldShopId)
        .toList();
    for (final txn in toMigrate) {
      final migrated = TransactionModel(
        txnId: txn.txnId,
        shopId: newShopId,
        amount: txn.amount,
        expression: txn.expression,
        typeIndex: txn.typeIndex,
        createdAt: txn.createdAt,
        itemName: txn.itemName,
        customerName: txn.customerName,
        notes: txn.notes,
        isDeleted: txn.isDeleted,
        synced: txn.synced,
      );
      await _box.put(txn.txnId, migrated.toMap());
    }
  }
}