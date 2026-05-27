import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/local_customer_datasource.dart';
import '../../data/models/customer_model.dart';
import '../../../../core/providers.dart';

class CustomerState {
  const CustomerState({this.customers = const [], this.isLoading = false});
  final List<CustomerModel> customers;
  final bool isLoading;

  CustomerState copyWith({List<CustomerModel>? customers, bool? isLoading}) =>
      CustomerState(
        customers: customers ?? this.customers,
        isLoading: isLoading ?? this.isLoading,
      );
}

class CustomerNotifier extends StateNotifier<CustomerState> {
  CustomerNotifier(this._ds, this._shopId) : super(const CustomerState()) {
    _loadAll();
  }

  final LocalCustomerDatasource _ds;
  final String _shopId;

  Future<void> _loadAll() async {
    state = state.copyWith(isLoading: true);
    final customers = await _ds.getAll(_shopId);
    state = state.copyWith(customers: customers, isLoading: false);
  }

  Future<void> addCustomer({required String name, String? phone}) async {
    final existing = await _ds.getByName(_shopId, name);
    if (existing != null) return;
    final customer = CustomerModel(
      customerId: const Uuid().v4(),
      shopId: _shopId,
      name: name.trim(),
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      createdAt: DateTime.now(),
    );
    await _ds.save(customer);
    await _loadAll();
  }

  Future<void> deleteCustomer(String customerId) async {
    await _ds.delete(customerId);
    await _loadAll();
  }

  /// Called from Save sheet — creates customer silently if they don't exist
  Future<void> ensureCustomerExists(String name) async {
    if (name.trim().isEmpty) return;
    final existing = await _ds.getByName(_shopId, name.trim());
    if (existing == null) await addCustomer(name: name.trim());
  }
}

final customerProvider =
    StateNotifierProvider<CustomerNotifier, CustomerState>((ref) {
  final ds = ref.watch(localCustomerDsProvider);
  final settings = ref.watch(settingsProvider);
  return CustomerNotifier(ds, settings.shopId);
});