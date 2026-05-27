import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/services/hive_service.dart';
import '../models/customer_model.dart';

class LocalCustomerDatasource {
  Box<Map> get _box => HiveService.instance.customersBox;

  Future<void> save(CustomerModel customer) async {
    await _box.put(customer.customerId, customer.toMap());
  }

  Future<void> delete(String customerId) async {
    await _box.delete(customerId);
  }

  Future<List<CustomerModel>> getAll(String shopId) async {
    final list = _box.values
        .map((m) => CustomerModel.fromMap(m))
        .where((c) => c.shopId == shopId)
        .toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  Future<CustomerModel?> getByName(String shopId, String name) async {
    final all = await getAll(shopId);
    try {
      return all.firstWhere(
          (c) => c.name.toLowerCase() == name.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  /// Migrates all customers from oldShopId to newShopId
  Future<void> migrateShopId(String oldShopId, String newShopId) async {
    if (oldShopId == newShopId) return;
    final toMigrate = _box.values
        .map((m) => CustomerModel.fromMap(m))
        .where((c) => c.shopId == oldShopId)
        .toList();
    for (final customer in toMigrate) {
      final migrated = CustomerModel(
        customerId: customer.customerId,
        shopId: newShopId,
        name: customer.name,
        phone: customer.phone,
        createdAt: customer.createdAt,
      );
      await _box.put(customer.customerId, migrated.toMap());
    }
  }
}