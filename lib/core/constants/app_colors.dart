import 'package:flutter/material.dart';

/// Bikri-Book Design System — Dukaan Design System (DDS)
/// Primary: Deep Forest Green (trust, money, growth)
abstract final class AppColors {
  // ── Brand greens ────────────────────────────────────────────
  static const primary = Color(0xFF1A7F4B);
  static const primaryLight = Color(0xFF4CAF50);
  static const primaryPale = Color(0xFFE8F5E9);
  static const primaryDark = Color(0xFF0D5C34);

  // ── Semantic ─────────────────────────────────────────────────
  static const sale = Color(0xFF2E7D32);       // income / credit received
  static const expense = Color(0xFFD32F2F);    // outflow / debit
  static const credit = Color(0xFFFF8F00);     // credit given (udhaari)

  // ── Surface & background ─────────────────────────────────────
  static const background = Color(0xFFF5F7F5);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFEFF3EF);

  // ── Calculator specific ──────────────────────────────────────
  static const calcBackground = Color(0xFF1A7F4B);   // display bg
  static const calcButtonNum = Color(0xFFFFFFFF);    // number buttons
  static const calcButtonFunc = Color(0xFF9FB9A4);   // AC, ±, %
  static const calcButtonOp = Color(0xFF1A7F4B);     // ÷, ×, −, +
  static const calcButtonEq = Color(0xFF4CAF50);     // = button
  static const calcNumText = Color(0xFF1A1A1A);
  static const calcOpText = Color(0xFFFFFFFF);
  static const calcDisplay = Color(0xFFFFFFFF);
  static const calcExpression = Color(0x99FFFFFF);

  // ── Text ─────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF616161);
  static const textTertiary = Color(0xFF9E9E9E);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // ── Border ───────────────────────────────────────────────────
  static const border = Color(0xFFE0E0E0);
  static const divider = Color(0xFFF0F0F0);

  // ── Status chips ─────────────────────────────────────────────
  static const saleChipBg = Color(0xFFE8F5E9);
  static const expenseChipBg = Color(0xFFFCE8E6);
  static const creditChipBg = Color(0xFFFFF8E1);
}
