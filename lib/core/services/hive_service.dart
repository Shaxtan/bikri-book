import 'package:hive_flutter/hive_flutter.dart';

const _txnBox = 'transactions';
const _customerBox = 'customers';

class HiveService {
  HiveService._();
  static final HiveService instance = HiveService._();
  bool _isOpen = false;

  Future<void> init() async {
    if (_isOpen) return;
    await Hive.initFlutter();
    await Hive.openBox<Map>(_txnBox);
    await Hive.openBox<Map>(_customerBox);
    _isOpen = true;
  }

  Box<Map> get transactionsBox => Hive.box<Map>(_txnBox);
  Box<Map> get customersBox => Hive.box<Map>(_customerBox);
}