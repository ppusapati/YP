package domain

import (
	"strings"
	"unicode"
)

// Locale is one of the languages the platform already ships.
type Locale string

const (
	LocaleUnspecified Locale = ""
	LocaleEN          Locale = "en"
	LocaleHI          Locale = "hi"
	LocaleMR          Locale = "mr"
	LocaleTE          Locale = "te"
	LocaleTA          Locale = "ta"
	LocaleKN          Locale = "kn"
	LocalePA          Locale = "pa"
	LocaleBN          Locale = "bn"
)

// SupportedLocales is the shipped set, in the order the apps list them.
var SupportedLocales = []Locale{
	LocaleEN, LocaleHI, LocaleMR, LocaleTE, LocaleTA, LocaleKN, LocalePA, LocaleBN,
}

// localeNames are the language's own names, used in the prompt.
//
// The endonym rather than the English name: a model told to answer "in
// Marathi" and a model told to answer in मराठी behave the same, but the
// endonym also survives being shown to the person asking, which is what the
// "answering in X" line in the UI needs.
var localeNames = map[Locale]struct{ English, Native string }{
	LocaleEN: {"English", "English"},
	LocaleHI: {"Hindi", "हिन्दी"},
	LocaleMR: {"Marathi", "मराठी"},
	LocaleTE: {"Telugu", "తెలుగు"},
	LocaleTA: {"Tamil", "தமிழ்"},
	LocaleKN: {"Kannada", "ಕನ್ನಡ"},
	LocalePA: {"Punjabi", "ਪੰਜਾਬੀ"},
	LocaleBN: {"Bengali", "বাংলা"},
}

// ParseLocale maps a tag onto a shipped locale.
//
// Unknown tags fall back to English rather than being rejected. A farmer whose
// phone reports a language this platform has not been translated into should
// get an answer in English, not an error: an answer they can partly read beats
// nothing, and the response says which language it is in either way.
func ParseLocale(tag string) Locale {
	tag = strings.ToLower(strings.TrimSpace(tag))
	if tag == "" {
		return LocaleEN
	}
	// Strip a region or script subtag: "hi-IN", "pa_Guru" and "bn-BD" are all
	// the locale we ship.
	if i := strings.IndexAny(tag, "-_"); i > 0 {
		tag = tag[:i]
	}
	for _, l := range SupportedLocales {
		if string(l) == tag {
			return l
		}
	}
	return LocaleEN
}

// IsSupported reports whether a locale is one of the shipped set.
func (l Locale) IsSupported() bool {
	for _, s := range SupportedLocales {
		if s == l {
			return true
		}
	}
	return false
}

// OrDefault resolves an unspecified locale to English.
func (l Locale) OrDefault() Locale {
	if l.IsSupported() {
		return l
	}
	return LocaleEN
}

// EnglishName is the language's name in English.
func (l Locale) EnglishName() string {
	if n, ok := localeNames[l.OrDefault()]; ok {
		return n.English
	}
	return "English"
}

// NativeName is the language's name in itself.
func (l Locale) NativeName() string {
	if n, ok := localeNames[l.OrDefault()]; ok {
		return n.Native
	}
	return "English"
}

// ── Phrases ──────────────────────────────────────────────────────────────────

// PhraseKey names a fixed string the service itself produces.
//
// These are not the model's words. When no model is configured the answer is
// assembled here, and when retrieval finds nothing the refusal is written
// here; both have to come out in the language that was asked for, or the
// locale support is only skin-deep — a Telugu-speaking farmer would get a
// Telugu-labelled screen with an English apology in it.
type PhraseKey string

const (
	// PhraseNoGrounding is the refusal when nothing relevant was retrieved.
	PhraseNoGrounding PhraseKey = "no_grounding"
	// PhraseExtractivePreamble introduces an answer assembled without a model.
	PhraseExtractivePreamble PhraseKey = "extractive_preamble"
	// PhraseSourcesHeading labels the citation list.
	PhraseSourcesHeading PhraseKey = "sources_heading"
	// PhraseBudgetExhausted is returned when the tenant's daily budget is spent.
	PhraseBudgetExhausted PhraseKey = "budget_exhausted"
	// PhraseTranslatedSource warns that the grounding is in another language.
	PhraseTranslatedSource PhraseKey = "translated_source"
	// PhraseCheckWithAgronomist is appended to every low-groundedness answer.
	PhraseCheckWithAgronomist PhraseKey = "check_with_agronomist"
)

