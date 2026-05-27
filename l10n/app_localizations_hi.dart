// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'बिक्री-बुक';

  @override
  String get tagline => 'दुकान का हिसाब, मुठ्ठी में।';

  @override
  String get tabCalculator => 'कैलकुलेटर';

  @override
  String get tabRecords => 'रिकॉर्ड';

  @override
  String get tabCustomers => 'कस्टमर';

  @override
  String get tabDashboard => 'डैशबोर्ड';

  @override
  String saveBtnLabel(String amount) {
    return 'SAVE KAR — ₹$amount';
  }

  @override
  String get saveSheetTitle => 'रिकॉर्ड सेव करो';

  @override
  String get saveSheetSubtitle => 'कुल';

  @override
  String get fieldItemName => 'चीज़ / सामान का नाम *';

  @override
  String get fieldItemHint => 'जैसे चावल 5kg, साबुन, बिस्किट...';

  @override
  String get fieldCustomer => 'ग्राहक का नाम (ज़रूरी नहीं)';

  @override
  String get fieldCustomerHint => 'जैसे रमेश, गीता...';

  @override
  String get fieldNotes => 'नोट (ज़रूरी नहीं)';

  @override
  String get fieldNotesHint => 'जैसे होम डिलीवरी, कार्ड से पेमेंट...';

  @override
  String get typeSale => 'बिक्री';

  @override
  String get typeExpense => 'खर्चा';

  @override
  String get typeCredit => 'उधारी';

  @override
  String get btnCancel => 'रद्द करो';

  @override
  String get btnSaveRecord => 'सेव करो';

  @override
  String get validationItemRequired => 'सामान का नाम डालें';

  @override
  String recordsSavedSuccess(String amount, String todayTotal) {
    return '₹$amount सेव हुए! आज: ₹$todayTotal';
  }

  @override
  String get recordsPageTitle => 'रिकॉर्ड';

  @override
  String get recordsEmpty => 'अभी कोई रिकॉर्ड नहीं।\nबिक्री करो और Save दबाओ!';

  @override
  String get recordsSearchHint => 'सामान या ग्राहक खोजो...';

  @override
  String get recordsExport => 'एक्सपोर्ट';

  @override
  String get sectionToday => 'आज';

  @override
  String get sectionYesterday => 'कल';

  @override
  String get sectionThisWeek => 'इस हफ्ते';

  @override
  String get sectionOlder => 'पहले का';

  @override
  String get totalLabel => 'कुल';

  @override
  String get deletedRecord => 'रिकॉर्ड डिलीट हुआ';

  @override
  String get undoDelete => 'वापस लाओ';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsFontSize => 'टेक्स्ट साइज़';

  @override
  String get settingsAbout => 'बिक्री-बुक के बारे में';

  @override
  String get comingSoon => 'जल्द आ रहा है!';

  @override
  String get placeholderScreen => 'यह फीचर अगले अपडेट में आएगा।';

  @override
  String get errorDivByZero => 'शून्य से भाग नहीं होता';

  @override
  String get errorInvalidExpr => 'गलत हिसाब';
}
