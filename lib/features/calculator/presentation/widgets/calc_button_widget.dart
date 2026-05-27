import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

enum CalcButtonStyle { number, function, operator, equals }

class CalcButton extends StatefulWidget {
  const CalcButton({
    super.key,
    required this.label,
    required this.onTap,
    this.style = CalcButtonStyle.number,
    this.flex = 1,
    this.fontSize,
  });

  final String label;
  final VoidCallback onTap;
  final CalcButtonStyle style;
  final int flex;
  final double? fontSize;

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 80),
    vsync: this,
  );
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.92)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  Color get _bg {
    switch (widget.style) {
      case CalcButtonStyle.number:
        return AppColors.calcButtonNum;
      case CalcButtonStyle.function:
        return AppColors.calcButtonFunc;
      case CalcButtonStyle.operator:
        return AppColors.calcButtonOp;
      case CalcButtonStyle.equals:
        return AppColors.calcButtonEq;
    }
  }

  Color get _fg {
    switch (widget.style) {
      case CalcButtonStyle.number:
      case CalcButtonStyle.function:
        return AppColors.calcNumText;
      case CalcButtonStyle.operator:
      case CalcButtonStyle.equals:
        return AppColors.calcOpText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(_) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: ScaleTransition(
            scale: _scale,
            child: widget.flex == 2
                ? _buildWideButton()
                : _buildCircleButton(),
          ),
        ),
      ),
    );
  }

  // Circle button for all normal buttons (1, 2, 3, +, etc.)
  Widget _buildCircleButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        return SizedBox(
          width: size,
          height: size,
          child: Container(
            decoration: BoxDecoration(
              color: _bg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: _label(),
          ),
        );
      },
    );
  }

  // Wide pill button for the zero button
  Widget _buildWideButton() {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 28),
      child: _label(),
    );
  }

  Widget _label() {
    return Text(
      widget.label,
      style: TextStyle(
        fontSize: widget.fontSize ?? 22,
        fontWeight: FontWeight.w400,
        color: _fg,
        height: 1,
      ),
    );
  }
}