// phrases holds each fixed string in every shipped language.
//
// A missing entry falls back to English at lookup rather than to the empty
// string: a blank refusal reads as a bug, and an English refusal reads as an
// untranslated string, which is what it is.
var phrases = map[PhraseKey]map[Locale]string{
	PhraseNoGrounding: {
		LocaleEN: "I do not have information about this in your records or in the reference material available to me, so I am not going to guess.",
		LocaleHI: "आपके रिकॉर्ड या मेरे पास उपलब्ध संदर्भ सामग्री में इसकी जानकारी नहीं है, इसलिए मैं अनुमान नहीं लगाऊँगा।",
		LocaleMR: "तुमच्या नोंदींमध्ये किंवा माझ्याकडील संदर्भ साहित्यात याची माहिती नाही, त्यामुळे मी अंदाज बांधणार नाही.",
		LocaleTE: "మీ రికార్డులలో గానీ నా వద్ద ఉన్న సూచన సామగ్రిలో గానీ దీని సమాచారం లేదు, కాబట్టి నేను ఊహించి చెప్పను.",
		LocaleTA: "உங்கள் பதிவுகளிலோ என்னிடம் உள்ள மேற்கோள் ஆவணங்களிலோ இதற்கான தகவல் இல்லை, எனவே நான் ஊகித்துச் சொல்லப் போவதில்லை.",
		LocaleKN: "ನಿಮ್ಮ ದಾಖಲೆಗಳಲ್ಲಿ ಅಥವಾ ನನ್ನ ಬಳಿ ಇರುವ ಉಲ್ಲೇಖ ಸಾಮಗ್ರಿಯಲ್ಲಿ ಇದರ ಮಾಹಿತಿ ಇಲ್ಲ, ಆದ್ದರಿಂದ ನಾನು ಊಹಿಸಿ ಹೇಳುವುದಿಲ್ಲ.",
		LocalePA: "ਤੁਹਾਡੇ ਰਿਕਾਰਡਾਂ ਜਾਂ ਮੇਰੇ ਕੋਲ ਮੌਜੂਦ ਹਵਾਲਾ ਸਮੱਗਰੀ ਵਿੱਚ ਇਸ ਬਾਰੇ ਜਾਣਕਾਰੀ ਨਹੀਂ ਹੈ, ਇਸ ਲਈ ਮੈਂ ਅੰਦਾਜ਼ਾ ਨਹੀਂ ਲਾਵਾਂਗਾ।",
		LocaleBN: "আপনার রেকর্ডে বা আমার কাছে থাকা তথ্যসূত্রে এর কোনো তথ্য নেই, তাই আমি অনুমান করে বলব না।",
	},
	PhraseExtractivePreamble: {
		LocaleEN: "No language model is configured, so this is quoted from your records and the reference material rather than written as an answer:",
		LocaleHI: "कोई भाषा मॉडल कॉन्फ़िगर नहीं है, इसलिए यह उत्तर लिखा नहीं गया है बल्कि आपके रिकॉर्ड और संदर्भ सामग्री से सीधे उद्धृत है:",
		LocaleMR: "कोणतेही भाषा मॉडेल कॉन्फिगर केलेले नाही, त्यामुळे हे उत्तर लिहिलेले नसून तुमच्या नोंदी व संदर्भ साहित्यातून थेट उद्धृत केलेले आहे:",
		LocaleTE: "ఏ భాషా మోడల్ కాన్ఫిగర్ చేయబడలేదు, కాబట్టి ఇది రాసిన సమాధానం కాదు — మీ రికార్డులు మరియు సూచన సామగ్రి నుండి నేరుగా ఉటంకించినది:",
		LocaleTA: "எந்த மொழி மாதிரியும் அமைக்கப்படவில்லை, எனவே இது எழுதப்பட்ட பதில் அல்ல — உங்கள் பதிவுகளிலிருந்தும் மேற்கோள் ஆவணங்களிலிருந்தும் நேரடியாக மேற்கோள் காட்டப்பட்டது:",
		LocaleKN: "ಯಾವುದೇ ಭಾಷಾ ಮಾದರಿ ಸಂರಚಿಸಲಾಗಿಲ್ಲ, ಆದ್ದರಿಂದ ಇದು ಬರೆದ ಉತ್ತರವಲ್ಲ — ನಿಮ್ಮ ದಾಖಲೆಗಳು ಮತ್ತು ಉಲ್ಲೇಖ ಸಾಮಗ್ರಿಯಿಂದ ನೇರವಾಗಿ ಉಲ್ಲೇಖಿಸಲಾಗಿದೆ:",
		LocalePA: "ਕੋਈ ਭਾਸ਼ਾ ਮਾਡਲ ਸੰਰਚਿਤ ਨਹੀਂ ਹੈ, ਇਸ ਲਈ ਇਹ ਲਿਖਿਆ ਜਵਾਬ ਨਹੀਂ — ਤੁਹਾਡੇ ਰਿਕਾਰਡਾਂ ਅਤੇ ਹਵਾਲਾ ਸਮੱਗਰੀ ਵਿੱਚੋਂ ਸਿੱਧਾ ਹਵਾਲਾ ਹੈ:",
		LocaleBN: "কোনো ভাষা মডেল কনফিগার করা নেই, তাই এটি লেখা উত্তর নয় — আপনার রেকর্ড ও তথ্যসূত্র থেকে সরাসরি উদ্ধৃত:",
	},
	PhraseSourcesHeading: {
		LocaleEN: "Sources",
		LocaleHI: "स्रोत",
		LocaleMR: "स्रोत",
		LocaleTE: "మూలాలు",
		LocaleTA: "ஆதாரங்கள்",
		LocaleKN: "ಮೂಲಗಳು",
		LocalePA: "ਸਰੋਤ",
		LocaleBN: "সূত্র",
	},
	PhraseBudgetExhausted: {
		LocaleEN: "This account's advisory budget for today has been used up. It resets at midnight UTC.",
		LocaleHI: "इस खाते का आज का सलाह बजट समाप्त हो गया है। यह UTC मध्यरात्रि को रीसेट होगा।",
		LocaleMR: "या खात्याचे आजचे सल्ला बजेट संपले आहे. ते UTC मध्यरात्री रीसेट होईल.",
		LocaleTE: "ఈ ఖాతా యొక్క నేటి సలహా బడ్జెట్ అయిపోయింది. ఇది UTC అర్ధరాత్రి రీసెట్ అవుతుంది.",
		LocaleTA: "இந்தக் கணக்கின் இன்றைய ஆலோசனை நிதி முடிந்துவிட்டது. இது UTC நள்ளிரவில் மீட்டமைக்கப்படும்.",
		LocaleKN: "ಈ ಖಾತೆಯ ಇಂದಿನ ಸಲಹಾ ಬಜೆಟ್ ಮುಗಿದಿದೆ. ಇದು UTC ಮಧ್ಯರಾತ್ರಿಗೆ ಮರುಹೊಂದಿಸಲ್ಪಡುತ್ತದೆ.",
		LocalePA: "ਇਸ ਖਾਤੇ ਦਾ ਅੱਜ ਦਾ ਸਲਾਹ ਬਜਟ ਖਤਮ ਹੋ ਗਿਆ ਹੈ। ਇਹ UTC ਅੱਧੀ ਰਾਤ ਨੂੰ ਰੀਸੈੱਟ ਹੋਵੇਗਾ।",
		LocaleBN: "এই অ্যাকাউন্টের আজকের পরামর্শ বাজেট শেষ হয়ে গেছে। এটি UTC মধ্যরাতে রিসেট হবে।",
	},
	PhraseTranslatedSource: {
		LocaleEN: "Some of the material this is based on is in another language.",
		LocaleHI: "यह जिस सामग्री पर आधारित है उसका कुछ भाग किसी अन्य भाषा में है।",
		LocaleMR: "हे ज्या साहित्यावर आधारित आहे त्यातील काही भाग दुसऱ्या भाषेत आहे.",
		LocaleTE: "దీనికి ఆధారమైన సామగ్రిలో కొంత భాగం వేరే భాషలో ఉంది.",
		LocaleTA: "இதற்கு ஆதாரமான ஆவணங்களில் சில வேறு மொழியில் உள்ளன.",
		LocaleKN: "ಇದಕ್ಕೆ ಆಧಾರವಾದ ಸಾಮಗ್ರಿಯ ಕೆಲವು ಭಾಗ ಬೇರೆ ಭಾಷೆಯಲ್ಲಿದೆ.",
		LocalePA: "ਜਿਸ ਸਮੱਗਰੀ 'ਤੇ ਇਹ ਅਧਾਰਿਤ ਹੈ, ਉਸ ਦਾ ਕੁਝ ਹਿੱਸਾ ਹੋਰ ਭਾਸ਼ਾ ਵਿੱਚ ਹੈ।",
		LocaleBN: "এটি যে উপাদানের উপর ভিত্তি করে, তার কিছু অংশ অন্য ভাষায়।",
	},
	PhraseCheckWithAgronomist: {
		LocaleEN: "Parts of this could not be matched to a source. Check with an agronomist before acting on it.",
		LocaleHI: "इसका कुछ भाग किसी स्रोत से मेल नहीं खाता। इस पर अमल करने से पहले कृषि विशेषज्ञ से पुष्टि करें।",
		LocaleMR: "याचा काही भाग कोणत्याही स्रोताशी जुळत नाही. यावर कृती करण्यापूर्वी कृषी तज्ज्ञाकडून खात्री करा.",
		LocaleTE: "దీనిలోని కొంత భాగాన్ని ఏ మూలంతోనూ సరిపోల్చలేకపోయాం. దీని ప్రకారం చర్య తీసుకునే ముందు వ్యవసాయ నిపుణుడిని సంప్రదించండి.",
		LocaleTA: "இதன் சில பகுதிகளை எந்த ஆதாரத்துடனும் பொருத்த முடியவில்லை. இதன்படி செயல்படும் முன் வேளாண் நிபுணரிடம் உறுதிப்படுத்துங்கள்.",
		LocaleKN: "ಇದರ ಕೆಲವು ಭಾಗಗಳನ್ನು ಯಾವುದೇ ಮೂಲದೊಂದಿಗೆ ಹೊಂದಿಸಲಾಗಲಿಲ್ಲ. ಇದರ ಪ್ರಕಾರ ಕ್ರಮ ಕೈಗೊಳ್ಳುವ ಮೊದಲು ಕೃಷಿ ತಜ್ಞರನ್ನು ಸಂಪರ್ಕಿಸಿ.",
		LocalePA: "ਇਸ ਦੇ ਕੁਝ ਹਿੱਸੇ ਕਿਸੇ ਸਰੋਤ ਨਾਲ ਮੇਲ ਨਹੀਂ ਖਾਂਦੇ। ਇਸ 'ਤੇ ਅਮਲ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਖੇਤੀ ਮਾਹਿਰ ਤੋਂ ਪੁਸ਼ਟੀ ਕਰੋ।",
		LocaleBN: "এর কিছু অংশ কোনো সূত্রের সঙ্গে মেলানো যায়নি। এই অনুযায়ী কাজ করার আগে কৃষি বিশেষজ্ঞের সঙ্গে যাচাই করুন।",
	},
}

