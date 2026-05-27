import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/customers/data/models/customer_model.dart';
import '../../features/transactions/data/datasources/local_transaction_datasource.dart';
import '../../features/customers/data/datasources/local_customer_datasource.dart';

class FirestoreSyncService {
  FirestoreSyncService._();
  static final FirestoreSyncService instance = FirestoreSyncService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<bool> get _isOnline async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  DocumentReference get _userDoc => _db.collection('users').doc(_uid);

  // ── Transactions ──────────────────────────────────────────────────────────

  Future<void> pushTransaction(TransactionModel txn) async {
    if (_uid == null || !await _isOnline) return;
    try {
      await _userDoc.collection('transactions').doc(txn.txnId).set(txn.toMap());
    } catch (_) {}
  }

  Future<void> softDeleteTransaction(String txnId) async {
    if (_uid == null || !await _isOnline) return;
    try {
      await _userDoc
          .collection('transactions')
          .doc(txnId)
          .update({'isDeleted': true});
    } catch (_) {}
  }

  // ── Customers ─────────────────────────────────────────────────────────────

  Future<void> pushCustomer(CustomerModel customer) async {
    if (_uid == null || !await _isOnline) return;
    try {
      await _userDoc
          .collection('customers')
          .doc(customer.customerId)
          .set(customer.toMap());
    } catch (_) {}
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<void> saveProfile({
    required String shopName,
    required String locale,
  }) async {
    if (_uid == null || !await _isOnline) return;
    try {
      await _userDoc.set({
        'shopName': shopName,
        'locale': locale,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  // ── Pull & merge on login ─────────────────────────────────────────────────

  Future<void> pullAndMerge({
    required LocalTransactionDatasource txnDs,
    required LocalCustomerDatasource customerDs,
    required String shopId,
  }) async {
    if (_uid == null || !await _isOnline) return;
    try {
      // Pull transactions
      final txnSnap =
          await _userDoc.collection('transactions').get();
      for (final doc in txnSnap.docs) {
        final txn = TransactionModel.fromMap(doc.data());
        final existing = await txnDs.getById(txn.txnId);
        if (existing == null) await txnDs.save(txn);
      }

      // Pull customers
      final custSnap =
          await _userDoc.collection('customers').get();
      for (final doc in custSnap.docs) {
        final customer = CustomerModel.fromMap(doc.data());
        final existing =
            await customerDs.getByName(shopId, customer.name);
        if (existing == null) await customerDs.save(customer);
      }
    } catch (_) {}
  }
}