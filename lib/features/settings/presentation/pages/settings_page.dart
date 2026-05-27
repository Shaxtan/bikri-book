import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../auth/presentation/pages/phone_login_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final user = FirebaseAuth.instance.currentUser;
    final isAnonymous = user?.isAnonymous ?? true;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      backgroundColor: AppColors.background,
      body: ListView(
        children: [
          const SizedBox(height: 12),

          // ── Account ─────────────────────────────────────────────────────
          _SectionHeader(label: 'Account'),
          Container(
            color: AppColors.surface,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryPale,
                child: Text(
                  isAnonymous ? '?' : (user?.phoneNumber ?? 'U')[0],
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700),
                ),
              ),
              title: Text(
                isAnonymous
                    ? 'Guest Account'
                    : (user?.phoneNumber ?? 'Logged In'),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                isAnonymous
                    ? 'Data not backed up to cloud'
                    : 'Data syncing to cloud ✓',
                style: TextStyle(
                  color: isAnonymous
                      ? AppColors.credit
                      : AppColors.sale,
                  fontSize: 12,
                ),
              ),
              trailing: isAnonymous
                  ? const Icon(Icons.cloud_off, color: AppColors.credit)
                  : const Icon(Icons.cloud_done, color: AppColors.sale),
            ),
          ),
          const SizedBox(height: 24),

          // ── Language ─────────────────────────────────────────────────────
          _SectionHeader(label: 'Bhasha / Language'),
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                _LanguageTile(
                  flag: '🇮🇳',
                  name: 'हिन्दी',
                  subtitle: 'Hindi',
                  isSelected: settings.locale == 'hi',
                  onTap: () =>
                      ref.read(settingsProvider.notifier).setLocale('hi'),
                ),
                const Divider(height: 0.5, indent: 16),
                _LanguageTile(
                  flag: '🇬🇧',
                  name: 'English',
                  subtitle: 'English',
                  isSelected: settings.locale == 'en',
                  onTap: () =>
                      ref.read(settingsProvider.notifier).setLocale('en'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Shop ─────────────────────────────────────────────────────────
          _SectionHeader(label: 'Dukaan / Shop'),
          Container(
            color: AppColors.surface,
            child: ListTile(
              leading: const Icon(Icons.store_outlined,
                  color: AppColors.primary),
              title: const Text('Shop name'),
              subtitle: Text(settings.shopName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _editShopName(context, ref, settings.shopName),
            ),
          ),
          const SizedBox(height: 24),

          // ── About ─────────────────────────────────────────────────────────
          _SectionHeader(label: 'About'),
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline,
                      color: AppColors.textSecondary),
                  title: Text('Bikri-Book'),
                  subtitle: Text('Version 2.0.0 · Phase 2'),
                ),
                const Divider(height: 0.5, indent: 16),
                const ListTile(
                  leading: Icon(Icons.favorite_border,
                      color: AppColors.expense),
                  title:
                      Text('Made with ❤ for Indian shopkeepers'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Logout ───────────────────────────────────────────────────────
          _SectionHeader(label: 'Account Actions'),
          Container(
            color: AppColors.surface,
            child: ListTile(
              leading:
                  const Icon(Icons.logout, color: AppColors.expense),
              title: const Text('Sign Out',
                  style: TextStyle(color: AppColors.expense)),
              onTap: () => _confirmLogout(context, ref),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _editShopName(
      BuildContext context, WidgetRef ref, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dukaan ka naam'),
        content: TextField(
          controller: ctrl,
          decoration:
              const InputDecoration(hintText: 'e.g. Sharma Kirana'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                ref
                    .read(settingsProvider.notifier)
                    .setShopName(ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
            'Aap sign out ho jaoge. Local data safe rahega.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.instance.signOut();
              await PreferencesService.setShopId('default_shop');
              ref.read(settingsProvider.notifier).setShopId('default_shop');
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const PhoneLoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.flag,
    required this.name,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String flag, name, subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.circle_outlined, color: AppColors.border),
      onTap: onTap,
    );
  }
}