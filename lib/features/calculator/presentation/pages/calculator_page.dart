import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/calculator_provider.dart';
import '../widgets/calc_button_widget.dart';
import '../widgets/calc_display_widget.dart';
import '../widgets/save_bottom_sheet.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';

class CalculatorPage extends ConsumerWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calc = ref.watch(calculatorProvider);
    final todayTotal =
        ref.watch(transactionProvider.select((s) => s.todayTotal));

    return Scaffold(
      backgroundColor: AppColors.calcBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar area (inside green) ──────────────────
            _AppBarArea(todayTotal: todayTotal),

            // ── Calculator display ───────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: CalcDisplayWidget(
                expression: calc.expressionDisplay,
                displayValue: calc.displayValue,
              ),
            ),

            // ── Button grid (white background below) ─────────
            Expanded(
              child: Container(
                color: AppColors.background,
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
                child: _ButtonGrid(calc: calc, ref: ref),
              ),
            ),

            // ── Save bar ──────────────────────────────────────
            _SaveBar(calc: calc, ref: ref),
          ],
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _AppBarArea extends StatelessWidget {
  const _AppBarArea({required this.todayTotal});
  final double todayTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.calcBackground,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bikri-Book',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Aaj ki Bikri: ${CurrencyFormatter.format(todayTotal)}',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Sync indicator — Phase 2
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Offline',
              style: GoogleFonts.notoSans(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Button grid ───────────────────────────────────────────────────────────────

class _ButtonGrid extends StatelessWidget {
  const _ButtonGrid({required this.calc, required this.ref});
  final CalculatorState calc;
  final WidgetRef ref;

  void _press(VoidCallback fn) => fn();

  CalculatorNotifier get _n => ref.read(calculatorProvider.notifier);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: AC  ±  %  ÷
        Expanded(
          child: Row(children: [
            CalcButton(
              label: 'AC',
              style: CalcButtonStyle.function,
              onTap: () => _n.pressAC(),
              fontSize: 20,
            ),
            CalcButton(
              label: '±',
              style: CalcButtonStyle.function,
              onTap: () => _n.pressToggleSign(),
            ),
            CalcButton(
              label: '%',
              style: CalcButtonStyle.function,
              onTap: () => _n.pressPercent(),
            ),
            CalcButton(
              label: '÷',
              style: CalcButtonStyle.operator,
              onTap: () => _n.pressOperator('÷'),
              fontSize: 26,
            ),
          ]),
        ),
        // Row 2: 7  8  9  ×
        Expanded(
          child: Row(children: [
            CalcButton(label: '7', onTap: () => _n.pressDigit('7')),
            CalcButton(label: '8', onTap: () => _n.pressDigit('8')),
            CalcButton(label: '9', onTap: () => _n.pressDigit('9')),
            CalcButton(
              label: '×',
              style: CalcButtonStyle.operator,
              onTap: () => _n.pressOperator('×'),
              fontSize: 26,
            ),
          ]),
        ),
        // Row 3: 4  5  6  −
        Expanded(
          child: Row(children: [
            CalcButton(label: '4', onTap: () => _n.pressDigit('4')),
            CalcButton(label: '5', onTap: () => _n.pressDigit('5')),
            CalcButton(label: '6', onTap: () => _n.pressDigit('6')),
            CalcButton(
              label: '−',
              style: CalcButtonStyle.operator,
              onTap: () => _n.pressOperator('−'),
              fontSize: 26,
            ),
          ]),
        ),
        // Row 4: 1  2  3  +
        Expanded(
          child: Row(children: [
            CalcButton(label: '1', onTap: () => _n.pressDigit('1')),
            CalcButton(label: '2', onTap: () => _n.pressDigit('2')),
            CalcButton(label: '3', onTap: () => _n.pressDigit('3')),
            CalcButton(
              label: '+',
              style: CalcButtonStyle.operator,
              onTap: () => _n.pressOperator('+'),
              fontSize: 26,
            ),
          ]),
        ),
        // Row 5: 0(wide)  .  =
        Expanded(
          child: Row(children: [
            CalcButton(
              label: '0',
              onTap: () => _n.pressDigit('0'),
              flex: 2,
            ),
            CalcButton(label: '.', onTap: () => _n.pressDecimal()),
            CalcButton(
              label: '=',
              style: CalcButtonStyle.equals,
              onTap: () => _n.pressEquals(),
            ),
          ]),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ── Save bar ──────────────────────────────────────────────────────────────────

class _SaveBar extends ConsumerWidget {
  const _SaveBar({required this.calc, required this.ref});
  final CalculatorState calc;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSave = calc.canSave;
    final todayTotal =
        ref.watch(transactionProvider.select((s) => s.todayTotal));

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: AnimatedOpacity(
            opacity: canSave ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton.icon(
              onPressed: canSave
                  ? () async {
                      final amount = calc.saveAmount;
                      final saved =
                          await SaveBottomSheet.show(context, amount);
                      if (saved && context.mounted) {
                        // Refresh today total is handled by the provider
                        final newTotal = ref.read(transactionProvider).todayTotal;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '₹${CurrencyFormatter.formatCompact(amount)} saved! '
                              'Aaj: ₹${CurrencyFormatter.formatCompact(newTotal)}',
                            ),
                            action: SnackBarAction(
                              label: 'Records',
                              onPressed: () {
                                // Navigate to records tab — handled by home page
                                DefaultTabController.maybeOf(context)
                                    ?.animateTo(1);
                              },
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  : null,
              icon: const Icon(Icons.save_outlined, size: 20),
              label: Text(
                canSave
                    ? 'SAVE KAR  —  ₹${CurrencyFormatter.formatCompact(calc.saveAmount)}'
                    : 'Calculate something first',
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
