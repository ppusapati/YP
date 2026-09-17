package domain

import (
	"strings"
	"testing"
)

const ureaPassage = `Urea is applied to irrigated wheat as a split top dressing. ` +
	`The first split of 60 kg per hectare goes in at first irrigation, around 21 days after sowing. ` +
	`The second split of 60 kg per hectare follows at the second irrigation, around 45 days after sowing.`

const spacingPassage = `Recommended row spacing for irrigated wheat is 22 cm between rows. ` +
	`Seed rate is 100 kg per hectare for timely sown crops.`

func TestGroundedAnswerPasses(t *testing.T) {
	answer := "Apply urea as a split top dressing [1]. " +
		"Give 60 kg per hectare at the first irrigation, around 21 days after sowing [1]."

	eval := EvaluateGroundedness(answer, []string{ureaPassage, spacingPassage})

	if eval.Verdict != VerdictGrounded {
		t.Fatalf("verdict = %q (groundedness %.2f, unsupported %+v, numbers %v)",
			eval.Verdict, eval.Groundedness, eval.Unsupported, eval.UnsupportedNumbers)
	}
	if eval.NeedsReview {
		t.Error("a fully grounded answer should not be queued for review")
	}
}

func TestFabricatedQuantityIsCaught(t *testing.T) {
	// The failure this check exists for: prose that matches the source almost
	// word for word, wrapped around a number the source never gives. The
	// sentence-level score alone passes this answer.
	answer := "Apply urea as a split top dressing [1]. " +
		"Give 120 kg per hectare at the first irrigation, around 21 days after sowing [1]."

	eval := EvaluateGroundedness(answer, []string{ureaPassage, spacingPassage})

	if len(eval.UnsupportedNumbers) == 0 {
		t.Fatalf("120 appears in no passage but was not reported; eval = %+v", eval)
	}
	if !contains(eval.UnsupportedNumbers, "120") {
		t.Errorf("expected 120 to be reported, got %v", eval.UnsupportedNumbers)
	}
	if eval.Verdict == VerdictGrounded {
		t.Error("an answer with an invented quantity must not be graded grounded")
	}
	if !eval.NeedsReview {
		t.Error("an answer with an invented quantity must be queued for review")
	}
}

func TestFabricatedQuantityIsCaughtInDevanagariNumerals(t *testing.T) {
	// Same fabrication, written the way a Hindi answer writes it. Without
	// digit normalisation the number check finds no numbers at all and passes
	// every Indic-script answer — a check that cannot fail.
	answer := "यूरिया को दो भागों में डालें [1]। पहली खुराक १२० किलो प्रति हेक्टेयर दें [1]।"

	eval := EvaluateGroundedness(answer, []string{ureaPassage})
	if !contains(eval.UnsupportedNumbers, "१२०") && !contains(eval.UnsupportedNumbers, "120") {
		t.Fatalf("the Devanagari 120 was not reported; eval = %+v", eval)
	}
}

func TestGroundedQuantityInDevanagariNumeralsIsNotFlagged(t *testing.T) {
	answer := "पहली खुराक ६० किलो प्रति हेक्टेयर दें [1]।"
	eval := EvaluateGroundedness(answer, []string{ureaPassage})
	if len(eval.UnsupportedNumbers) != 0 {
		t.Errorf("60 is in the passage; it should not be flagged. got %v", eval.UnsupportedNumbers)
	}
}

func TestUngroundedAnswerIsRejected(t *testing.T) {
	answer := "Intercrop with pigeon pea and apply a foliar spray of zinc sulphate at flowering. " +
		"Mulch the beds with paddy straw to conserve moisture."

	eval := EvaluateGroundedness(answer, []string{ureaPassage, spacingPassage})
	if eval.Verdict != VerdictUngrounded {
		t.Fatalf("verdict = %q, groundedness = %.2f", eval.Verdict, eval.Groundedness)
	}
	if len(eval.Unsupported) == 0 {
		t.Error("expected the unsupported sentences to be listed")
	}
}

func TestEmptyContextGroundsNothing(t *testing.T) {
	eval := EvaluateGroundedness("Apply 60 kg of urea per hectare at 21 days.", nil)
	if eval.Verdict != VerdictUngrounded {
		t.Fatalf("an answer with no context at all must be ungrounded, got %q", eval.Verdict)
	}
	if !eval.NeedsReview {
		t.Error("expected review")
	}
}

func TestSupportIsNotStitchedAcrossPassages(t *testing.T) {
	// The spacing comes from passage 2 and the seed rate from passage 1, and
	// the sentence cites only passage 2. The combination is a recommendation
	// neither source makes — passage 2 says 100 kg per hectare, not 60.
	// Checking quantities against the union of everything retrieved would find
	// 60 in passage 1 and pass this.
	answer := "Sow wheat at 22 cm row spacing with a seed rate of 60 kg per hectare [2]."

	eval := EvaluateGroundedness(answer, []string{ureaPassage, spacingPassage})
	if !contains(eval.UnsupportedNumbers, "60") {
		t.Fatalf("60 is not in the passage this sentence cites; eval = %+v", eval)
	}
	if eval.Verdict == VerdictGrounded {
		t.Errorf("a claim stitched from two passages must not be grounded; eval = %+v", eval)
	}
}