// Phrase returns a fixed string in the given locale, falling back to English.
func Phrase(key PhraseKey, locale Locale) string {
	byLocale, ok := phrases[key]
	if !ok {
		return ""
	}
	if s, ok := byLocale[locale.OrDefault()]; ok && s != "" {
		return s
	}
	return byLocale[LocaleEN]
}

// ── Digits ───────────────────────────────────────────────────────────────────

// indicDigitBases are the code points of zero in each Indic digit block.
//
// Needed because the groundedness check works on the numbers in an answer, and
// an answer written in Hindi may write them as ४५ rather than 45. Without this
// the number check would find no numbers in every non-Latin answer and pass
// every one of them — a check that always passes is worse than no check, since
// it reports a verdict.
var indicDigitBases = []rune{
	0x0966, // Devanagari — Hindi, Marathi
	0x09E6, // Bengali
	0x0A66, // Gurmukhi — Punjabi
	0x0AE6, // Gujarati
	0x0B66, // Oriya
	0x0BE6, // Tamil
	0x0C66, // Telugu
	0x0CE6, // Kannada
	0x0D66, // Malayalam
}

// NormalizeDigits rewrites Indic digits as ASCII, leaving everything else be.
func NormalizeDigits(s string) string {
	if !strings.ContainsFunc(s, isIndicDigit) {
		return s
	}
	var b strings.Builder
	b.Grow(len(s))
	for _, r := range s {
		if v, ok := indicDigitValue(r); ok {
			b.WriteRune(rune('0' + v))
			continue
		}
		b.WriteRune(r)
	}
	return b.String()
}

