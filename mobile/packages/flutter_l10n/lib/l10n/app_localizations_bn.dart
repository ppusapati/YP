// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get commonSave => 'সংরক্ষণ করুন';

  @override
  String get commonCancel => 'বাতিল করুন';

  @override
  String get commonDelete => 'মুছুন';

  @override
  String get commonEdit => 'সম্পাদনা করুন';

  @override
  String get commonCreate => 'তৈরি করুন';

  @override
  String get commonUpdate => 'হালনাগাদ করুন';

  @override
  String get commonClose => 'বন্ধ করুন';

  @override
  String get commonBack => 'পিছনে';

  @override
  String get commonNext => 'পরবর্তী';

  @override
  String get commonSubmit => 'জমা দিন';

  @override
  String get commonReset => 'রিসেট করুন';

  @override
  String get commonSearch => 'খুঁজুন';

  @override
  String get commonFilter => 'ফিল্টার';

  @override
  String get commonSort => 'সাজান';

  @override
  String get commonExport => 'রপ্তানি';

  @override
  String get commonImport => 'আমদানি';

  @override
  String get commonPrint => 'মুদ্রণ করুন';

  @override
  String get commonLoading => 'লোড হচ্ছে...';

  @override
  String get commonError => 'ত্রুটি';

  @override
  String get commonSuccess => 'সফল';

  @override
  String get commonWarning => 'সতর্কতা';

  @override
  String get commonInfo => 'তথ্য';

  @override
  String get commonConfirm => 'নিশ্চিত করুন';

  @override
  String get commonYes => 'হ্যাঁ';

  @override
  String get commonNo => 'না';

  @override
  String get commonOk => 'ঠিক আছে';

  @override
  String get commonRequired => 'আবশ্যক';

  @override
  String get commonOptional => 'ঐচ্ছিক';

  @override
  String get commonAll => 'সব';

  @override
  String get commonNone => 'কোনোটিই নয়';

  @override
  String get commonSelect => 'নির্বাচন করুন';

  @override
  String get commonClear => 'পরিষ্কার করুন';

  @override
  String get commonApply => 'প্রয়োগ করুন';

  @override
  String get commonActions => 'কার্যক্রম';

  @override
  String get commonStatus => 'অবস্থা';

  @override
  String get commonName => 'নাম';

  @override
  String get commonDescription => 'বিবরণ';

  @override
  String get commonDate => 'তারিখ';

  @override
  String get commonAmount => 'পরিমাণ';

  @override
  String get commonTotal => 'মোট';

  @override
  String get commonNotes => 'নোট';

  @override
  String get validationRequired => 'এই ঘরটি আবশ্যক';

  @override
  String validationMinLength(int min) {
    return 'কমপক্ষে $minটি অক্ষর প্রয়োজন';
  }

  @override
  String validationMaxLength(int max) {
    return 'সর্বাধিক $maxটি অক্ষর';
  }

  @override
  String get validationEmail => 'সঠিক ইমেল ঠিকানা দিন';

  @override
  String get validationPhone => 'সঠিক ফোন নম্বর দিন';

  @override
  String get validationNumber => 'সঠিক সংখ্যা দিন';

  @override
  String validationMin(String min) {
    return 'মান কমপক্ষে $min হতে হবে';
  }

  @override
  String validationMax(String max) {
    return 'মান সর্বাধিক $max হতে হবে';
  }

  @override
  String get validationPattern => 'অবৈধ বিন্যাস';

  @override
  String get validationUrl => 'সঠিক URL দিন';

  @override
  String get authLogin => 'লগইন';

  @override
  String get authLogout => 'লগআউট';

  @override
  String get authEmail => 'ইমেল';

  @override
  String get authPassword => 'পাসওয়ার্ড';

  @override
  String get authForgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get authSignIn => 'সাইন ইন';

  @override
  String get authSignOut => 'সাইন আউট';

  @override
  String authWelcome(String name) {
    return 'স্বাগতম, $name';
  }

  @override
  String get navDashboard => 'ড্যাশবোর্ড';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get navProfile => 'প্রোফাইল';

  @override
  String get navHelp => 'সহায়তা';

  @override
  String get agricultureCrop => 'ফসল';

  @override
  String get agricultureFarm => 'খামার';

  @override
  String get agricultureHarvest => 'ফসল কাটা';

  @override
  String get agricultureSeason => 'মৌসুম';

  @override
  String get agricultureField => 'জমি';

  @override
  String get agricultureYield => 'ফলন';

  @override
  String get agricultureIrrigation => 'সেচ';

  @override
  String get agricultureFertilizer => 'সার';

  @override
  String get agriculturePesticide => 'কীটনাশক';

  @override
  String get agricultureEquipment => 'সরঞ্জাম';

  @override
  String get manufacturingProduction => 'উৎপাদন';

  @override
  String get manufacturingWorkOrder => 'কার্যাদেশ';

  @override
  String get manufacturingBom => 'সামগ্রীর তালিকা';

  @override
  String get manufacturingInventory => 'মজুদ';

  @override
  String get manufacturingQuality => 'গুণমান';

  @override
  String get manufacturingMachine => 'যন্ত্র';

  @override
  String get manufacturingShift => 'শিফট';

  @override
  String get manufacturingOperator => 'পরিচালক';

  @override
  String get manufacturingDefect => 'ত্রুটি';

  @override
  String get manufacturingBatch => 'ব্যাচ';

  @override
  String get waterSupply => 'জল সরবরাহ';

  @override
  String get waterTreatment => 'পরিশোধন';

  @override
  String get waterDistribution => 'বণ্টন';

  @override
  String get waterMeter => 'মিটার';

  @override
  String get waterConnection => 'সংযোগ';

  @override
  String get waterBill => 'বিল';

  @override
  String get waterConsumption => 'ব্যবহার';

  @override
  String get waterPipeline => 'পাইপলাইন';

  @override
  String get waterPump => 'পাম্প';

  @override
  String get waterReservoir => 'জলাধার';

  @override
  String get constructionProject => 'প্রকল্প';

  @override
  String get constructionSite => 'স্থান';

  @override
  String get constructionContractor => 'ঠিকাদার';

  @override
  String get constructionMaterial => 'উপকরণ';

  @override
  String get constructionLabour => 'শ্রমিক';

  @override
  String get constructionDrawing => 'নকশা';

  @override
  String get constructionInspection => 'পরিদর্শন';

  @override
  String get constructionMilestone => 'মাইলফলক';

  @override
  String get constructionBoq => 'পরিমাণ তালিকা';

  @override
  String get constructionEstimate => 'প্রাক্কলন';

  @override
  String get financeInvoice => 'চালান';

  @override
  String get financePayment => 'পরিশোধ';

  @override
  String get financeReceipt => 'রসিদ';

  @override
  String get financeExpense => 'ব্যয়';

  @override
  String get financeBudget => 'বাজেট';

  @override
  String get financeLedger => 'খতিয়ান';

  @override
  String get financeAccount => 'হিসাব';

  @override
  String get financeBalance => 'স্থিতি';

  @override
  String get financeTax => 'কর';

  @override
  String get financeCurrency => 'মুদ্রা';

  @override
  String get hrEmployee => 'কর্মচারী';

  @override
  String get hrDepartment => 'বিভাগ';

  @override
  String get hrLeave => 'ছুটি';

  @override
  String get hrAttendance => 'উপস্থিতি';

  @override
  String get hrPayroll => 'বেতন তালিকা';

  @override
  String get hrSalary => 'বেতন';

  @override
  String get hrDesignation => 'পদবি';

  @override
  String get hrShift => 'শিফট';

  @override
  String get hrPerformance => 'কর্মদক্ষতা';

  @override
  String get hrTraining => 'প্রশিক্ষণ';

  @override
  String get errorNotFound => 'পাওয়া যায়নি';

  @override
  String get errorUnauthorized => 'অননুমোদিত';

  @override
  String get errorServerError => 'সার্ভার ত্রুটি। আবার চেষ্টা করুন।';

  @override
  String get errorNetworkError =>
      'নেটওয়ার্ক ত্রুটি। আপনার সংযোগ পরীক্ষা করুন।';

  @override
  String get errorSessionExpired => 'সেশনের মেয়াদ শেষ। আবার লগইন করুন।';

  @override
  String get advisoryTitle => 'কৃষি পরামর্শদাতা';

  @override
  String get advisorySubtitle =>
      'উত্তরগুলি এই খামারের নিজস্ব রেকর্ড ও সূচিবদ্ধ তথ্যসূত্রের উপর ভিত্তি করে। প্রতিটি দাবির সূত্র দেওয়া আছে; সূত্রে চাপ দিয়ে খুলুন।';

  @override
  String get advisoryAskHint =>
      'জমি, ফসল, পোকা বা কোনো উপকরণ সম্পর্কে জিজ্ঞাসা করুন…';

  @override
  String get advisorySend => 'জিজ্ঞাসা';

  @override
  String get advisoryThinking => 'দেখছি…';

  @override
  String get advisorySources => 'সূত্র';

  @override
  String get advisoryToolsUsed => 'ব্যবহৃত পরিষেবা';

  @override
  String get advisoryEmptyTitle => 'এখনও কোনো প্রশ্ন নেই';

  @override
  String get advisoryEmptyBody =>
      'জমির সেচ, ফসলের পুষ্টি, আপনার দেখা পোকা বা তথ্যসূত্র গ্রন্থাগারের যেকোনো বিষয়ে জিজ্ঞাসা করুন।';

  @override
  String get advisoryKindGenerated => 'মডেল লিখেছে, নিচের সূত্রের ভিত্তিতে';

  @override
  String get advisoryKindExtractive =>
      'সূত্র থেকে সরাসরি উদ্ধৃত — কোনো ভাষা মডেল কনফিগার করা নেই';

  @override
  String get advisoryKindRefused => 'উত্তর দেওয়া হয়নি';

  @override
  String get advisoryVerdictGrounded =>
      'প্রতিটি দাবি একটি সূত্রের সঙ্গে মিলেছে';

  @override
  String get advisoryVerdictPartial => 'কিছু দাবি কোনো সূত্রের সঙ্গে মেলেনি';

  @override
  String get advisoryVerdictUngrounded =>
      'এই উত্তরটি কোনো সূত্রের সঙ্গে মেলানো যায়নি';

  @override
  String get advisoryReviewFlagged =>
      'কৃষি বিশেষজ্ঞের পর্যালোচনার জন্য চিহ্নিত';

  @override
  String get advisoryFailed =>
      'পরামর্শদাতার সঙ্গে যোগাযোগ করা যায়নি। কোনো উত্তর দেওয়া হয়নি।';

  @override
  String get advisoryNewConversation => 'নতুন প্রশ্ন';

  @override
  String get appTitleAgronomist => 'ইল্ডপয়েন্ট কৃষি বিশেষজ্ঞ';

  @override
  String get navAnalytics => 'বিশ্লেষণ';

  @override
  String get navNotifications => 'বিজ্ঞপ্তি';

  @override
  String get navSatellite => 'উপগ্রহ';

  @override
  String get navSensors => 'সেন্সর';

  @override
  String get navTraceability => 'সনাক্তযোগ্যতা';

  @override
  String get actionRetry => 'আবার চেষ্টা';

  @override
  String get authSignOutConfirm => 'আপনি কি নিশ্চিতভাবে সাইন আউট করতে চান?';

  @override
  String get settingsAppVersion => 'অ্যাপ সংস্করণ';

  @override
  String get settingsPrivacyPolicy => 'গোপনীয়তা নীতি';

  @override
  String get settingsTermsOfService => 'পরিষেবার শর্তাবলী';

  @override
  String get themeLight => 'হালকা';

  @override
  String get themeDark => 'গাঢ়';

  @override
  String get themeSystem => 'সিস্টেম';

  @override
  String get themeSystemHint => 'ডিভাইস সেটিংস অনুসরণ করুন';

  @override
  String get farmManaged => 'পরিচালিত খামার';

  @override
  String get farmDetails => 'খামারের বিবরণ';

  @override
  String get inspectionList => 'জমি পরিদর্শন';

  @override
  String get inspectionNew => 'নতুন পরিদর্শন';

  @override
  String get inspectionCreate => 'পরিদর্শন তৈরি করুন';

  @override
  String get inspectionCreated => 'পরিদর্শন তৈরি হয়েছে';

  @override
  String get advisoryDetail => 'পরামর্শের বিবরণ';

  @override
  String get diagnosisPlant => 'উদ্ভিদ নির্ণয়';

  @override
  String get diagnosisNew => 'নতুন নির্ণয়';

  @override
  String get diagnosisHistory => 'নির্ণয়ের ইতিহাস';

  @override
  String get diagnosisResult => 'নির্ণয়ের ফলাফল';

  @override
  String get diagnosisHistoryEmpty => 'নির্ণয়ের কোনো ইতিহাস নেই।';

  @override
  String get soilAnalysis => 'মাটি বিশ্লেষণ';

  @override
  String get soilSampleNew => 'নতুন মাটির নমুনা';

  @override
  String get soilSampleRecord => 'নমুনা রেকর্ড করুন';

  @override
  String get soilSampleRecorded => 'মাটির নমুনা রেকর্ড হয়েছে';

  @override
  String get pestRisk => 'পোকার ঝুঁকি';

  @override
  String get pestAlerts => 'পোকার সতর্কতা';

  @override
  String get stressAlerts => 'চাপের সতর্কতা';

  @override
  String get satelliteMonitoring => 'উপগ্রহ পর্যবেক্ষণ';

  @override
  String get yieldForecast => 'ফলনের পূর্বাভাস';

  @override
  String get cropPerformance => 'ফসলের কর্মদক্ষতা';

  @override
  String get traceRecord => 'সনাক্তকরণ রেকর্ড';
}
