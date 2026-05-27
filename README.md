# Bikri-Book — Phase 0

> *Har bikri, ek click mein.* — Every sale, in one click.

Bikri-Book replaces the traditional calculator + notebook system used in Indian kiranas and small businesses. Shopkeepers calculate on a familiar Android-style calculator, then save the result as a permanent record with one tap.

---

## Phase 0 Features

- ✅ Standard Android calculator layout (familiar to every shopkeeper)
- ✅ One-tap "Save Kar" button — instantly saves any calculation
- ✅ Item name, customer, type (sale/expense/credit), notes
- ✅ Date-grouped records list with search
- ✅ Swipe to delete with undo
- ✅ Today's total always visible in header
- ✅ Hindi + English UI
- ✅ 100% offline — Isar local database
- ✅ Riverpod state management
- ✅ Clean Architecture folder structure ready for scale

---

## Project Structure

```
lib/
├── core/
│   ├── constants/app_colors.dart       ← Bikri-Book colour palette
│   ├── theme/app_theme.dart            ← Material 3 theme
│   ├── utils/currency_formatter.dart   ← Indian ₹ formatting
│   └── providers.dart                  ← App-level Riverpod providers
│
├── features/
│   ├── calculator/
│   │   ├── domain/calculator_engine.dart            ← Pure Dart logic (tested)
│   │   ├── presentation/providers/calculator_provider.dart
│   │   ├── presentation/pages/calculator_page.dart
│   │   └── presentation/widgets/
│   │       ├── calc_button_widget.dart
│   │       ├── calc_display_widget.dart
│   │       └── save_bottom_sheet.dart
│   │
│   ├── transactions/
│   │   ├── data/
│   │   │   ├── models/transaction_model.dart        ← Isar collection
│   │   │   └── datasources/local_transaction_datasource.dart
│   │   └── presentation/
│   │       ├── providers/transaction_provider.dart
│   │       ├── pages/records_page.dart
│   │       └── widgets/transaction_tile.dart
│   │
│   ├── home/presentation/pages/home_page.dart       ← Bottom nav shell
│   └── settings/presentation/pages/settings_page.dart
│
├── l10n/
│   ├── app_en.arb                      ← English strings
│   └── app_hi.arb                      ← Hindi strings
│
└── main.dart                           ← Entry point
```

---

## Quick Start

### 1. Prerequisites
- Flutter SDK ≥ 3.16.0 (`flutter --version`)
- Android Studio or VS Code with Flutter extension
- An Android device or emulator (API 21+)

### 2. Clone & Install

```bash
# Create a new Flutter project with this name first:
flutter create bikri_book
cd bikri_book

# Replace the generated files with the Bikri-Book source files,
# then run:
flutter pub get
```

### 3. Generate Isar code (REQUIRED)

Isar uses code generation. Run this once, and again whenever you change `transaction_model.dart`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates `lib/features/transactions/data/models/transaction_model.g.dart`.

### 4. Run

```bash
flutter run
```

For a release build:

```bash
flutter build apk --release
```

---

## Running Tests

The `CalculatorEngine` has full unit test coverage:

```bash
flutter test test/calculator_engine_test.dart
```

---

## Architecture Decisions

| Decision | Choice | Why |
|---|---|---|
| State management | Riverpod 2 StateNotifier | Scalable, testable, no boilerplate |
| Local DB | Isar 3 | Fastest Flutter DB, offline-first |
| Navigation | BottomNavigationBar (Phase 0) | Simple; go_router ready for Phase 1 |
| Fonts | Google Fonts — Noto Sans + Roboto Mono | Hindi support + calculator feel |
| Architecture | Feature-first Clean Architecture | Scales to millions without refactor |

---

## Key Design Rules

1. **Never change the calculator layout.** It is the trust anchor.
2. **Save must work in < 3 seconds.** Item name is the only required field.
3. **Offline first.** App must work with zero connectivity. Sync is bonus.
4. **Hindi-first copy.** Button says "SAVE KAR", not just "SAVE".
5. **Big touch targets.** All buttons are minimum 56dp for older users.

---

## Phase 1 Roadmap (next)

- [ ] Firebase Auth (phone OTP)
- [ ] Firestore background sync
- [ ] Onboarding flow (language → OTP → shop name → demo)
- [ ] Customer Khata tab
- [ ] PDF daily report + WhatsApp share
- [ ] Google Play Store internal testing track

---

## Color Palette

| Name | Hex | Usage |
|---|---|---|
| Primary | `#1A7F4B` | App bar, buttons, accents |
| Primary Light | `#4CAF50` | = button, success states |
| Primary Pale | `#E8F5E9` | Backgrounds, chips |
| Sale Green | `#2E7D32` | Sale amounts |
| Expense Red | `#D32F2F` | Expense amounts |
| Credit Amber | `#FF8F00` | Credit / udhaari |

---

*Bikri-Book — Modernizing India's 63 million small businesses, one calculation at a time.*