func indicDigitValue(r rune) (int, bool) {
	for _, base := range indicDigitBases {
		if r >= base && r <= base+9 {
			return int(r - base), true
		}
	}
	return 0, false
}

func isIndicDigit(r rune) bool {
	_, ok := indicDigitValue(r)
	return ok
}

// sentenceTerminators end a sentence in the scripts this platform ships.
//
// The danda (।) and double danda (॥) are the full stop in Devanagari and are
// used in Bengali and Gurmukhi text too. Splitting on '.' alone would treat a
// whole Hindi paragraph as one sentence, and a groundedness score computed
// over one enormous "sentence" is either 0 or 1 and means nothing either way.
func isSentenceTerminator(r rune) bool {
	switch r {
	case '.', '!', '?', '\n', '।', '॥', '؟':
		return true
	}
	return false
}

// SplitSentences breaks text into sentences across Latin and Indic scripts.
func SplitSentences(text string) []string {
	var out []string
	var cur strings.Builder

	flush := func() {
		s := strings.TrimSpace(cur.String())
		cur.Reset()
		if s == "" {
			return
		}
		// Drop fragments with no letters at all — a bare bullet or a stray
		// number is not a claim, and counting it as an unsupported sentence
		// drags the score down for punctuation.
		if !strings.ContainsFunc(s, unicode.IsLetter) {
			return
		}
		out = append(out, s)
	}

	runes := []rune(text)
	for i, r := range runes {
		// A full stop between two digits is a decimal point.
		//
		// Without this, "apply 4.1 tonnes" is two sentences — "apply 4" and "1
		// tonnes" — and every decimal quantity in every answer is silently
		// split into two integers. The quantity check then compares 4 and 1
		// against the sources, finds them in a page number or a year, and
		// reports a fabricated 4.1 as perfectly well supported.
		if r == '.' && i > 0 && i+1 < len(runes) &&
			isDecimalDigit(runes[i-1]) && isDecimalDigit(runes[i+1]) {
			cur.WriteRune(r)
			continue
		}
		if isSentenceTerminator(r) {
			if r != '\n' {
				cur.WriteRune(r)
			}
			flush()
			continue
		}
		cur.WriteRune(r)
	}
	flush()
	return out
}

func isDecimalDigit(r rune) bool {
	if r >= '0' && r <= '9' {
		return true
	}
	return isIndicDigit(r)
}

// Tokenize lowercases and splits text into word tokens.
//
// Splits on anything that is not a letter or a digit, which works for
// Devanagari, Bengali, Gurmukhi, Tamil, Telugu and Kannada as well as Latin;
// a regexp over [a-z0-9] would silently reduce every Indic string to no tokens
// at all.
func Tokenize(text string) []string {
	text = NormalizeDigits(text)
	fields := strings.FieldsFunc(strings.ToLower(text), func(r rune) bool {
		return !unicode.IsLetter(r) && !unicode.IsDigit(r)
	})
	out := fields[:0]
	for _, f := range fields {
		if f != "" {
			out = append(out, f)
		}
	}
	return out
}
