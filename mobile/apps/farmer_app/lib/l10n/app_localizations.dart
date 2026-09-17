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

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get commonUpdate;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get commonFilter;

  /// No description provided for @commonSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get commonSort;

  /// No description provided for @commonExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get commonExport;

  /// No description provided for @commonImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get commonImport;

  /// No description provided for @commonPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get commonPrint;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get commonWarning;

  /// No description provided for @commonInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get commonInfo;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// No description provided for @commonOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get commonOptional;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// No description provided for @commonSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get commonSelect;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get commonActions;

  /// No description provided for @commonStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get commonStatus;

  /// No description provided for @commonName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get commonName;

  /// No description provided for @commonDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get commonDescription;

  /// No description provided for @commonDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get commonDate;

  /// No description provided for @commonAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get commonAmount;

  /// No description provided for @commonTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get commonTotal;

  /// No description provided for @commonNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get commonNotes;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationMinLength.
  ///
  /// In en, this message translates to:
  /// **'Minimum {min} characters required'**
  String validationMinLength(int min);

  /// No description provided for @validationMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Maximum {max} characters allowed'**
  String validationMaxLength(int max);

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validationEmail;

  /// No description provided for @validationPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get validationPhone;

  /// No description provided for @validationNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get validationNumber;

  /// No description provided for @validationMin.
  ///
  /// In en, this message translates to:
  /// **'Value must be at least {min}'**
  String validationMin(String min);

  /// No description provided for @validationMax.
  ///
  /// In en, this message translates to:
  /// **'Value must be at most {max}'**
  String validationMax(String max);

  /// No description provided for @validationPattern.
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get validationPattern;

  /// No description provided for @validationUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL'**
  String get validationUrl;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get authLogout;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOut;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String authWelcome(String name);

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get navHelp;

  /// No description provided for @agricultureCrop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get agricultureCrop;

  /// No description provided for @agricultureFarm.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get agricultureFarm;

  /// No description provided for @agricultureHarvest.
  ///
  /// In en, this message translates to:
  /// **'Harvest'**
  String get agricultureHarvest;

  /// No description provided for @agricultureSeason.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get agricultureSeason;

  /// No description provided for @agricultureField.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get agricultureField;

  /// No description provided for @agricultureYield.
  ///
  /// In en, this message translates to:
  /// **'Yield'**
  String get agricultureYield;

  /// No description provided for @agricultureIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Irrigation'**
  String get agricultureIrrigation;

  /// No description provided for @agricultureFertilizer.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer'**
  String get agricultureFertilizer;

  /// No description provided for @agriculturePesticide.
  ///
  /// In en, this message translates to:
  /// **'Pesticide'**
  String get agriculturePesticide;

  /// No description provided for @agricultureEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get agricultureEquipment;

  /// No description provided for @manufacturingProduction.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get manufacturingProduction;

  /// No description provided for @manufacturingWorkOrder.
  ///
  /// In en, this message translates to:
  /// **'Work Order'**
  String get manufacturingWorkOrder;

  /// No description provided for @manufacturingBom.
  ///
  /// In en, this message translates to:
  /// **'Bill of Materials'**
  String get manufacturingBom;

  /// No description provided for @manufacturingInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get manufacturingInventory;

  /// No description provided for @manufacturingQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get manufacturingQuality;

  /// No description provided for @manufacturingMachine.
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get manufacturingMachine;

  /// No description provided for @manufacturingShift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get manufacturingShift;

  /// No description provided for @manufacturingOperator.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get manufacturingOperator;

  /// No description provided for @manufacturingDefect.
  ///
  /// In en, this message translates to:
  /// **'Defect'**
  String get manufacturingDefect;

  /// No description provided for @manufacturingBatch.
  ///
  /// In en, this message translates to:
  /// **'Batch'**
  String get manufacturingBatch;

  /// No description provided for @waterSupply.
  ///
  /// In en, this message translates to:
  /// **'Water Supply'**
  String get waterSupply;

  /// No description provided for @waterTreatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get waterTreatment;

  /// No description provided for @waterDistribution.
  ///
  /// In en, this message translates to:
  /// **'Distribution'**
  String get waterDistribution;

  /// No description provided for @waterMeter.
  ///
  /// In en, this message translates to:
  /// **'Meter'**
  String get waterMeter;

  /// No description provided for @waterConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get waterConnection;

  /// No description provided for @waterBill.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get waterBill;

  /// No description provided for @waterConsumption.
  ///
  /// In en, this message translates to:
  /// **'Consumption'**
  String get waterConsumption;

  /// No description provided for @waterPipeline.
  ///
  /// In en, this message translates to:
  /// **'Pipeline'**
  String get waterPipeline;

  /// No description provided for @waterPump.
  ///
  /// In en, this message translates to:
  /// **'Pump'**
  String get waterPump;

  /// No description provided for @waterReservoir.
  ///
  /// In en, this message translates to:
  /// **'Reservoir'**
  String get waterReservoir;

  /// No description provided for @constructionProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get constructionProject;

  /// No description provided for @constructionSite.
  ///
  /// In en, this message translates to:
  /// **'Site'**
  String get constructionSite;

  /// No description provided for @constructionContractor.
  ///
  /// In en, this message translates to:
  /// **'Contractor'**
  String get constructionContractor;

  /// No description provided for @constructionMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get constructionMaterial;

  /// No description provided for @constructionLabour.
  ///
  /// In en, this message translates to:
  /// **'Labour'**
  String get constructionLabour;

  /// No description provided for @constructionDrawing.
  ///
  /// In en, this message translates to:
  /// **'Drawing'**
  String get constructionDrawing;

  /// No description provided for @constructionInspection.
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get constructionInspection;

  /// No description provided for @constructionMilestone.
  ///
  /// In en, this message translates to:
  /// **'Milestone'**
  String get constructionMilestone;

  /// No description provided for @constructionBoq.
  ///
  /// In en, this message translates to:
  /// **'Bill of Quantities'**
  String get constructionBoq;

  /// No description provided for @constructionEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get constructionEstimate;

  /// No description provided for @financeInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get financeInvoice;

  /// No description provided for @financePayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get financePayment;

  /// No description provided for @financeReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get financeReceipt;

  /// No description provided for @financeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get financeExpense;

  /// No description provided for @financeBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get financeBudget;

  /// No description provided for @financeLedger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get financeLedger;

  /// No description provided for @financeAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get financeAccount;

  /// No description provided for @financeBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get financeBalance;

  /// No description provided for @financeTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get financeTax;

  /// No description provided for @financeCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get financeCurrency;

  /// No description provided for @hrEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get hrEmployee;

  /// No description provided for @hrDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get hrDepartment;

  /// No description provided for @hrLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get hrLeave;

  /// No description provided for @hrAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get hrAttendance;

  /// No description provided for @hrPayroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get hrPayroll;

  /// No description provided for @hrSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get hrSalary;

  /// No description provided for @hrDesignation.
  ///
  /// In en, this message translates to:
  /// **'Designation'**
  String get hrDesignation;

  /// No description provided for @hrShift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get hrShift;

  /// No description provided for @hrPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get hrPerformance;

  /// No description provided for @hrTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get hrTraining;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get errorNotFound;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get errorUnauthorized;

  /// No description provided for @errorServerError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again.'**
  String get errorServerError;

  /// No description provided for @errorNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get errorNetworkError;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get errorSessionExpired;

  /// Title of the agronomy assistant screen
  ///
  /// In en, this message translates to:
  /// **'Agronomy assistant'**
  String get advisoryTitle;

  /// Explains that answers are grounded and cited
  ///
  /// In en, this message translates to:
  /// **'Answers grounded on this farm\'s own records and on reference material. Every claim is cited.'**
  String get advisorySubtitle;

  /// Placeholder in the question field
  ///
  /// In en, this message translates to:
  /// **'Ask about a field, a crop, a pest, an input…'**
  String get advisoryAskHint;

  /// Button that submits the question
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get advisorySend;

  /// Shown while the assistant is answering
  ///
  /// In en, this message translates to:
  /// **'Looking this up…'**
  String get advisoryThinking;

  /// Heading above the citation list
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get advisorySources;

  /// Heading above the list of services the assistant called
  ///
  /// In en, this message translates to:
  /// **'Services consulted'**
  String get advisoryToolsUsed;

  /// Heading when no question has been asked yet
  ///
  /// In en, this message translates to:
  /// **'No questions yet'**
  String get advisoryEmptyTitle;

  /// Suggests what can be asked
  ///
  /// In en, this message translates to:
  /// **'Ask about a field\'s irrigation, a crop\'s nutrition, a pest you have seen, or anything in the reference library.'**
  String get advisoryEmptyBody;

  /// Shown above an answer a language model wrote
  ///
  /// In en, this message translates to:
  /// **'Written by the model, grounded on the sources below'**
  String get advisoryKindGenerated;

  /// Shown above an answer quoted from sources because no model is configured
  ///
  /// In en, this message translates to:
  /// **'Quoted from the sources — no language model is configured'**
  String get advisoryKindExtractive;

  /// Shown when nothing grounded an answer
  ///
  /// In en, this message translates to:
  /// **'Not answered'**
  String get advisoryKindRefused;

  /// Groundedness check passed
  ///
  /// In en, this message translates to:
  /// **'Every claim matched a source'**
  String get advisoryVerdictGrounded;

  /// Groundedness check partly failed
  ///
  /// In en, this message translates to:
  /// **'Some claims did not match a source'**
  String get advisoryVerdictPartial;

  /// Groundedness check failed
  ///
  /// In en, this message translates to:
  /// **'This answer could not be matched to a source'**
  String get advisoryVerdictUngrounded;

  /// The exchange is in the agronomist review queue
  ///
  /// In en, this message translates to:
  /// **'Flagged for an agronomist to review'**
  String get advisoryReviewFlagged;

  /// The request to the advisory service failed
  ///
  /// In en, this message translates to:
  /// **'The assistant could not be reached. Nothing was answered.'**
  String get advisoryFailed;

  /// Starts a fresh conversation
  ///
  /// In en, this message translates to:
  /// **'New question'**
  String get advisoryNewConversation;
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
