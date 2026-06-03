import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/calculator_provider.dart';
import '../widgets/calc_button_widget.dart';
import '../widgets/save_bottom_sheet.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';

class CalculatorPage extends ConsumerStatefulWidget {
  const CalculatorPage({super.key});

  @override
  ConsumerState<CalculatorPage> createState() =>
      _CalculatorPageState();
}

class _CalculatorPageState extends ConsumerState<CalculatorPage> {
  late final TextEditingController _exprCtrl;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _exprCtrl = TextEditingController();
    _exprCtrl.addListener(() {
      if (_syncing) return;
      final pos = _exprCtrl.selection.baseOffset;
      if (pos >= 0) {
        ref.read(calculatorProvider.notifier).setCursorPos(pos);
      }
    });
  }

  @override
  void dispose() {
    _exprCtrl.dispose();
    super.dispose();
  }

  void _sync(CalculatorState calc) {
    final text = calc.expression;
    final cursor = calc.cursorPos.clamp(0, text.length);
    if (_exprCtrl.text != text ||
        _exprCtrl.selection.baseOffset != cursor) {
      _syncing = true;
      _exprCtrl.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: cursor),
      );
      _syncing = false;
    }
  }

  Future<void> _handleSave(
      BuildContext context, CalculatorState calc) async {
    if (!calc.canSave) return;
    final saved =
        await SaveBottomSheet.show(context, calc.saveAmount);
    if (saved && context.mounted) {
      final newTotal =
          ref.read(transactionProvider).todayTotal;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '₹${CurrencyFormatter.formatCompact(calc.saveAmount)} saved! '
            'Aaj: ₹${CurrencyFormatter.formatCompact(newTotal)}',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final calc = ref.watch(calculatorProvider);
    final n = ref.read(calculatorProvider.notifier);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _sync(calc));

    return Column(
      children: [
        // ── Display (green area) ───────────────────────────────
        Expanded(
          flex: 38,
          child: _Display(
            calc: calc,
            exprCtrl: _exprCtrl,
            onSave: () => _handleSave(context, calc),
          ),
        ),

        // ── Keypad (white/grey area) ───────────────────────────
        Expanded(
          flex: 62,
          child: Container(
            color: AppColors.background,
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
            child: _Keypad(n: n),
          ),
        ),
      ],
    );
  }
}

// ── Display ───────────────────────────────────────────────────────────────────

class _Display extends StatelessWidget {
  const _Display({
    required this.calc,
    required this.exprCtrl,
    required this.onSave,
  });

  final CalculatorState calc;
  final TextEditingController exprCtrl;
  final VoidCallback onSave;

  double _resultSize(String val, bool big) {
    final len = val.length;
    if (big) {
      if (len <= 6) return 52;
      if (len <= 9) return 40;
      if (len <= 12) return 30;
      return 24;
    }
    if (len <= 8) return 30;
    if (len <= 12) return 24;
    return 20;
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = calc.liveResult.isNotEmpty;
    final isFinal = calc.justCalculated;

    return Container(
      color: AppColors.calcBackground,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Expression — full expression with cursor ─────────
          Expanded(
            child: TextField(
  controller: exprCtrl,
  readOnly: true,
  showCursor: true,
  enableInteractiveSelection: true,
  textAlign: TextAlign.right,
  maxLines: null,
  expands: true,
  style: GoogleFonts.robotoMono(
    color: isFinal
        ? Colors.white.withOpacity(0.6)
        : Colors.white,
    fontSize: 24,
    height: 1.4,
  ),
  decoration: InputDecoration(
    border: InputBorder.none,
    isDense: true,
    contentPadding: EdgeInsets.zero,
    filled: false,                        // ← ADD THIS LINE
    hintText: '0',
    hintStyle: GoogleFonts.robotoMono(
      color: Colors.white.withOpacity(0.35),
      fontSize: 24,
    ),
  ),
),
          ),

          // ── Live result / final answer ───────────────────────
          if (hasResult) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '= ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: isFinal ? 28 : 20,
                    fontFamily: 'RobotoMono',
                  ),
                ),
                Flexible(
                  child: Text(
                    calc.liveResult,
                    style: GoogleFonts.robotoMono(
                      color: isFinal
                          ? Colors.white
                          : Colors.white.withOpacity(0.65),
                      fontSize: _resultSize(
                          calc.liveResult, isFinal),
                      fontWeight: isFinal
                          ? FontWeight.w400
                          : FontWeight.w300,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),

          // ── Save button ─────────────────────────────────────
          AnimatedOpacity(
            opacity: calc.canSave ? 1.0 : 0.38,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: calc.canSave ? onSave : null,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: Text(
                  calc.canSave
                      ? 'SAVE KAR  —  ₹${CurrencyFormatter.formatCompact(calc.saveAmount)}'
                      : 'Calculate karo phir save karo',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.calcButtonEq,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Keypad ────────────────────────────────────────────────────────────────────

class _Keypad extends StatelessWidget {
  const _Keypad({required this.n});
  final CalculatorNotifier n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(children: [
            CalcButton(
                label: 'AC',
                style: CalcButtonStyle.function,
                onTap: n.pressAC,
                fontSize: 18),
            CalcButton(
                label: '⌫',
                style: CalcButtonStyle.function,
                onTap: n.pressBackspace,
                fontSize: 20),
            CalcButton(
                label: '%',
                style: CalcButtonStyle.function,
                onTap: n.pressPercent),
            CalcButton(
                label: '÷',
                style: CalcButtonStyle.operator,
                onTap: () => n.pressOperator('÷'),
                fontSize: 26),
          ]),
        ),
        Expanded(
          child: Row(children: [
            CalcButton(
                label: '7', onTap: () => n.pressDigit('7')),
            CalcButton(
                label: '8', onTap: () => n.pressDigit('8')),
            CalcButton(
                label: '9', onTap: () => n.pressDigit('9')),
            CalcButton(
                label: '×',
                style: CalcButtonStyle.operator,
                onTap: () => n.pressOperator('×'),
                fontSize: 26),
          ]),
        ),
        Expanded(
          child: Row(children: [
            CalcButton(
                label: '4', onTap: () => n.pressDigit('4')),
            CalcButton(
                label: '5', onTap: () => n.pressDigit('5')),
            CalcButton(
                label: '6', onTap: () => n.pressDigit('6')),
            CalcButton(
                label: '−',
                style: CalcButtonStyle.operator,
                onTap: () => n.pressOperator('−'),
                fontSize: 26),
          ]),
        ),
        Expanded(
          child: Row(children: [
            CalcButton(
                label: '1', onTap: () => n.pressDigit('1')),
            CalcButton(
                label: '2', onTap: () => n.pressDigit('2')),
            CalcButton(
                label: '3', onTap: () => n.pressDigit('3')),
            CalcButton(
                label: '+',
                style: CalcButtonStyle.operator,
                onTap: () => n.pressOperator('+'),
                fontSize: 26),
          ]),
        ),
        Expanded(
          child: Row(children: [
            CalcButton(
                label: '0',
                onTap: () => n.pressDigit('0'),
                flex: 2),
            CalcButton(label: '.', onTap: n.pressDecimal),
            CalcButton(
                label: '=',
                style: CalcButtonStyle.equals,
                onTap: n.pressEquals),
          ]),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}