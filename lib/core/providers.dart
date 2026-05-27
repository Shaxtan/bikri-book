import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/transactions/data/datasources/local_transaction_datasource.dart';
import '../features/customers/data/datasources/local_customer_datasource.dart';
import 'services/preferences_service.dart';
import 'services/firestore_sync_service.dart';

// ── Datasource providers ──────────────────────────────────────────────────────

final localTransactionDsProvider =
    Provider<LocalTransactionDatasource>((_) => LocalTransactionDatasource());

final localCustomerDsProvider =
    Provider<LocalCustomerDatasource>((_) => LocalCustomerDatasource());

final syncServiceProvider =
    Provider<FirestoreSyncService>((_) => FirestoreSyncService.instance);

// ── Settings ──────────────────────────────────────────────────────────────────

class SettingsState {
  const SettingsState({
    this.locale = 'en',
    this.shopId = 'default_shop',
    this.shopName = 'My Shop',
  });

  final String locale;
  final String shopId;
  final String shopName;

  SettingsState copyWith(
      {String? locale, String? shopId, String? shopName}) {
    return SettingsState(
      locale: locale ?? this.locale,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(SettingsState initial) : super(initial);

  Future<void> setLocale(String locale) async {
    await PreferencesService.setLocale(locale);
    state = state.copyWith(locale: locale);
  }

  Future<void> setShopName(String name) async {
    await PreferencesService.setShopName(name);
    state = state.copyWith(shopName: name);
  }

  Future<void> setShopId(String id) async {
    await PreferencesService.setShopId(id);
    state = state.copyWith(shopId: id);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
        (_) => SettingsNotifier(const SettingsState()));