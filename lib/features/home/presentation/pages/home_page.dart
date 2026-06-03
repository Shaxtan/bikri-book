import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../calculator/presentation/pages/calculator_page.dart';
import '../../../transactions/presentation/pages/records_page.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../customers/presentation/pages/customers_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _pageController;
  bool _pageChanging = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pageController = PageController();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging && !_pageChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayTotal =
        ref.watch(transactionProvider.select((s) => s.todayTotal));
    final settings = ref.watch(settingsProvider);
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = user?.isAnonymous ?? true;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [

            // ── Row 1: App heading + today total + sync ─────────
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // App name
                  Text(
                    'Bikri-Book',
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Today total
                  Expanded(
                    child: Text(
                      'Aaj: ${CurrencyFormatter.format(todayTotal)}',
                      style: GoogleFonts.notoSans(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  // Sync status
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isGuest ? Icons.cloud_off : Icons.cloud_done,
                          color: Colors.white,
                          size: 11,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isGuest ? 'Guest' : 'Synced',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Row 2: Page navigation tabs ─────────────────────
            Container(
              color: AppColors.primary,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.calculate_outlined, size: 20),
                    text: 'Calc',
                    iconMargin: EdgeInsets.only(bottom: 2),
                    height: 50,
                  ),
                  Tab(
                    icon: Icon(Icons.receipt_long_outlined, size: 20),
                    text: 'Records',
                    iconMargin: EdgeInsets.only(bottom: 2),
                    height: 50,
                  ),
                  Tab(
                    icon: Icon(Icons.people_outline, size: 20),
                    text: 'Customers',
                    iconMargin: EdgeInsets.only(bottom: 2),
                    height: 50,
                  ),
                  Tab(
                    icon: Icon(Icons.bar_chart_outlined, size: 20),
                    text: 'Dashboard',
                    iconMargin: EdgeInsets.only(bottom: 2),
                    height: 50,
                  ),
                ],
              ),
            ),

            // ── Row 3: Swipeable page content ────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  _pageChanging = true;
                  _tabController.animateTo(index);
                  Future.delayed(
                    const Duration(milliseconds: 350),
                    () => _pageChanging = false,
                  );
                },
                children: const [
                  CalculatorPage(),
                  RecordsPage(),
                  CustomersPage(),
                  DashboardPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}