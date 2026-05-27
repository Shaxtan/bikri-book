// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Bikri-Book';

  @override
  String get tagline => 'Your shop\'s accounts, in your palm.';

  @override
  String get tabCalculator => 'Calculator';

  @override
  String get tabRecords => 'Records';

  @override
  String get tabCustomers => 'Customers';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String saveBtnLabel(String amount) {
    return 'SAVE — ₹$amount';
  }

  @override
  String get saveSheetTitle => 'Save this record';

  @override
  String get saveSheetSubtitle => 'Total';

  @override
  String get fieldItemName => 'Item / product name *';

  @override
  String get fieldItemHint => 'e.g. Chawal 5kg, Soap, Biscuit...';

  @override
  String get fieldCustomer => 'Customer name (optional)';

  @override
  String get fieldCustomerHint => 'e.g. Ramesh, Geeta...';

  @override
  String get fieldNotes => 'Notes (optional)';

  @override
  String get fieldNotesHint => 'e.g. home delivery, paid by card...';

  @override
  String get typeSale => 'Sale';

  @override
  String get typeExpense => 'Expense';

  @override
  String get typeCredit => 'Credit';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnSaveRecord => 'Save Record';

  @override
  String get validationItemRequired => 'Please enter an item name';

  @override
  String recordsSavedSuccess(String amount, String todayTotal) {
    return '₹$amount saved! Today: ₹$todayTotal';
  }

  @override
  String get recordsPageTitle => 'Records';

  @override
  String get recordsEmpty => 'No records yet.\nMake a sale and tap Save!';

  @override
  String get recordsSearchHint => 'Search item or customer...';

  @override
  String get recordsExport => 'Export';

  @override
  String get sectionToday => 'Today';

  @override
  String get sectionYesterday => 'Yesterday';

  @override
  String get sectionThisWeek => 'This Week';

  @override
  String get sectionOlder => 'Older';

  @override
  String get totalLabel => 'Total';

  @override
  String get deletedRecord => 'Record deleted';

  @override
  String get undoDelete => 'Undo';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsFontSize => 'Text size';

  @override
  String get settingsAbout => 'About Bikri-Book';

  @override
  String get comingSoon => 'Coming soon!';

  @override
  String get placeholderScreen => 'This feature is coming in the next update.';

  @override
  String get errorDivByZero => 'Can\'t divide by zero';

  @override
  String get errorInvalidExpr => 'Invalid expression';
}
