// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonUpdate => 'Update';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonFilter => 'Filter';

  @override
  String get commonSort => 'Sort';

  @override
  String get commonExport => 'Export';

  @override
  String get commonImport => 'Import';

  @override
  String get commonPrint => 'Print';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonWarning => 'Warning';

  @override
  String get commonInfo => 'Info';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonOk => 'OK';

  @override
  String get commonRequired => 'Required';

  @override
  String get commonOptional => 'Optional';

  @override
  String get commonAll => 'All';

  @override
  String get commonNone => 'None';

  @override
  String get commonSelect => 'Select';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonActions => 'Actions';

  @override
  String get commonStatus => 'Status';

  @override
  String get commonName => 'Name';

  @override
  String get commonDescription => 'Description';

  @override
  String get commonDate => 'Date';

  @override
  String get commonAmount => 'Amount';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonNotes => 'Notes';

  @override
  String get validationRequired => 'This field is required';

  @override
  String validationMinLength(int min) {
    return 'Minimum $min characters required';
  }

  @override
  String validationMaxLength(int max) {
    return 'Maximum $max characters allowed';
  }

  @override
  String get validationEmail => 'Please enter a valid email address';

  @override
  String get validationPhone => 'Please enter a valid phone number';

  @override
  String get validationNumber => 'Please enter a valid number';

  @override
  String validationMin(String min) {
    return 'Value must be at least $min';
  }

  @override
  String validationMax(String max) {
    return 'Value must be at most $max';
  }

  @override
  String get validationPattern => 'Invalid format';

  @override
  String get validationUrl => 'Please enter a valid URL';

  @override
  String get authLogin => 'Login';

  @override
  String get authLogout => 'Logout';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignOut => 'Sign out';

  @override
  String authWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navSettings => 'Settings';

  @override
  String get navProfile => 'Profile';

  @override
  String get navHelp => 'Help';

  @override
  String get agricultureCrop => 'Crop';

  @override
  String get agricultureFarm => 'Farm';

  @override
  String get agricultureHarvest => 'Harvest';

  @override
  String get agricultureSeason => 'Season';

  @override
  String get agricultureField => 'Field';

  @override
  String get agricultureYield => 'Yield';

  @override
  String get agricultureIrrigation => 'Irrigation';

  @override
  String get agricultureFertilizer => 'Fertilizer';

  @override
  String get agriculturePesticide => 'Pesticide';

  @override
  String get agricultureEquipment => 'Equipment';

  @override
  String get manufacturingProduction => 'Production';

  @override
  String get manufacturingWorkOrder => 'Work Order';

  @override
  String get manufacturingBom => 'Bill of Materials';

  @override
  String get manufacturingInventory => 'Inventory';

  @override
  String get manufacturingQuality => 'Quality';

  @override
  String get manufacturingMachine => 'Machine';

  @override
  String get manufacturingShift => 'Shift';

  @override
  String get manufacturingOperator => 'Operator';

  @override
  String get manufacturingDefect => 'Defect';

  @override
  String get manufacturingBatch => 'Batch';

  @override
  String get waterSupply => 'Water Supply';

  @override
  String get waterTreatment => 'Treatment';

  @override
  String get waterDistribution => 'Distribution';

  @override
  String get waterMeter => 'Meter';

  @override
  String get waterConnection => 'Connection';

  @override
  String get waterBill => 'Bill';

  @override
  String get waterConsumption => 'Consumption';

  @override
  String get waterPipeline => 'Pipeline';

  @override
  String get waterPump => 'Pump';

  @override
  String get waterReservoir => 'Reservoir';

  @override
  String get constructionProject => 'Project';

  @override
  String get constructionSite => 'Site';

  @override
  String get constructionContractor => 'Contractor';

  @override
  String get constructionMaterial => 'Material';

  @override
  String get constructionLabour => 'Labour';

  @override
  String get constructionDrawing => 'Drawing';

  @override
  String get constructionInspection => 'Inspection';

  @override
  String get constructionMilestone => 'Milestone';

  @override
  String get constructionBoq => 'Bill of Quantities';

  @override
  String get constructionEstimate => 'Estimate';

  @override
  String get financeInvoice => 'Invoice';

  @override
  String get financePayment => 'Payment';

  @override
  String get financeReceipt => 'Receipt';

  @override
  String get financeExpense => 'Expense';

  @override
  String get financeBudget => 'Budget';

  @override
  String get financeLedger => 'Ledger';

  @override
  String get financeAccount => 'Account';

  @override
  String get financeBalance => 'Balance';

  @override
  String get financeTax => 'Tax';

  @override
  String get financeCurrency => 'Currency';

  @override
  String get hrEmployee => 'Employee';

  @override
  String get hrDepartment => 'Department';

  @override
  String get hrLeave => 'Leave';

  @override
  String get hrAttendance => 'Attendance';

  @override
  String get hrPayroll => 'Payroll';

  @override
  String get hrSalary => 'Salary';

  @override
  String get hrDesignation => 'Designation';

  @override
  String get hrShift => 'Shift';

  @override
  String get hrPerformance => 'Performance';

  @override
  String get hrTraining => 'Training';

  @override
  String get errorNotFound => 'Not found';

  @override
  String get errorUnauthorized => 'Unauthorized';

  @override
  String get errorServerError => 'Server error. Please try again.';

  @override
  String get errorNetworkError => 'Network error. Check your connection.';

  @override
  String get errorSessionExpired => 'Session expired. Please login again.';

  @override
  String get advisoryTitle => 'Agronomy assistant';

  @override
  String get advisorySubtitle =>
      'Answers grounded on this farm\'s own records and on reference material. Every claim is cited.';

  @override
  String get advisoryAskHint => 'Ask about a field, a crop, a pest, an input…';

  @override
  String get advisorySend => 'Ask';

  @override
  String get advisoryThinking => 'Looking this up…';

  @override
  String get advisorySources => 'Sources';

  @override
  String get advisoryToolsUsed => 'Services consulted';

  @override
  String get advisoryEmptyTitle => 'No questions yet';

  @override
  String get advisoryEmptyBody =>
      'Ask about a field\'s irrigation, a crop\'s nutrition, a pest you have seen, or anything in the reference library.';

  @override
  String get advisoryKindGenerated =>
      'Written by the model, grounded on the sources below';

  @override
  String get advisoryKindExtractive =>
      'Quoted from the sources — no language model is configured';

  @override
  String get advisoryKindRefused => 'Not answered';

  @override
  String get advisoryVerdictGrounded => 'Every claim matched a source';

  @override
  String get advisoryVerdictPartial => 'Some claims did not match a source';

  @override
  String get advisoryVerdictUngrounded =>
      'This answer could not be matched to a source';

  @override
  String get advisoryReviewFlagged => 'Flagged for an agronomist to review';

  @override
  String get advisoryFailed =>
      'The assistant could not be reached. Nothing was answered.';

  @override
  String get advisoryNewConversation => 'New question';

  @override
  String get appTitleAgronomist => 'YieldPoint Agronomist';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navSatellite => 'Satellite';

  @override
  String get navSensors => 'Sensors';

  @override
  String get navTraceability => 'Traceability';

  @override
  String get actionRetry => 'Retry';

  @override
  String get authSignOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get settingsAppVersion => 'App Version';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get themeSystemHint => 'Follow device settings';

  @override
  String get farmManaged => 'Managed Farms';

  @override
  String get farmDetails => 'Farm Details';

  @override
  String get inspectionList => 'Field Inspections';

  @override
  String get inspectionNew => 'New Inspection';

  @override
  String get inspectionCreate => 'Create Inspection';

  @override
  String get inspectionCreated => 'Inspection created';

  @override
  String get advisoryDetail => 'Advisory Detail';

  @override
  String get diagnosisPlant => 'Plant Diagnosis';

  @override
  String get diagnosisNew => 'New Diagnosis';

  @override
  String get diagnosisHistory => 'Diagnosis History';

  @override
  String get diagnosisResult => 'Diagnosis Result';

  @override
  String get diagnosisHistoryEmpty => 'No diagnosis history.';

  @override
  String get soilAnalysis => 'Soil Analysis';

  @override
  String get soilSampleNew => 'New Soil Sample';

  @override
  String get soilSampleRecord => 'Record Sample';

  @override
  String get soilSampleRecorded => 'Soil sample recorded';

  @override
  String get pestRisk => 'Pest Risk';

  @override
  String get pestAlerts => 'Pest Alerts';

  @override
  String get stressAlerts => 'Stress Alerts';

  @override
  String get satelliteMonitoring => 'Satellite Monitoring';

  @override
  String get yieldForecast => 'Yield Forecast';

  @override
  String get cropPerformance => 'Crop Performance';

  @override
  String get traceRecord => 'Trace Record';
}
