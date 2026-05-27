import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_sync_service.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import '../../../transactions/data/datasources/local_transaction_datasource.dart';
import '../../../customers/data/datasources/local_customer_datasource.dart';
import 'otp_verify_page.dart';

class PhoneLoginPage extends ConsumerStatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  ConsumerState<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends ConsumerState<PhoneLoginPage> {
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;
  String _error = '';

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Called after any successful login ─────────────────────────────────────

  Future<void> _afterLogin(String uid) async {
    await PreferencesService.setShopId(uid);
    ref.read(settingsProvider.notifier).setShopId(uid);

    await ref
        .read(localTransactionDsProvider)
        .migrateShopId('default_shop', uid);
    await ref
        .read(localCustomerDsProvider)
        .migrateShopId('default_shop', uid);

    final isOnboarded = await PreferencesService.isOnboarded();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              isOnboarded ? const HomePage() : const OnboardingPage(),
        ),
        (route) => false,
      );
    }

    // Firestore sync in background — non-blocking
    final settings = ref.read(settingsProvider);
    FirestoreSyncService.instance.saveProfile(
      shopName: settings.shopName,
      locale: settings.locale,
    );
  }

  // ── Guest / Anonymous (Web) ───────────────────────────────────────────────

  Future<void> _continueAsGuest() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final result = await FirebaseAuth.instance
          .signInAnonymously()
          .timeout(const Duration(seconds: 10));

      final uid = result.user!.uid;

      // Local operations only — instant
      await PreferencesService.setShopId(uid);
      ref.read(settingsProvider.notifier).setShopId(uid);

      await ref
          .read(localTransactionDsProvider)
          .migrateShopId('default_shop', uid);
      await ref
          .read(localCustomerDsProvider)
          .migrateShopId('default_shop', uid);

      // Navigate immediately — don't wait for Firestore
      final isOnboarded = await PreferencesService.isOnboarded();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) =>
                isOnboarded ? const HomePage() : const OnboardingPage(),
          ),
          (route) => false,
        );
      }

      // Firestore in background — non-blocking
      final settings = ref.read(settingsProvider);
      FirestoreSyncService.instance.saveProfile(
        shopName: settings.shopName,
        locale: settings.locale,
      );
      FirestoreSyncService.instance.pullAndMerge(
        txnDs: ref.read(localTransactionDsProvider),
        customerDs: ref.read(localCustomerDsProvider),
        shopId: uid,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Could not connect. Please check internet and try again.';
        });
      }
    }
  }

  // ── Phone OTP (Mobile) ────────────────────────────────────────────────────

  Future<void> _sendOTP() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 10) {
      setState(() => _error = 'Please enter a valid phone number');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final fullPhone = '+91$phone';
    await AuthService.instance.sendOTP(
      phoneNumber: fullPhone,
      onCodeSent: (verificationId) {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerifyPage(
                verificationId: verificationId,
                phoneNumber: fullPhone,
                onVerified: _afterLogin,
              ),
            ),
          );
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = error;
          });
        }
      },
      onAutoVerified: (credential) async {
        await _afterLogin(credential.user!.uid);
      },
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  56,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.calculate,
                        color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Bikri-Book',
                    style: GoogleFonts.notoSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary),
                  ),
                  Text(
                    'Apni dukan ka hisaab, muthhi mein.',
                    style: GoogleFonts.notoSans(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5),
                  ),
                  const SizedBox(height: 48),

                  if (kIsWeb) ...[
                    // ── Web: Guest mode ─────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPale,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary, width: 0.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Phone OTP login works on the Android app. '
                              'On web, continue in Guest mode.',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(_error,
                          style: const TextStyle(
                              color: AppColors.expense, fontSize: 13)),
                    ],

                    const Spacer(),
                    const SizedBox(height: 48),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _continueAsGuest,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.arrow_forward),
                        label: Text(
                          _isLoading
                              ? 'Signing in...'
                              : 'Continue as Guest',
                        ),
                      ),
                    ),
                  ] else ...[
                    // ── Mobile: Phone OTP ────────────────────────────────
                    Text(
                      'Enter your mobile number',
                      style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.border, width: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.surfaceVariant,
                          ),
                          child: const Text('+91',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: const TextStyle(fontSize: 18),
                            decoration: const InputDecoration(
                              hintText: '98765 43210',
                              counterText: '',
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(_error,
                          style: const TextStyle(
                              color: AppColors.expense, fontSize: 13)),
                    ],
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendOTP,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Send OTP'),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}