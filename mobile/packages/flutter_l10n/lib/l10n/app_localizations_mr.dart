// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get commonSave => 'जतन करा';

  @override
  String get commonCancel => 'रद्द करा';

  @override
  String get commonDelete => 'हटवा';

  @override
  String get commonEdit => 'संपादित करा';

  @override
  String get commonCreate => 'तयार करा';

  @override
  String get commonUpdate => 'अद्ययावत करा';

  @override
  String get commonClose => 'बंद करा';

  @override
  String get commonBack => 'मागे';

  @override
  String get commonNext => 'पुढे';

  @override
  String get commonSubmit => 'सबमिट करा';

  @override
  String get commonReset => 'रीसेट करा';

  @override
  String get commonSearch => 'शोधा';

  @override
  String get commonFilter => 'फिल्टर';

  @override
  String get commonSort => 'क्रमवारी';

  @override
  String get commonExport => 'निर्यात';

  @override
  String get commonImport => 'आयात';

  @override
  String get commonPrint => 'छापा';

  @override
  String get commonLoading => 'लोड होत आहे...';

  @override
  String get commonError => 'त्रुटी';

  @override
  String get commonSuccess => 'यशस्वी';

  @override
  String get commonWarning => 'इशारा';

  @override
  String get commonInfo => 'माहिती';

  @override
  String get commonConfirm => 'पुष्टी करा';

  @override
  String get commonYes => 'होय';

  @override
  String get commonNo => 'नाही';

  @override
  String get commonOk => 'ठीक आहे';

  @override
  String get commonRequired => 'आवश्यक';

  @override
  String get commonOptional => 'ऐच्छिक';

  @override
  String get commonAll => 'सर्व';

  @override
  String get commonNone => 'काहीही नाही';

  @override
  String get commonSelect => 'निवडा';

  @override
  String get commonClear => 'साफ करा';

  @override
  String get commonApply => 'लागू करा';

  @override
  String get commonActions => 'क्रिया';

  @override
  String get commonStatus => 'स्थिती';

  @override
  String get commonName => 'नाव';

  @override
  String get commonDescription => 'वर्णन';

  @override
  String get commonDate => 'दिनांक';

  @override
  String get commonAmount => 'रक्कम';

  @override
  String get commonTotal => 'एकूण';

  @override
  String get commonNotes => 'टिपा';

  @override
  String get validationRequired => 'हे क्षेत्र आवश्यक आहे';

  @override
  String validationMinLength(int min) {
    return 'किमान $min अक्षरे आवश्यक';
  }

  @override
  String validationMaxLength(int max) {
    return 'जास्तीत जास्त $max अक्षरे';
  }

  @override
  String get validationEmail => 'वैध ईमेल पत्ता टाका';

  @override
  String get validationPhone => 'वैध दूरध्वनी क्रमांक टाका';

  @override
  String get validationNumber => 'वैध संख्या टाका';

  @override
  String validationMin(String min) {
    return 'मूल्य किमान $min असावे';
  }

  @override
  String validationMax(String max) {
    return 'मूल्य जास्तीत जास्त $max असावे';
  }

  @override
  String get validationPattern => 'अवैध स्वरूप';

  @override
  String get validationUrl => 'वैध URL टाका';

  @override
  String get authLogin => 'लॉगिन';

  @override
  String get authLogout => 'लॉगआउट';

  @override
  String get authEmail => 'ईमेल';

  @override
  String get authPassword => 'पासवर्ड';

  @override
  String get authForgotPassword => 'पासवर्ड विसरलात?';

  @override
  String get authSignIn => 'साइन इन';

  @override
  String get authSignOut => 'साइन आउट';

  @override
  String authWelcome(String name) {
    return 'स्वागत आहे, $name';
  }

  @override
  String get navDashboard => 'डॅशबोर्ड';

  @override
  String get navSettings => 'सेटिंग्ज';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String get navHelp => 'मदत';

  @override
  String get agricultureCrop => 'पीक';

  @override
  String get agricultureFarm => 'शेत';

  @override
  String get agricultureHarvest => 'कापणी';

  @override
  String get agricultureSeason => 'हंगाम';

  @override
  String get agricultureField => 'शेतजमीन';

  @override
  String get agricultureYield => 'उत्पादन';

  @override
  String get agricultureIrrigation => 'सिंचन';

  @override
  String get agricultureFertilizer => 'खत';

  @override
  String get agriculturePesticide => 'कीटकनाशक';

  @override
  String get agricultureEquipment => 'उपकरणे';

  @override
  String get manufacturingProduction => 'उत्पादन';

  @override
  String get manufacturingWorkOrder => 'कार्य आदेश';

  @override
  String get manufacturingBom => 'साहित्य सूची';

  @override
  String get manufacturingInventory => 'साठा';

  @override
  String get manufacturingQuality => 'गुणवत्ता';

  @override
  String get manufacturingMachine => 'यंत्र';

  @override
  String get manufacturingShift => 'पाळी';

  @override
  String get manufacturingOperator => 'चालक';

  @override
  String get manufacturingDefect => 'दोष';

  @override
  String get manufacturingBatch => 'तुकडी';

  @override
  String get waterSupply => 'पाणीपुरवठा';

  @override
  String get waterTreatment => 'प्रक्रिया';

  @override
  String get waterDistribution => 'वितरण';

  @override
  String get waterMeter => 'मीटर';

  @override
  String get waterConnection => 'जोडणी';

  @override
  String get waterBill => 'बिल';

  @override
  String get waterConsumption => 'वापर';

  @override
  String get waterPipeline => 'जलवाहिनी';

  @override
  String get waterPump => 'पंप';

  @override
  String get waterReservoir => 'जलाशय';

  @override
  String get constructionProject => 'प्रकल्प';

  @override
  String get constructionSite => 'स्थळ';

  @override
  String get constructionContractor => 'कंत्राटदार';

  @override
  String get constructionMaterial => 'साहित्य';

  @override
  String get constructionLabour => 'मजूर';

  @override
  String get constructionDrawing => 'आराखडा';

  @override
  String get constructionInspection => 'तपासणी';

  @override
  String get constructionMilestone => 'टप्पा';

  @override
  String get constructionBoq => 'मात्रा पत्रक';

  @override
  String get constructionEstimate => 'अंदाजपत्रक';

  @override
  String get financeInvoice => 'बीजक';

  @override
  String get financePayment => 'देयक';

  @override
  String get financeReceipt => 'पावती';

  @override
  String get financeExpense => 'खर्च';

  @override
  String get financeBudget => 'अर्थसंकल्प';

  @override
  String get financeLedger => 'खतावणी';

  @override
  String get financeAccount => 'खाते';

  @override
  String get financeBalance => 'शिल्लक';

  @override
  String get financeTax => 'कर';

  @override
  String get financeCurrency => 'चलन';

  @override
  String get hrEmployee => 'कर्मचारी';

  @override
  String get hrDepartment => 'विभाग';

  @override
  String get hrLeave => 'रजा';

  @override
  String get hrAttendance => 'उपस्थिती';

  @override
  String get hrPayroll => 'वेतनपत्रक';

  @override
  String get hrSalary => 'वेतन';

  @override
  String get hrDesignation => 'पदनाम';

  @override
  String get hrShift => 'पाळी';

  @override
  String get hrPerformance => 'कामगिरी';

  @override
  String get hrTraining => 'प्रशिक्षण';

  @override
  String get errorNotFound => 'सापडले नाही';

  @override
  String get errorUnauthorized => 'अनधिकृत';

  @override
  String get errorServerError => 'सर्व्हर त्रुटी. पुन्हा प्रयत्न करा.';

  @override
  String get errorNetworkError => 'नेटवर्क त्रुटी. तुमचे कनेक्शन तपासा.';

  @override
  String get errorSessionExpired => 'सत्र संपले. पुन्हा लॉगिन करा.';

  @override
  String get advisoryTitle => 'कृषी सल्लागार';

  @override
  String get advisorySubtitle =>
      'उत्तरे याच शेताच्या नोंदी व अनुक्रमित संदर्भ साहित्यावर आधारित आहेत. प्रत्येक विधानाचा स्रोत दिला आहे; स्रोत दाबून तो उघडा.';

  @override
  String get advisoryAskHint =>
      'शेत, पीक, कीड किंवा एखाद्या निविष्ठेबद्दल विचारा…';

  @override
  String get advisorySend => 'विचारा';

  @override
  String get advisoryThinking => 'पाहत आहोत…';

  @override
  String get advisorySources => 'स्रोत';

  @override
  String get advisoryToolsUsed => 'वापरलेल्या सेवा';

  @override
  String get advisoryEmptyTitle => 'अजून कोणताही प्रश्न नाही';

  @override
  String get advisoryEmptyBody =>
      'शेताचे पाणी, पिकाचे पोषण, दिसलेली कीड किंवा संदर्भ ग्रंथालयातील कशाबद्दलही विचारा.';

  @override
  String get advisoryKindGenerated =>
      'मॉडेलने लिहिलेले, खालील स्रोतांवर आधारित';

  @override
  String get advisoryKindExtractive =>
      'स्रोतांमधून थेट उद्धृत — कोणतेही भाषा मॉडेल कॉन्फिगर केलेले नाही';

  @override
  String get advisoryKindRefused => 'उत्तर दिले नाही';

  @override
  String get advisoryVerdictGrounded => 'प्रत्येक विधान स्रोताशी जुळते';

  @override
  String get advisoryVerdictPartial => 'काही विधाने स्रोताशी जुळत नाहीत';

  @override
  String get advisoryVerdictUngrounded =>
      'हे उत्तर कोणत्याही स्रोताशी जुळत नाही';

  @override
  String get advisoryReviewFlagged => 'कृषी तज्ज्ञाच्या तपासणीसाठी चिन्हांकित';

  @override
  String get advisoryFailed =>
      'सल्लागाराशी संपर्क होऊ शकला नाही. उत्तर दिले गेले नाही.';

  @override
  String get advisoryNewConversation => 'नवीन प्रश्न';

  @override
  String get appTitleAgronomist => 'यील्डपॉइंट कृषी तज्ज्ञ';

  @override
  String get navAnalytics => 'विश्लेषण';

  @override
  String get navNotifications => 'सूचना';

  @override
  String get navSatellite => 'उपग्रह';

  @override
  String get navSensors => 'सेन्सर';

  @override
  String get navTraceability => 'शोधक्षमता';

  @override
  String get actionRetry => 'पुन्हा प्रयत्न';

  @override
  String get authSignOutConfirm =>
      'तुम्हाला खात्री आहे की साइन आउट करायचे आहे?';

  @override
  String get settingsAppVersion => 'ॲप आवृत्ती';

  @override
  String get settingsPrivacyPolicy => 'गोपनीयता धोरण';

  @override
  String get settingsTermsOfService => 'सेवा अटी';

  @override
  String get themeLight => 'फिकट';

  @override
  String get themeDark => 'गडद';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeSystemHint => 'डिव्हाइस सेटिंग्ज वापरा';

  @override
  String get farmManaged => 'व्यवस्थापित शेते';

  @override
  String get farmDetails => 'शेताचा तपशील';

  @override
  String get inspectionList => 'शेत तपासणी';

  @override
  String get inspectionNew => 'नवीन तपासणी';

  @override
  String get inspectionCreate => 'तपासणी तयार करा';

  @override
  String get inspectionCreated => 'तपासणी तयार झाली';

  @override
  String get advisoryDetail => 'सल्ला तपशील';

  @override
  String get diagnosisPlant => 'वनस्पती निदान';

  @override
  String get diagnosisNew => 'नवीन निदान';

  @override
  String get diagnosisHistory => 'निदान इतिहास';

  @override
  String get diagnosisResult => 'निदान निकाल';

  @override
  String get diagnosisHistoryEmpty => 'निदान इतिहास नाही.';

  @override
  String get soilAnalysis => 'माती विश्लेषण';

  @override
  String get soilSampleNew => 'नवीन माती नमुना';

  @override
  String get soilSampleRecord => 'नमुना नोंदवा';

  @override
  String get soilSampleRecorded => 'माती नमुना नोंदवला';

  @override
  String get pestRisk => 'कीड धोका';

  @override
  String get pestAlerts => 'कीड इशारे';

  @override
  String get stressAlerts => 'ताण इशारे';

  @override
  String get satelliteMonitoring => 'उपग्रह निरीक्षण';

  @override
  String get yieldForecast => 'उत्पादन अंदाज';

  @override
  String get cropPerformance => 'पीक कामगिरी';

  @override
  String get traceRecord => 'शोध नोंद';
}
