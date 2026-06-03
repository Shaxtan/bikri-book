import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../auth/presentation/pages/phone_login_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _shopNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _shopAddressCtrl = TextEditingController();
  final _gstinCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();

  String _selectedCategory = 'Kirana / Grocery';
  bool _isSaving = false;
  bool _isLoading = true;

  static const _categories = [
    'Kirana / Grocery',
    'Cloth / Textile',
    'Electronics',
    'Hardware / Electrical',
    'Medical / Pharmacy',
    'Vegetables / Fruits',
    'Restaurant / Dabba',
    'Wholesale / Distributor',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = ref.read(settingsProvider);
    setState(() {
      _shopNameCtrl.text = settings.shopName;
      _ownerNameCtrl.text = prefs.getString('owner_name') ?? '';
      _shopAddressCtrl.text = prefs.getString('shop_address') ?? '';
      _gstinCtrl.text = prefs.getString('gstin') ?? '';
      _upiCtrl.text = prefs.getString('upi_id') ?? '';
      _selectedCategory =
          prefs.getString('shop_category') ?? 'Kirana / Grocery';
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('owner_name', _ownerNameCtrl.text.trim());
    await prefs.setString(
        'shop_address', _shopAddressCtrl.text.trim());
    await prefs.setString('gstin', _gstinCtrl.text.trim());
    await prefs.setString('upi_id', _upiCtrl.text.trim());
    await prefs.setString('shop_category', _selectedCategory);

    await ref
        .read(settingsProvider.notifier)
        .setShopName(_shopNameCtrl.text.trim());

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully! ✓'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _shopAddressCtrl.dispose();
    _gstinCtrl.dispose();
    _upiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = user?.isAnonymous ?? true;
    final settings = ref.watch(settingsProvider);
    final initials = _shopNameCtrl.text.isNotEmpty
        ? _shopNameCtrl.text[0].toUpperCase()
        : 'B';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: Text(
              _isSaving ? 'Saving...' : 'Save',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  // ── Profile header ────────────────────────────
                  _ProfileHeader(
                    initials: initials,
                    shopName: settings.shopName,
                    isGuest: isGuest,
                    phone: user?.phoneNumber,
                  ),

                  const SizedBox(height: 16),

                  // ── Shop Information ──────────────────────────
                  _SectionHeader(label: 'Shop Information'),
                  _Card(
                    children: [
                      _Field(
                        controller: _shopNameCtrl,
                        label: 'Shop Name *',
                        hint: 'e.g. Sharma Kirana Store',
                        icon: Icons.store_outlined,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Shop name is required'
                            : null,
                      ),
                      const Divider(height: 0.5),
                      _Field(
                        controller: _ownerNameCtrl,
                        label: 'Owner Name',
                        hint: 'e.g. Ramesh Sharma',
                        icon: Icons.person_outline,
                      ),
                      const Divider(height: 0.5),
                      _CategoryDropdown(
                        value: _selectedCategory,
                        categories: _categories,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCategory = val);
                          }
                        },
                      ),
                      const Divider(height: 0.5),
                      _Field(
                        controller: _shopAddressCtrl,
                        label: 'Shop Address',
                        hint: 'e.g. Shop No. 5, Main Market, Pune',
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Business Details ──────────────────────────
                  _SectionHeader(label: 'Business Details (Optional)'),
                  _Card(
                    children: [
                      _Field(
                        controller: _gstinCtrl,
                        label: 'GSTIN',
                        hint: 'e.g. 27AAAAA0000A1Z5',
                        icon: Icons.receipt_outlined,
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const Divider(height: 0.5),
                      _Field(
                        controller: _upiCtrl,
                        label: 'UPI ID',
                        hint: 'e.g. ramesh@upi',
                        icon: Icons.payment_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Account & Preferences ─────────────────────
                  _SectionHeader(label: 'Account & Preferences'),
                  _Card(
                    children: [
                      // Language
                      ListTile(
                        leading: const Icon(Icons.language,
                            color: AppColors.primary),
                        title: const Text('Language'),
                        subtitle: Text(
                          settings.locale == 'hi'
                              ? 'हिन्दी'
                              : 'English',
                        ),
                        trailing: const Icon(Icons.chevron_right,
                            color: AppColors.textTertiary),
                        onTap: () => _showLanguagePicker(context),
                      ),
                      const Divider(height: 0.5, indent: 56),

                      // Account type
                      ListTile(
                        leading: Icon(
                          isGuest
                              ? Icons.cloud_off
                              : Icons.cloud_done,
                          color: isGuest
                              ? AppColors.credit
                              : AppColors.primary,
                        ),
                        title: const Text('Account Type'),
                        subtitle: Text(
                          isGuest
                              ? 'Guest — data on this device only'
                              : 'Phone Login — data synced to cloud',
                          style: TextStyle(
                            color: isGuest
                                ? AppColors.credit
                                : AppColors.sale,
                          ),
                        ),
                      ),

                      if (!isGuest) ...[
                        const Divider(height: 0.5, indent: 56),
                        ListTile(
                          leading: const Icon(Icons.phone_outlined,
                              color: AppColors.primary),
                          title: const Text('Phone Number'),
                          subtitle: Text(
                              user?.phoneNumber ?? 'Not available'),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Stats ─────────────────────────────────────
                  _SectionHeader(label: 'App Statistics'),
                  _StatsCard(),

                  const SizedBox(height: 16),

                  // ── Danger zone ───────────────────────────────
                  _SectionHeader(label: 'Account Actions'),
                  _Card(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.logout,
                            color: AppColors.expense),
                        title: const Text(
                          'Sign Out',
                          style:
                              TextStyle(color: AppColors.expense),
                        ),
                        subtitle: const Text(
                            'Local data will remain on device'),
                        onTap: () => _confirmLogout(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Language',
                style: GoogleFonts.notoSans(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _LangTile(
              flag: '🇮🇳',
              name: 'हिन्दी',
              subtitle: 'Hindi',
              selected:
                  ref.read(settingsProvider).locale == 'hi',
              onTap: () {
                ref
                    .read(settingsProvider.notifier)
                    .setLocale('hi');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _LangTile(
              flag: '🇬🇧',
              name: 'English',
              subtitle: 'English',
              selected:
                  ref.read(settingsProvider).locale == 'en',
              onTap: () {
                ref
                    .read(settingsProvider.notifier)
                    .setLocale('en');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
            'Aap sign out ho jaoge. Local data safe rahega.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.instance.signOut();
              await PreferencesService.setShopId('default_shop');
              ref
                  .read(settingsProvider.notifier)
                  .setShopId('default_shop');
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

// ── Profile header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initials,
    required this.shopName,
    required this.isGuest,
    this.phone,
  });

  final String initials;
  final String shopName;
  final bool isGuest;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.5), width: 3),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.notoSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Shop name
          Text(
            shopName,
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),

          // Account type badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isGuest ? Icons.cloud_off : Icons.verified_user,
                  color: Colors.white,
                  size: 13,
                ),
                const SizedBox(width: 5),
                Text(
                  isGuest
                      ? 'Guest Account'
                      : phone ?? 'Phone Account',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats card ────────────────────────────────────────────────────────────────

class _StatsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Card(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _StatItem(
                label: 'App Version',
                value: '2.0.0',
                icon: Icons.info_outline,
              ),
              const VerticalDivider(width: 1),
              _StatItem(
                label: 'Phase',
                value: 'Phase 2',
                icon: Icons.rocket_launch_outlined,
              ),
              const VerticalDivider(width: 1),
              _StatItem(
                label: 'Platform',
                value: 'Flutter',
                icon: Icons.flutter_dash,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.textPrimary)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

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
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(children: children),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.words,
  });

  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.value,
    required this.categories,
    required this.onChanged,
  });

  final String value;
  final List<String> categories;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.category_outlined,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: const InputDecoration(
                labelText: 'Shop Category',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              items: categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c,
                            style: const TextStyle(fontSize: 14)),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  const _LangTile({
    required this.flag,
    required this.name,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String flag, name, subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.primaryPale : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary)),
              ],
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle,
                  color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}