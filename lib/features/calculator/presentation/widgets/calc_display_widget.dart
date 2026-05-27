import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class CalcDisplayWidget extends StatelessWidget {
  const CalcDisplayWidget({
    super.key,
    required this.expression,
    required this.displayValue,
  });

  final String expression;
  final String displayValue;

  /// Scales the font down if the number is too long to fit.
  double _fontSize(String val) {
    if (val.length <= 6) return 64;
    if (val.length <= 9) return 52;
    if (val.length <= 12) return 40;
    return 30;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.calcBackground,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Expression line (small, above)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Text(
              expression,
              key: ValueKey(expression),
              style: GoogleFonts.robotoMono(
                fontSize: 16,
                color: AppColors.calcExpression,
                height: 1.3,
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          // Main display (large number)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            transitionBuilder: (child, anim) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Text(
              displayValue,
              key: ValueKey(displayValue),
              style: GoogleFonts.robotoMono(
                fontSize: _fontSize(displayValue),
                fontWeight: FontWeight.w300,
                color: AppColors.calcDisplay,
                height: 1,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
