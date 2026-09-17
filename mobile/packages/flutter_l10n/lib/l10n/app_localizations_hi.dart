// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get commonSave => 'सहेजें';

  @override
  String get commonCancel => 'रद्द करें';

  @override
  String get commonDelete => 'हटाएं';

  @override
  String get commonEdit => 'संपादित करें';

  @override
  String get commonCreate => 'बनाएं';

  @override
  String get commonUpdate => 'अपडेट करें';

  @override
  String get commonClose => 'बंद करें';

  @override
  String get commonBack => 'वापस';

  @override
  String get commonNext => 'अगला';

  @override
  String get commonSubmit => 'जमा करें';

  @override
  String get commonReset => 'रीसेट';

  @override
  String get commonSearch => 'खोजें';

  @override
  String get commonFilter => 'फ़िल्टर';

  @override
  String get commonSort => 'क्रमबद्ध';

  @override
  String get commonExport => 'निर्यात';

  @override
  String get commonImport => 'आयात';

  @override
  String get commonPrint => 'प्रिंट';

  @override
  String get commonLoading => 'लोड हो रहा है...';

  @override
  String get commonError => 'त्रुटि';

  @override
  String get commonSuccess => 'सफल';

  @override
  String get commonWarning => 'चेतावनी';

  @override
  String get commonInfo => 'जानकारी';

  @override
  String get commonConfirm => 'पुष्टि करें';

  @override
  String get commonYes => 'हाँ';

  @override
  String get commonNo => 'नहीं';

  @override
  String get commonOk => 'ठीक है';

  @override
  String get commonRequired => 'आवश्यक';

  @override
  String get commonOptional => 'वैकल्पिक';

  @override
  String get commonAll => 'सभी';

  @override
  String get commonNone => 'कोई नहीं';

  @override
  String get commonSelect => 'चुनें';

  @override
  String get commonClear => 'साफ़ करें';

  @override
  String get commonApply => 'लागू करें';

  @override
  String get commonActions => 'क्रियाएं';

  @override
  String get commonStatus => 'स्थिति';

  @override
  String get commonName => 'नाम';

  @override
  String get commonDescription => 'विवरण';

  @override
  String get commonDate => 'तारीख';

  @override
  String get commonAmount => 'राशि';

  @override
  String get commonTotal => 'कुल';

  @override
  String get commonNotes => 'टिप्पणियां';

  @override
  String get validationRequired => 'यह फ़ील्ड आवश्यक है';

  @override
  String validationMinLength(int min) {
    return 'न्यूनतम $min अक्षर आवश्यक हैं';
  }

  @override
  String validationMaxLength(int max) {
    return 'अधिकतम $max अक्षर अनुमत हैं';
  }

  @override
  String get validationEmail => 'कृपया एक मान्य ईमेल पता दर्ज करें';

  @override
  String get validationPhone => 'कृपया एक मान्य फ़ोन नंबर दर्ज करें';

  @override
  String get validationNumber => 'कृपया एक मान्य संख्या दर्ज करें';

  @override
  String validationMin(String min) {
    return 'मान कम से कम $min होना चाहिए';
  }

  @override
  String validationMax(String max) {
    return 'मान अधिकतम $max होना चाहिए';
  }

  @override
  String get validationPattern => 'अमान्य प्रारूप';

  @override
  String get validationUrl => 'कृपया एक मान्य URL दर्ज करें';

  @override
  String get authLogin => 'लॉगिन';

  @override
  String get authLogout => 'लॉगआउट';

  @override
  String get authEmail => 'ईमेल';

  @override
  String get authPassword => 'पासवर्ड';

  @override
  String get authForgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get authSignIn => 'साइन इन';

  @override
  String get authSignOut => 'साइन आउट';

  @override
  String authWelcome(String name) {
    return 'स्वागत है, $name';
  }

  @override
  String get navDashboard => 'डैशबोर्ड';

  @override
  String get navSettings => 'सेटिंग्स';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get navHelp => 'सहायता';

  @override
  String get agricultureCrop => 'फसल';

  @override
  String get agricultureFarm => 'खेत';

  @override
  String get agricultureHarvest => 'कटाई';

  @override
  String get agricultureSeason => 'मौसम';

  @override
  String get agricultureField => 'खेत';

  @override
  String get agricultureYield => 'उपज';

  @override
  String get agricultureIrrigation => 'सिंचाई';

  @override
  String get agricultureFertilizer => 'उर्वरक';

  @override
  String get agriculturePesticide => 'कीटनाशक';

  @override
  String get agricultureEquipment => 'उपकरण';

  @override
  String get manufacturingProduction => 'उत्पादन';

  @override
  String get manufacturingWorkOrder => 'कार्य आदेश';

  @override
  String get manufacturingBom => 'सामग्री विवरण';

  @override
  String get manufacturingInventory => 'इन्वेंटरी';

  @override
  String get manufacturingQuality => 'गुणवत्ता';

  @override
  String get manufacturingMachine => 'मशीन';

  @override
  String get manufacturingShift => 'पाली';

  @override
  String get manufacturingOperator => 'ऑपरेटर';

  @override
  String get manufacturingDefect => 'दोष';

  @override
  String get manufacturingBatch => 'बैच';

  @override
  String get waterSupply => 'जल आपूर्ति';

  @override
  String get waterTreatment => 'उपचार';

  @override
  String get waterDistribution => 'वितरण';

  @override
  String get waterMeter => 'मीटर';

  @override
  String get waterConnection => 'कनेक्शन';

  @override
  String get waterBill => 'बिल';

  @override
  String get waterConsumption => 'खपत';

  @override
  String get waterPipeline => 'पाइपलाइन';

  @override
  String get waterPump => 'पंप';

  @override
  String get waterReservoir => 'जलाशय';

  @override
  String get constructionProject => 'परियोजना';

  @override
  String get constructionSite => 'स्थल';

  @override
  String get constructionContractor => 'ठेकेदार';

  @override
  String get constructionMaterial => 'सामग्री';

  @override
  String get constructionLabour => 'श्रम';

  @override
  String get constructionDrawing => 'चित्र';

  @override
  String get constructionInspection => 'निरीक्षण';

  @override
  String get constructionMilestone => 'माइलस्टोन';

  @override
  String get constructionBoq => 'मात्रा विवरण';

  @override
  String get constructionEstimate => 'अनुमान';

  @override
  String get financeInvoice => 'चालान';

  @override
  String get financePayment => 'भुगतान';

  @override
  String get financeReceipt => 'रसीद';

  @override
  String get financeExpense => 'व्यय';

  @override
  String get financeBudget => 'बजट';

  @override
  String get financeLedger => 'खाता बही';

  @override
  String get financeAccount => 'खाता';

  @override
  String get financeBalance => 'शेष';

  @override
  String get financeTax => 'कर';

  @override
  String get financeCurrency => 'मुद्रा';

  @override
  String get hrEmployee => 'कर्मचारी';

  @override
  String get hrDepartment => 'विभाग';

  @override
  String get hrLeave => 'छुट्टी';

  @override
  String get hrAttendance => 'उपस्थिति';

  @override
  String get hrPayroll => 'वेतन पत्रक';

  @override
  String get hrSalary => 'वेतन';

  @override
  String get hrDesignation => 'पदनाम';

  @override
  String get hrShift => 'पाली';

  @override
  String get hrPerformance => 'प्रदर्शन';

  @override
  String get hrTraining => 'प्रशिक्षण';

  @override
  String get errorNotFound => 'नहीं मिला';

  @override
  String get errorUnauthorized => 'अनधिकृत';

  @override
  String get errorServerError => 'सर्वर त्रुटि। कृपया पुनः प्रयास करें।';

  @override
  String get errorNetworkError => 'नेटवर्क त्रुटि। अपना कनेक्शन जांचें।';

  @override
  String get errorSessionExpired => 'सत्र समाप्त। कृपया फिर से लॉगिन करें।';

  @override
  String get advisoryTitle => 'कृषि सलाहकार';

  @override
  String get advisorySubtitle =>
      'उत्तर इसी खेत के अपने रिकॉर्ड और संदर्भ सामग्री पर आधारित हैं। हर दावे का स्रोत दिया गया है।';

  @override
  String get advisoryAskHint =>
      'खेत, फसल, कीट या किसी निवेश के बारे में पूछें…';

  @override
  String get advisorySend => 'पूछें';

  @override
  String get advisoryThinking => 'देख रहे हैं…';

  @override
  String get advisorySources => 'स्रोत';

  @override
  String get advisoryToolsUsed => 'उपयोग की गई सेवाएँ';

  @override
  String get advisoryEmptyTitle => 'अभी कोई प्रश्न नहीं';

  @override
  String get advisoryEmptyBody =>
      'खेत की सिंचाई, फसल के पोषण, दिखे हुए कीट या संदर्भ पुस्तकालय की किसी भी बात के बारे में पूछें।';

  @override
  String get advisoryKindGenerated =>
      'मॉडल द्वारा लिखा गया, नीचे दिए स्रोतों पर आधारित';

  @override
  String get advisoryKindExtractive =>
      'स्रोतों से सीधे उद्धृत — कोई भाषा मॉडल कॉन्फ़िगर नहीं है';

  @override
  String get advisoryKindRefused => 'उत्तर नहीं दिया गया';

  @override
  String get advisoryVerdictGrounded => 'हर दावा किसी स्रोत से मेल खाता है';

  @override
  String get advisoryVerdictPartial => 'कुछ दावे किसी स्रोत से मेल नहीं खाते';

  @override
  String get advisoryVerdictUngrounded =>
      'यह उत्तर किसी स्रोत से मेल नहीं खाता';

  @override
  String get advisoryReviewFlagged => 'कृषि विशेषज्ञ की समीक्षा के लिए चिह्नित';

  @override
  String get advisoryFailed =>
      'सलाहकार से संपर्क नहीं हो सका। कोई उत्तर नहीं दिया गया।';

  @override
  String get advisoryNewConversation => 'नया प्रश्न';

  @override
  String get appTitleAgronomist => 'यील्डपॉइंट कृषि विशेषज्ञ';

  @override
  String get navAnalytics => 'विश्लेषण';

  @override
  String get navNotifications => 'सूचनाएं';

  @override
  String get navSatellite => 'उपग्रह';

  @override
  String get navSensors => 'सेंसर';

  @override
  String get navTraceability => 'अनुरेखणीयता';

  @override
  String get actionRetry => 'पुनः प्रयास';

  @override
  String get authSignOutConfirm => 'क्या आप वाकई साइन आउट करना चाहते हैं?';

  @override
  String get settingsAppVersion => 'ऐप संस्करण';

  @override
  String get settingsPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get settingsTermsOfService => 'सेवा की शर्तें';

  @override
  String get themeLight => 'हल्का';

  @override
  String get themeDark => 'गहरा';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeSystemHint => 'डिवाइस सेटिंग्स का पालन करें';

  @override
  String get farmManaged => 'प्रबंधित खेत';

  @override
  String get farmDetails => 'खेत का विवरण';

  @override
  String get inspectionList => 'खेत निरीक्षण';

  @override
  String get inspectionNew => 'नया निरीक्षण';

  @override
  String get inspectionCreate => 'निरीक्षण बनाएं';

  @override
  String get inspectionCreated => 'निरीक्षण बनाया गया';

  @override
  String get advisoryDetail => 'सलाह विवरण';

  @override
  String get diagnosisPlant => 'पौध निदान';

  @override
  String get diagnosisNew => 'नया निदान';

  @override
  String get diagnosisHistory => 'निदान इतिहास';

  @override
  String get diagnosisResult => 'निदान परिणाम';

  @override
  String get diagnosisHistoryEmpty => 'कोई निदान इतिहास नहीं।';

  @override
  String get soilAnalysis => 'मृदा विश्लेषण';

  @override
  String get soilSampleNew => 'नया मृदा नमूना';

  @override
  String get soilSampleRecord => 'नमूना दर्ज करें';

  @override
  String get soilSampleRecorded => 'मृदा नमूना दर्ज किया गया';

  @override
  String get pestRisk => 'कीट जोखिम';

  @override
  String get pestAlerts => 'कीट चेतावनी';

  @override
  String get stressAlerts => 'तनाव चेतावनी';

  @override
  String get satelliteMonitoring => 'उपग्रह निगरानी';

  @override
  String get yieldForecast => 'उपज पूर्वानुमान';

  @override
  String get cropPerformance => 'फसल प्रदर्शन';

  @override
  String get traceRecord => 'अनुरेखण रिकॉर्ड';
}
