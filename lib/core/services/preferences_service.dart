import 'package:shared_preferences/shared_preferences.dart';

abstract final class PreferencesService {
  static const _keyOnboarded = 'onboarded';
  static const _keyShopName = 'shop_name';
  static const _keyShopId = 'shop_id';
  static const _keyLocale = 'locale';

  static Future<bool> isOnboarded() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_keyOnboarded) ?? false;
  }

  static Future<void> setOnboarded() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_keyOnboarded, true);
  }

  static Future<String> getShopName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyShopName) ?? 'My Shop';
  }

  static Future<void> setShopName(String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyShopName, name);
  }

  static Future<String> getShopId() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyShopId) ?? 'default_shop';
  }

  static Future<void> setShopId(String id) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyShopId, id);
  }

  static Future<String> getLocale() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyLocale) ?? 'en';
  }

  static Future<void> setLocale(String locale) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyLocale, locale);
  }
}