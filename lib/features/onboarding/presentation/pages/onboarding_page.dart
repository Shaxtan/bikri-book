import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../home/presentation/pages/home_page.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  final _shopNameCtrl = TextEditingController();
  int _currentPage = 0;
  String _selectedLocale = 'en';
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _shopNameCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    if (_shopNameCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    await PreferencesService.setShopName(_shopNameCtrl.text.trim());
    await PreferencesService.setLocale(_selectedLocale);
    await PreferencesService.setOnboarded();
    await ref.read(settingsProvider.notifier).setShopName(_shopNameCtrl.text.trim());
    await ref.read(settingsProvider.notifier).setLocale(_selectedLocale);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _LanguagePage(
                    selected: _selectedLocale,
                    onSelect: (l) => setState(() => _selectedLocale = l),
                    onNext: _nextPage,
                  ),
                  _ShopNamePage(
                    controller: _shopNameCtrl,
                    onNext: _nextPage,
                  ),
                  _ReadyPage(isSaving: _isSaving, onStart: _finish),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page 1: Language ──────────────────────────────────────────────────────────

class _LanguagePage extends StatelessWidget {
  const _LanguagePage({
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('👋 Swagat hai!',
              style: GoogleFonts.notoSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
          const SizedBox(height: 8),
          Text('Apni bhasha chuniye\nSelect your language',
              style: GoogleFonts.notoSans(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.6)),
          const SizedBox(height: 48),
          _LangCard(
            flag: '🇮🇳',
            name: 'हिन्दी',
            subtitle: 'Hindi',
            isSelected: selected == 'hi',
            onTap: () => onSelect('hi'),
          ),
          const SizedBox(height: 16),
          _LangCard(
            flag: '🇬🇧',
            name: 'English',
            subtitle: 'English',
            isSelected: selected == 'en',
            onTap: () => onSelect('en'),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text('Next →'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LangCard extends StatelessWidget {
  const _LangCard({
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPale : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}

// ── Page 2: Shop Name ─────────────────────────────────────────────────────────

class _ShopNamePage extends StatelessWidget {
  const _ShopNamePage({required this.controller, required this.onNext});
  final TextEditingController controller;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text('🏪', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text('Aapki dukan ka naam?',
              style: GoogleFonts.notoSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Yeh naam aapki reports mein dikhega',
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textSecondary)),
          const SizedBox(height: 40),
          TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.notoSans(fontSize: 18),
            decoration: const InputDecoration(
              hintText: 'e.g. Sharma Kirana, Ram General Store...',
              prefixIcon: Icon(Icons.store_outlined),
            ),
            onSubmitted: (_) {
              if (controller.text.trim().isNotEmpty) onNext();
            },
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) onNext();
              },
              child: const Text('Next →'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 3: Ready ─────────────────────────────────────────────────────────────

class _ReadyPage extends StatelessWidget {
  const _ReadyPage({required this.isSaving, required this.onStart});
  final bool isSaving;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
                color: AppColors.primaryPale, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded,
                size: 60, color: AppColors.primary),
          ),
          const SizedBox(height: 32),
          Text('Bilkul Taiyyar! 🎉',
              style: GoogleFonts.notoSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
          const SizedBox(height: 16),
          Text(
            'Ab aap apni dukan ka hisaab\nek click mein rakh sakte hain.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.6),
          ),
          const SizedBox(height: 52),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isSaving ? null : onStart,
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Shuru Karen! 🚀'),
            ),
          ),
        ],
      ),
    );
  }
}