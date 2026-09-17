// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get commonSave => 'சேமி';

  @override
  String get commonCancel => 'ரத்து செய்';

  @override
  String get commonDelete => 'நீக்கு';

  @override
  String get commonEdit => 'திருத்து';

  @override
  String get commonCreate => 'உருவாக்கு';

  @override
  String get commonUpdate => 'புதுப்பி';

  @override
  String get commonClose => 'மூடு';

  @override
  String get commonBack => 'பின்';

  @override
  String get commonNext => 'அடுத்து';

  @override
  String get commonSubmit => 'சமர்ப்பி';

  @override
  String get commonReset => 'மீட்டமை';

  @override
  String get commonSearch => 'தேடு';

  @override
  String get commonFilter => 'வடிகட்டு';

  @override
  String get commonSort => 'வரிசைப்படுத்து';

  @override
  String get commonExport => 'ஏற்றுமதி';

  @override
  String get commonImport => 'இறக்குமதி';

  @override
  String get commonPrint => 'அச்சிடு';

  @override
  String get commonLoading => 'ஏற்றுகிறது...';

  @override
  String get commonError => 'பிழை';

  @override
  String get commonSuccess => 'வெற்றி';

  @override
  String get commonWarning => 'எச்சரிக்கை';

  @override
  String get commonInfo => 'தகவல்';

  @override
  String get commonConfirm => 'உறுதிப்படுத்து';

  @override
  String get commonYes => 'ஆம்';

  @override
  String get commonNo => 'இல்லை';

  @override
  String get commonOk => 'சரி';

  @override
  String get commonRequired => 'தேவை';

  @override
  String get commonOptional => 'விருப்பம்';

  @override
  String get commonAll => 'அனைத்தும்';

  @override
  String get commonNone => 'எதுவுமில்லை';

  @override
  String get commonSelect => 'தேர்ந்தெடு';

  @override
  String get commonClear => 'அழி';

  @override
  String get commonApply => 'பயன்படுத்து';

  @override
  String get commonActions => 'செயல்கள்';

  @override
  String get commonStatus => 'நிலை';

  @override
  String get commonName => 'பெயர்';

  @override
  String get commonDescription => 'விளக்கம்';

  @override
  String get commonDate => 'தேதி';

  @override
  String get commonAmount => 'தொகை';

  @override
  String get commonTotal => 'மொத்தம்';

  @override
  String get commonNotes => 'குறிப்புகள்';

  @override
  String get validationRequired => 'இந்தப் புலம் தேவை';

  @override
  String validationMinLength(int min) {
    return 'குறைந்தது $min எழுத்துகள் தேவை';
  }

  @override
  String validationMaxLength(int max) {
    return 'அதிகபட்சம் $max எழுத்துகள்';
  }

  @override
  String get validationEmail => 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்';

  @override
  String get validationPhone => 'சரியான தொலைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get validationNumber => 'சரியான எண்ணை உள்ளிடவும்';

  @override
  String validationMin(String min) {
    return 'மதிப்பு குறைந்தது $min ஆக இருக்க வேண்டும்';
  }

  @override
  String validationMax(String max) {
    return 'மதிப்பு அதிகபட்சம் $max ஆக இருக்க வேண்டும்';
  }

  @override
  String get validationPattern => 'தவறான வடிவம்';

  @override
  String get validationUrl => 'சரியான URL ஐ உள்ளிடவும்';

  @override
  String get authLogin => 'உள்நுழை';

  @override
  String get authLogout => 'வெளியேறு';

  @override
  String get authEmail => 'மின்னஞ்சல்';

  @override
  String get authPassword => 'கடவுச்சொல்';

  @override
  String get authForgotPassword => 'கடவுச்சொல் மறந்துவிட்டதா?';

  @override
  String get authSignIn => 'உள்நுழைக';

  @override
  String get authSignOut => 'வெளியேறு';

  @override
  String authWelcome(String name) {
    return 'வரவேற்கிறோம், $name';
  }

  @override
  String get navDashboard => 'டாஷ்போர்டு';

  @override
  String get navSettings => 'அமைப்புகள்';

  @override
  String get navProfile => 'சுயவிவரம்';

  @override
  String get navHelp => 'உதவி';

  @override
  String get agricultureCrop => 'பயிர்';

  @override
  String get agricultureFarm => 'பண்ணை';

  @override
  String get agricultureHarvest => 'அறுவடை';

  @override
  String get agricultureSeason => 'பருவம்';

  @override
  String get agricultureField => 'வயல்';

  @override
  String get agricultureYield => 'விளைச்சல்';

  @override
  String get agricultureIrrigation => 'நீர்ப்பாசனம்';

  @override
  String get agricultureFertilizer => 'உரம்';

  @override
  String get agriculturePesticide => 'பூச்சிக்கொல்லி';

  @override
  String get agricultureEquipment => 'உபகரணங்கள்';

  @override
  String get manufacturingProduction => 'உற்பத்தி';

  @override
  String get manufacturingWorkOrder => 'பணி ஆணை';

  @override
  String get manufacturingBom => 'பொருட்கள் பட்டியல்';

  @override
  String get manufacturingInventory => 'சரக்கு';

  @override
  String get manufacturingQuality => 'தரம்';

  @override
  String get manufacturingMachine => 'இயந்திரம்';

  @override
  String get manufacturingShift => 'பணிமுறை';

  @override
  String get manufacturingOperator => 'இயக்குநர்';

  @override
  String get manufacturingDefect => 'குறைபாடு';

  @override
  String get manufacturingBatch => 'தொகுதி';

  @override
  String get waterSupply => 'நீர் விநியோகம்';

  @override
  String get waterTreatment => 'சுத்திகரிப்பு';

  @override
  String get waterDistribution => 'விநியோகம்';

  @override
  String get waterMeter => 'மீட்டர்';

  @override
  String get waterConnection => 'இணைப்பு';

  @override
  String get waterBill => 'கட்டணச் சீட்டு';

  @override
  String get waterConsumption => 'நுகர்வு';

  @override
  String get waterPipeline => 'குழாய் வழி';

  @override
  String get waterPump => 'விசையியக்கி';

  @override
  String get waterReservoir => 'நீர்த்தேக்கம்';

  @override
  String get constructionProject => 'திட்டம்';

  @override
  String get constructionSite => 'இடம்';

  @override
  String get constructionContractor => 'ஒப்பந்தக்காரர்';

  @override
  String get constructionMaterial => 'பொருள்';

  @override
  String get constructionLabour => 'தொழிலாளர்';

  @override
  String get constructionDrawing => 'வரைபடம்';

  @override
  String get constructionInspection => 'ஆய்வு';

  @override
  String get constructionMilestone => 'மைல்கல்';

  @override
  String get constructionBoq => 'அளவுப் பட்டியல்';

  @override
  String get constructionEstimate => 'மதிப்பீடு';

  @override
  String get financeInvoice => 'விலைப்பட்டியல்';

  @override
  String get financePayment => 'கட்டணம்';

  @override
  String get financeReceipt => 'ரசீது';

  @override
  String get financeExpense => 'செலவு';

  @override
  String get financeBudget => 'நிதித்திட்டம்';

  @override
  String get financeLedger => 'பேரேடு';

  @override
  String get financeAccount => 'கணக்கு';

  @override
  String get financeBalance => 'இருப்பு';

  @override
  String get financeTax => 'வரி';

  @override
  String get financeCurrency => 'நாணயம்';

  @override
  String get hrEmployee => 'ஊழியர்';

  @override
  String get hrDepartment => 'துறை';

  @override
  String get hrLeave => 'விடுப்பு';

  @override
  String get hrAttendance => 'வருகை';

  @override
  String get hrPayroll => 'ஊதியப் பட்டியல்';

  @override
  String get hrSalary => 'சம்பளம்';

  @override
  String get hrDesignation => 'பதவி';

  @override
  String get hrShift => 'பணிமுறை';

  @override
  String get hrPerformance => 'செயல்திறன்';

  @override
  String get hrTraining => 'பயிற்சி';

  @override
  String get errorNotFound => 'கிடைக்கவில்லை';

  @override
  String get errorUnauthorized => 'அனுமதி இல்லை';

  @override
  String get errorServerError => 'சேவையகப் பிழை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorNetworkError =>
      'பிணையப் பிழை. உங்கள் இணைப்பைச் சரிபார்க்கவும்.';

  @override
  String get errorSessionExpired =>
      'அமர்வு காலாவதியானது. மீண்டும் உள்நுழையவும்.';

  @override
  String get advisoryTitle => 'வேளாண் ஆலோசகர்';

  @override
  String get advisorySubtitle =>
      'பதில்கள் இந்த பண்ணையின் சொந்தப் பதிவுகள் மற்றும் அட்டவணைப்படுத்தப்பட்ட மேற்கோள் ஆவணங்களை அடிப்படையாகக் கொண்டவை. ஒவ்வொரு கூற்றுக்கும் ஆதாரம் உண்டு; ஆதாரத்தை அழுத்தித் திறக்கவும்.';

  @override
  String get advisoryAskHint =>
      'வயல், பயிர், பூச்சி அல்லது இடுபொருள் குறித்துக் கேளுங்கள்…';

  @override
  String get advisorySend => 'கேள்';

  @override
  String get advisoryThinking => 'பார்க்கிறோம்…';

  @override
  String get advisorySources => 'ஆதாரங்கள்';

  @override
  String get advisoryToolsUsed => 'பயன்படுத்திய சேவைகள்';

  @override
  String get advisoryEmptyTitle => 'இதுவரை கேள்விகள் இல்லை';

  @override
  String get advisoryEmptyBody =>
      'வயலின் நீர்ப்பாசனம், பயிரின் ஊட்டச்சத்து, நீங்கள் பார்த்த பூச்சி அல்லது மேற்கோள் நூலகத்தில் உள்ள எதைப் பற்றியும் கேளுங்கள்.';

  @override
  String get advisoryKindGenerated =>
      'மாதிரி எழுதியது, கீழுள்ள ஆதாரங்களின் அடிப்படையில்';

  @override
  String get advisoryKindExtractive =>
      'ஆதாரங்களிலிருந்து நேரடி மேற்கோள் — மொழி மாதிரி எதுவும் அமைக்கப்படவில்லை';

  @override
  String get advisoryKindRefused => 'பதில் அளிக்கப்படவில்லை';

  @override
  String get advisoryVerdictGrounded =>
      'ஒவ்வொரு கூற்றும் ஒரு ஆதாரத்துடன் பொருந்தியது';

  @override
  String get advisoryVerdictPartial =>
      'சில கூற்றுகள் எந்த ஆதாரத்துடனும் பொருந்தவில்லை';

  @override
  String get advisoryVerdictUngrounded =>
      'இந்தப் பதிலை எந்த ஆதாரத்துடனும் பொருத்த முடியவில்லை';

  @override
  String get advisoryReviewFlagged =>
      'வேளாண் நிபுணர் பரிசீலனைக்குக் குறிக்கப்பட்டது';

  @override
  String get advisoryFailed =>
      'ஆலோசகரைத் தொடர்பு கொள்ள முடியவில்லை. பதில் எதுவும் அளிக்கப்படவில்லை.';

  @override
  String get advisoryNewConversation => 'புதிய கேள்வி';

  @override
  String get appTitleAgronomist => 'யீல்ட்பாயிண்ட் வேளாண் நிபுணர்';

  @override
  String get navAnalytics => 'பகுப்பாய்வு';

  @override
  String get navNotifications => 'அறிவிப்புகள்';

  @override
  String get navSatellite => 'செயற்கைக்கோள்';

  @override
  String get navSensors => 'உணரிகள்';

  @override
  String get navTraceability => 'தடமறிதல்';

  @override
  String get actionRetry => 'மீண்டும் முயற்சி';

  @override
  String get authSignOutConfirm => 'நிச்சயமாக வெளியேற விரும்புகிறீர்களா?';

  @override
  String get settingsAppVersion => 'செயலி பதிப்பு';

  @override
  String get settingsPrivacyPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String get settingsTermsOfService => 'சேவை விதிமுறைகள்';

  @override
  String get themeLight => 'வெளிர்';

  @override
  String get themeDark => 'அடர்';

  @override
  String get themeSystem => 'அமைப்பு';

  @override
  String get themeSystemHint => 'சாதன அமைப்புகளைப் பின்பற்று';

  @override
  String get farmManaged => 'நிர்வகிக்கப்படும் பண்ணைகள்';

  @override
  String get farmDetails => 'பண்ணை விவரங்கள்';

  @override
  String get inspectionList => 'வயல் ஆய்வுகள்';

  @override
  String get inspectionNew => 'புதிய ஆய்வு';

  @override
  String get inspectionCreate => 'ஆய்வை உருவாக்கு';

  @override
  String get inspectionCreated => 'ஆய்வு உருவாக்கப்பட்டது';

  @override
  String get advisoryDetail => 'ஆலோசனை விவரம்';

  @override
  String get diagnosisPlant => 'தாவர நோயறிதல்';

  @override
  String get diagnosisNew => 'புதிய நோயறிதல்';

  @override
  String get diagnosisHistory => 'நோயறிதல் வரலாறு';

  @override
  String get diagnosisResult => 'நோயறிதல் முடிவு';

  @override
  String get diagnosisHistoryEmpty => 'நோயறிதல் வரலாறு இல்லை.';

  @override
  String get soilAnalysis => 'மண் பகுப்பாய்வு';

  @override
  String get soilSampleNew => 'புதிய மண் மாதிரி';

  @override
  String get soilSampleRecord => 'மாதிரியைப் பதிவு செய்';

  @override
  String get soilSampleRecorded => 'மண் மாதிரி பதிவு செய்யப்பட்டது';

  @override
  String get pestRisk => 'பூச்சி ஆபத்து';

  @override
  String get pestAlerts => 'பூச்சி எச்சரிக்கைகள்';

  @override
  String get stressAlerts => 'அழுத்த எச்சரிக்கைகள்';

  @override
  String get satelliteMonitoring => 'செயற்கைக்கோள் கண்காணிப்பு';

  @override
  String get yieldForecast => 'விளைச்சல் முன்னறிவிப்பு';

  @override
  String get cropPerformance => 'பயிர் செயல்திறன்';

  @override
  String get traceRecord => 'தட ஆவணம்';
}