func TestAQuantityIsCheckedAgainstThePassageItCites(t *testing.T) {
	// Both numbers are in the corpus somewhere. Only one of them is in the
	// passage its sentence points at, and that is the one that counts.
	ok := EvaluateGroundedness("Row spacing is 22 cm [2].", []string{ureaPassage, spacingPassage})
	if len(ok.UnsupportedNumbers) != 0 {
		t.Errorf("22 is in passage 2, which the sentence cites; got %v", ok.UnsupportedNumbers)
	}

	wrong := EvaluateGroundedness("Row spacing is 22 cm [1].", []string{ureaPassage, spacingPassage})
	if !contains(wrong.UnsupportedNumbers, "22") {
		t.Errorf("22 is not in passage 1, which the sentence cites; got %v", wrong.UnsupportedNumbers)
	}
}

func TestAnInventedMarkerCannotBorrowAnotherPassagesNumbers(t *testing.T) {
	// [9] when only two passages were given is a citation the model made up.
	// Clamping it to the last passage would let the invented marker inherit
	// that passage's numbers and launder the claim.
	eval := EvaluateGroundedness("Apply 45 kg per hectare [9].", []string{ureaPassage, spacingPassage})
	if !contains(eval.UnsupportedNumbers, "45") {
		t.Fatalf("a quantity cited to a non-existent source must be reported; eval = %+v", eval)
	}
}

func TestDecimalsSurviveSentenceSplitting(t *testing.T) {
	// "4.1" must stay one number. Split on the full stop it becomes 4 and 1,
	// which are common enough to appear in almost any passage — so a
	// fabricated 4.1 would be reported as well supported.
	sentences := SplitSentences("Your forecast is 4.1 tonnes per hectare.")
	if len(sentences) != 1 {
		t.Fatalf("expected one sentence, got %q", sentences)
	}
	eval := EvaluateGroundedness("Your forecast is 4.1 tonnes per hectare.", []string{ureaPassage})
	if !contains(eval.UnsupportedNumbers, "4.1") {
		t.Errorf("expected 4.1 to be reported as one quantity, got %v", eval.UnsupportedNumbers)
	}
}

func TestCitationMarkersDoNotCountAsQuantities(t *testing.T) {
	// [1] and [2] are markers this service asks for. Treating them as claimed
	// quantities would flag every correctly-cited answer.
	answer := "Apply urea as a split top dressing [1]. Row spacing is 22 cm [2]."
	eval := EvaluateGroundedness(answer, []string{ureaPassage, spacingPassage})
	for _, n := range eval.UnsupportedNumbers {
		if n == "1" || n == "2" {
			t.Fatalf("citation marker %q was treated as a quantity", n)
		}
	}
}

func TestToolResultsCountAsContext(t *testing.T) {
	// A number that came back from a service is grounded even though it is in
	// no document. Without this, every tool-derived figure is flagged and the
	// review queue becomes noise reviewers learn to ignore.
	passages := ContextPassages([]Citation{
		{Title: "Wheat top dressing", Snippet: ureaPassage},
		{Kind: CitationYieldForecast, Title: "Yield forecast for this field",
			Snippet: `{"predicted_tonnes_per_hectare":4.1}`},
	})
	eval := EvaluateGroundedness("Your forecast is 4.1 tonnes per hectare [2].", passages)
	if contains(eval.UnsupportedNumbers, "4.1") {
		t.Errorf("a figure returned by a tool should count as grounded, got %v", eval.UnsupportedNumbers)
	}
}

func TestNothingGroundsWithoutACitation(t *testing.T) {
	// A tool call that failed never becomes a citation, so it cannot ground
	// anything. This asserts the consequence: with no citations there are no
	// passages, and an answer quoting the figure the failed call would have
	// returned is reported.
	if passages := ContextPassages(nil); len(passages) != 0 {
		t.Fatalf("no citations means no context, got %q", passages)
	}
	eval := EvaluateGroundedness("Your forecast is 4.1 tonnes per hectare.", ContextPassages(nil))
	if !contains(eval.UnsupportedNumbers, "4.1") {
		t.Errorf("expected 4.1 to be unsupported, got %v", eval.UnsupportedNumbers)
	}
}

func TestDecimalFormattingIsNotAFinding(t *testing.T) {
	eval := EvaluateGroundedness("Row spacing is 22.0 cm [1].", []string{spacingPassage})
	if len(eval.UnsupportedNumbers) != 0 {
		t.Errorf("22.0 and 22 are the same quantity; got %v", eval.UnsupportedNumbers)
	}
}

func TestEvaluationOfBlankAnswer(t *testing.T) {
	eval := EvaluateGroundedness("   \n  ", []string{ureaPassage})
	if eval.Verdict != VerdictUngrounded || !eval.NeedsReview {
		t.Fatalf("a blank answer should be ungrounded and reviewed, got %+v", eval)
	}
	if !strings.Contains(eval.Notes, "no sentences") {
		t.Errorf("expected the note to say why, got %q", eval.Notes)
	}
}

func contains(list []string, want string) bool {
	for _, s := range list {
		if s == want {
			return true
		}
	}
	return false
}
