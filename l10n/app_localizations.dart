import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Bikri-Book'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your shop\'s accounts, in your palm.'**
  String get tagline;

  /// No description provided for @tabCalculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get tabCalculator;

  /// No description provided for @tabRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get tabRecords;

  /// No description provided for @tabCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get tabCustomers;

  /// No description provided for @tabDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get tabDashboard;

  /// No description provided for @saveBtnLabel.
  ///
  /// In en, this message translates to:
  /// **'SAVE — ₹{amount}'**
  String saveBtnLabel(String amount);

  /// No description provided for @saveSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Save this record'**
  String get saveSheetTitle;

  /// No description provided for @saveSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get saveSheetSubtitle;

  /// No description provided for @fieldItemName.
  ///
  /// In en, this message translates to:
  /// **'Item / product name *'**
  String get fieldItemName;

  /// No description provided for @fieldItemHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Chawal 5kg, Soap, Biscuit...'**
  String get fieldItemHint;

  /// No description provided for @fieldCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer name (optional)'**
  String get fieldCustomer;

  /// No description provided for @fieldCustomerHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ramesh, Geeta...'**
  String get fieldCustomerHint;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get fieldNotes;

  /// No description provided for @fieldNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. home delivery, paid by card...'**
  String get fieldNotesHint;

  /// No description provided for @typeSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get typeSale;

  /// No description provided for @typeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get typeExpense;

  /// No description provided for @typeCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get typeCredit;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnSaveRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Record'**
  String get btnSaveRecord;

  /// No description provided for @validationItemRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an item name'**
  String get validationItemRequired;

  /// No description provided for @recordsSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'₹{amount} saved! Today: ₹{todayTotal}'**
  String recordsSavedSuccess(String amount, String todayTotal);

  /// No description provided for @recordsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get recordsPageTitle;

  /// No description provided for @recordsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No records yet.\nMake a sale and tap Save!'**
  String get recordsEmpty;

  /// No description provided for @recordsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search item or customer...'**
  String get recordsSearchHint;

  /// No description provided for @recordsExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get recordsExport;

  /// No description provided for @sectionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get sectionToday;

  /// No description provided for @sectionYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get sectionYesterday;

  /// No description provided for @sectionThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get sectionThisWeek;

  /// No description provided for @sectionOlder.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get sectionOlder;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @deletedRecord.
  ///
  /// In en, this message translates to:
  /// **'Record deleted'**
  String get deletedRecord;

  /// No description provided for @undoDelete.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoDelete;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsFontSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get settingsFontSize;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Bikri-Book'**
  String get settingsAbout;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// No description provided for @placeholderScreen.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming in the next update.'**
  String get placeholderScreen;

  /// No description provided for @errorDivByZero.
  ///
  /// In en, this message translates to:
  /// **'Can\'t divide by zero'**
  String get errorDivByZero;

  /// No description provided for @errorInvalidExpr.
  ///
  /// In en, this message translates to:
  /// **'Invalid expression'**
  String get errorInvalidExpr;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
