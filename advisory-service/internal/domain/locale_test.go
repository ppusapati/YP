package domain

import (
	"strings"
	"testing"
)

func TestParseLocaleStripsRegionAndScript(t *testing.T) {
	cases := map[string]Locale{
		"hi":       LocaleHI,
		"hi-IN":    LocaleHI,
		"pa_Guru":  LocalePA,
		"bn-BD":    LocaleBN,
		"TE":       LocaleTE,
		"  ta  ":   LocaleTA,
		"":         LocaleEN,
		"fr":       LocaleEN,
		"kn-IN-u-": LocaleKN,
	}
	for in, want := range cases {
		if got := ParseLocale(in); got != want {
			t.Errorf("ParseLocale(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestNormalizeDigitsCoversEveryShippedScript(t *testing.T) {
	// One sample per script the platform ships, because the number check in
	// the evaluator is a no-op for any script missing from the table — and a
	// no-op check still reports a verdict.
	cases := map[string]string{
		"४५ किलो":  "45 किलो",  // Devanagari — Hindi, Marathi
		"৪৫ কেজি":  "45 কেজি",  // Bengali
		"੪੫ ਕਿੱਲੋ": "45 ਕਿੱਲੋ", // Gurmukhi
		"௪௫ கிலோ":  "45 கிலோ",  // Tamil
		"౪౫ కిలో":  "45 కిలో",  // Telugu
		"೪೫ ಕಿಲೋ":  "45 ಕಿಲೋ",  // Kannada
		"45 kg":    "45 kg",    // already ASCII, untouched
	}
	for in, want := range cases {
		if got := NormalizeDigits(in); got != want {
			t.Errorf("NormalizeDigits(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestSplitSentencesHandlesDanda(t *testing.T) {
	hindi := "यूरिया डालें। दूसरी खुराक ४५ दिन बाद दें। बस।"
	got := SplitSentences(hindi)
	if len(got) != 3 {
		t.Fatalf("expected 3 sentences from Hindi text, got %d: %q", len(got), got)
	}

	latin := "Apply urea. Second dose at 45 days! Any questions?"
	if len(SplitSentences(latin)) != 3 {
		t.Fatalf("expected 3 sentences from Latin text, got %q", SplitSentences(latin))
	}
}

func TestSplitSentencesDropsFragmentsWithNoLetters(t *testing.T) {
	got := SplitSentences("Apply urea.\n\n---\n\n123.\n\nThen irrigate.")
	if len(got) != 2 {
		t.Fatalf("expected the separator and the bare number to be dropped, got %q", got)
	}
}

func TestTokenizeKeepsIndicWords(t *testing.T) {
	// A regexp over [a-z0-9] reduces this to nothing at all, which would make
	// every lexical score zero for every non-Latin language while still
	// returning a number.
	got := Tokenize("పొలంలో ౪౫ కిలోల యూరియా")
	if len(got) < 3 {
		t.Fatalf("expected Telugu words to tokenise, got %q", got)
	}
	var found bool
	for _, tok := range got {
		if tok == "45" {
			found = true
		}
	}
	if !found {
		t.Errorf("expected the Telugu numeral to normalise to 45, got %q", got)
	}
}

func TestPhraseFallsBackToEnglishNotToEmpty(t *testing.T) {
	for _, locale := range SupportedLocales {
		got := Phrase(PhraseNoGrounding, locale)
		if strings.TrimSpace(got) == "" {
			t.Errorf("no refusal phrase for %q", locale)
		}
	}
	if Phrase(PhraseNoGrounding, Locale("zz")) != Phrase(PhraseNoGrounding, LocaleEN) {
		t.Error("an unknown locale should fall back to English")
	}
}

func TestEveryPhraseIsTranslatedIntoEveryShippedLocale(t *testing.T) {
	// The point of the locale item in this epic is that the strings the
	// service writes itself are translated too. An English refusal on a Telugu
	// screen is the failure this test exists to catch.
	for key, byLocale := range phrases {
		for _, locale := range SupportedLocales {
			if strings.TrimSpace(byLocale[locale]) == "" {
				t.Errorf("phrase %q is missing a %s translation", key, locale)
			}
		}
	}
}
