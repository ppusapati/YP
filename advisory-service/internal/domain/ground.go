package domain

import (
	"fmt"
	"math"
	"regexp"
	"strconv"
	"strings"
)

// Groundedness thresholds.
//
// A sentence counts as supported when this much of its informative weight is
// present in some single context passage. Not all of it: an answer that
// rephrases a passage is still grounded on it, and demanding a full match
// would fail every answer that is not a verbatim quote — which would make the
// evaluator a test of copying rather than of truthfulness.
const (
	sentenceSupportThreshold = 0.6
	groundedThreshold        = 0.8
	ungroundedThreshold      = 0.4
)

// EvaluateGroundedness checks an answer against the context it was given.
//
// Two separate checks, because they fail differently:
//
//   - Sentence support catches an answer that drifts into general knowledge.
//     Scored on informative tokens only, weighted by how rare each one is
//     across the context, so the function words that fill every sentence in
//     every language do not carry the score.
//
//   - Number support catches the failure that actually costs a farmer money.
//     A fabricated dose rate, spacing or interval hides inside a sentence that
//     is otherwise well supported — "apply urea as a top dressing at 120 kg per
//     hectare" scores as grounded on a passage about urea top dressing even
//     when the passage says 60. Every quantity in the answer therefore has to
//     appear in the context as a number, or it is reported.
//
// Neither check can prove an answer true. What they can do is refuse to let an
// answer through unexamined, and mark for review the ones no source supports.
func EvaluateGroundedness(answer string, passages []string) Evaluation {
	// Split before the markers are stripped, so each sentence keeps the
	// citations it made. Which sources a sentence points at is the whole basis
	// of the quantity check below.
	sentences := SplitSentences(answer)
	if len(sentences) == 0 {
		return Evaluation{
			Verdict:      VerdictUngrounded,
			Groundedness: 0,
			NeedsReview:  true,
			Notes:        "the answer contained no sentences to check",
		}
	}

	idf := inverseDocumentFrequency(passages)
	passageTokens := make([]tokenIndex, len(passages))
	for i, p := range passages {
		passageTokens[i] = newTokenIndex(p)
	}

	var supported int
	var unsupported []UnsupportedClaim
	seenNumbers := map[string]struct{}{}
	var unsupportedNumbers []string

	for _, raw := range sentences {
		sentence := stripCitationMarkers(raw)

		coverage := bestCoverage(sentence, passageTokens, idf)
		if coverage >= sentenceSupportThreshold {
			supported++
		} else {
			unsupported = append(unsupported, UnsupportedClaim{
				Text: strings.TrimSpace(sentence),
				Reason: fmt.Sprintf("only %.0f%% of this sentence's informative words appear in any single source passage",
					coverage*100),
			})
		}

		// Quantities are checked against the passages this sentence cites, not
		// against the union of everything retrieved. That distinction is what
		// catches a recommendation stitched from two sources: "sow at 22 cm
		// spacing with a seed rate of 60 kg per hectare [2]" takes the spacing
		// from the passage it cites and the rate from a different one, and the
		// combination is advice neither source gives. Against the union, 60
		// appears somewhere and the claim passes.
		for _, number := range quantitiesIn(sentence) {
			if quantityPresent(number.value, citedNumbers(raw, passages)) {
				continue
			}
			if _, dup := seenNumbers[number.text]; dup {
				continue
			}
			seenNumbers[number.text] = struct{}{}
			unsupportedNumbers = append(unsupportedNumbers, number.text)
		}
	}

	groundedness := float64(supported) / float64(len(sentences))

	eval := Evaluation{
		Groundedness:       groundedness,
		Unsupported:        unsupported,
		UnsupportedNumbers: unsupportedNumbers,
	}

	switch {
	case groundedness >= groundedThreshold && len(unsupportedNumbers) == 0:
		eval.Verdict = VerdictGrounded
	case groundedness < ungroundedThreshold:
		eval.Verdict = VerdictUngrounded
	default:
		eval.Verdict = VerdictPartial
	}

	// A quantity with no source is enough on its own. An answer can be 95%
	// supported prose wrapped around one invented dose rate, and that is the
	// answer most likely to be acted on, because everything around it reads
	// correctly.
	eval.NeedsReview = eval.Verdict != VerdictGrounded || len(unsupportedNumbers) > 0

	if len(unsupportedNumbers) > 0 {
		eval.Notes = "quantities with no source: " + strings.Join(unsupportedNumbers, ", ")
	}
	return eval
}

// bestCoverage is the highest share of a sentence's informative weight found
// in any one passage.
//
// Any *one* passage, not the union of them. Stitching support for half a
// sentence from one document and half from another is how two unrelated
// sources get combined into a claim neither of them makes.
func bestCoverage(sentence string, passages []tokenIndex, idf map[string]float64) float64 {
	tokens := tokenSet(sentence)
	if len(tokens) == 0 {
		return 1
	}

	unseen := unseenWeight(len(passages))

	var total float64
	weights := make(map[string]float64, len(tokens))
	for tok := range tokens {
		w, ok := idf[tok]
		if !ok {
			// A token that appears in no passage at all still has to count
			// against the sentence, or an answer made entirely of words the
			// context never used would score a perfect 1 on an empty
			// denominator.
			w = unseen
		}
		weights[tok] = w
		total += w
	}
	if total == 0 {
		return 1
	}

	best := 0.0
	for _, passage := range passages {
		var matched float64
		for tok, w := range weights {
			if passage.contains(tok) {
				matched += w
			}
		}
		if c := matched / total; c > best {
			best = c
		}
	}
	return best
}

// tokenIndex answers "does this passage use this word", allowing for inflection.
//
// Exact matching alone makes the sentence check a test of copying rather than
// of truthfulness: a source that says "urea is applied" does support an answer
// that says "apply urea", and an evaluator that disagrees flags every
// paraphrase and teaches reviewers that the flag means nothing.
type tokenIndex struct {
	exact map[string]struct{}
	// Tokens bucketed by their first four runes, so the inflection check is a
	// map lookup rather than a scan of the whole passage per word.
	buckets map[string][]string
}

func newTokenIndex(text string) tokenIndex {
	ix := tokenIndex{
		exact:   map[string]struct{}{},
		buckets: map[string][]string{},
	}
	for tok := range tokenSet(text) {
		ix.exact[tok] = struct{}{}
		if key, ok := prefixKey(tok); ok {
			ix.buckets[key] = append(ix.buckets[key], tok)
		}
	}
	return ix
}

func (ix tokenIndex) contains(tok string) bool {
	if _, ok := ix.exact[tok]; ok {
		return true
	}
	key, ok := prefixKey(tok)
	if !ok {
		return false
	}
	for _, candidate := range ix.buckets[key] {
		if sameStem(tok, candidate) {
			return true
		}
	}
	return false
}

func prefixKey(tok string) (string, bool) {
	runes := []rune(tok)
	if len(runes) < minStemRunes {
		return "", false
	}
	return string(runes[:minStemRunes]), true
}

// minStemRunes is how much of two words has to agree before they are treated
// as the same word inflected.
//
// Four. Below that the rule starts matching unrelated words — and, critically,
// numbers: "45" and "450" share two characters, and a quantity check that
// accepted near-misses would defeat the one part of this evaluator that has to
// be exact.
const minStemRunes = 4

// maxStemLengthGap is how much longer one form may be than the other.
//
// Suffixal morphology only: "apply"/"applied", "dressing"/"dressings",
// "పొలం"/"పొలంలో". English and every Indic language this platform ships inflect
// that way. Prefixal changes — "treated"/"untreated" — are deliberately not
// matched, because those two are opposites and matching them would let an
// answer invert its source and still score as supported.
const maxStemLengthGap = 3

func sameStem(a, b string) bool {
	ra, rb := []rune(a), []rune(b)
	shorter := len(ra)
	if len(rb) < shorter {
		shorter = len(rb)
	}
	gap := len(ra) - len(rb)
	if gap < 0 {
		gap = -gap
	}
	if gap > maxStemLengthGap {
		return false
	}

	var common int
	for common < shorter && ra[common] == rb[common] {
		common++
	}
	return common >= minStemRunes && float64(common) >= 0.6*float64(shorter)
}

// inverseDocumentFrequency weights each token by how rare it is in the context.
//
// This is what stands in for a stopword list. The platform answers in eight
// languages and maintaining a stoplist for each is a job that would be done
// once and then rot; "the", "और", "మరియు" and their equivalents all appear in
// nearly every passage, so their weight falls on its own, in any language,
// with no list to maintain.
//
// log(1 + N/df) rather than the textbook log(N/df): the textbook form collapses
// when the context is small, which is the normal case here. With one retrieved
// passage, log((N+1)/(df+0.5)) gives every word in that passage a weight of
// 0.29 while a word the passage does not contain gets the unseen weight — so a
// single unremarkable verb outweighed thirteen matching words and graded a
// correct, faithfully-cited answer as only half supported. This form keeps the
// unseen weight within about a factor of four of a rare seen one at every
// corpus size.
func inverseDocumentFrequency(passages []string) map[string]float64 {
	if len(passages) == 0 {
		return map[string]float64{}
	}
	df := make(map[string]int)
	for _, p := range passages {
		for tok := range tokenSet(p) {
			df[tok]++
		}
	}
	n := float64(len(passages))
	idf := make(map[string]float64, len(df))
	for tok, count := range df {
		idf[tok] = math.Log(1 + n/float64(count))
	}
	return idf
}

// unseenWeight is what a token the context never uses counts for.
//
// It has to be positive, or an answer made entirely of words no source
// contains would divide by zero and score a perfect 1. df is taken as 0.5 —
// half an appearance — which makes an unseen token the heaviest thing in a
// sentence without letting one unusual word single-handedly fail an otherwise
// well-supported one.
func unseenWeight(passages int) float64 {
	if passages <= 0 {
		return 1
	}
	return math.Log(1 + float64(passages)/0.5)
}

func tokenSet(text string) map[string]struct{} {
	tokens := Tokenize(text)
	set := make(map[string]struct{}, len(tokens))
	for _, tok := range tokens {
		// Single characters carry no information and are mostly punctuation
		// survivors and Indic matras split off by tokenisation.
		if len([]rune(tok)) < 2 {
			continue
		}
		set[tok] = struct{}{}
	}
	return set
}

// citationMarker matches the [1] and [2, 3] the assistant is told to write.
var citationMarker = regexp.MustCompile(`\[\s*\d+(\s*,\s*\d+)*\s*\]`)

func stripCitationMarkers(s string) string {
	return citationMarker.ReplaceAllString(s, " ")
}

// numberPattern matches a decimal quantity, with optional thousands separators.
var numberPattern = regexp.MustCompile(`\d+(?:,\d{3})*(?:\.\d+)?`)

// markerPattern pulls the numbers out of a [2] or [1, 3].
var markerPattern = regexp.MustCompile(`\[\s*([\d\s,]+)\]`)

type quantity struct {
	text  string
	value float64
}

// quantitiesIn lists the numbers a sentence states, markers already removed.
func quantitiesIn(sentence string) []quantity {
	var out []quantity
	for _, raw := range numberPattern.FindAllString(NormalizeDigits(sentence), -1) {
		if v, ok := parseQuantity(raw); ok {
			out = append(out, quantity{text: raw, value: v})
		}
	}
	return out
}

// citedNumbers collects every number in the passages a sentence cites.
//
// A sentence with no markers at all falls back to every passage. That is
// deliberately the weaker check: the alternative — treating an uncited
// sentence's numbers as unsupported — would flag the opening line of every
// answer that summarises before citing, and a check that fires on correct
// answers is one reviewers stop reading.
func citedNumbers(sentence string, passages []string) []float64 {
	indices := citedIndices(sentence, len(passages))

	values := make([]float64, 0, 32)
	for _, i := range indices {
		for _, raw := range numberPattern.FindAllString(NormalizeDigits(passages[i]), -1) {
			if v, ok := parseQuantity(raw); ok {
				values = append(values, v)
			}
		}
	}
	return values
}

// citedIndices resolves a sentence's markers to passage positions.
func citedIndices(sentence string, passageCount int) []int {
	matches := markerPattern.FindAllStringSubmatch(sentence, -1)
	if len(matches) == 0 {
		// No markers at all: fall back to the whole context.
		all := make([]int, passageCount)
		for i := range all {
			all[i] = i
		}
		return all
	}

	// Markers were written, so they are the claim about where this came from
	// and they are what gets checked. An empty result here means every marker
	// in the sentence was invented, and nothing then supports its numbers —
	// which is the correct reading, not a reason to fall back to everything.
	var indices []int
	for _, match := range matches {
		for _, part := range strings.Split(match[1], ",") {
			n, err := strconv.Atoi(strings.TrimSpace(part))
			// Markers are 1-based, and one past the end of the context is a
			// citation the model made up. Skipped rather than clamped:
			// clamping would let a fabricated [9] borrow passage 8's numbers
			// and launder the claim.
			if err != nil || n < 1 || n > passageCount {
				continue
			}
			indices = append(indices, n-1)
		}
	}
	return indices
}

func parseQuantity(raw string) (float64, bool) {
	v, err := strconv.ParseFloat(strings.ReplaceAll(raw, ",", ""), 64)
	if err != nil {
		return 0, false
	}
	return v, true
}

// quantityPresent compares numerically rather than textually.
//
// "45", "45.0" and "45.00" are the same quantity, and flagging an answer that
// wrote a source's 45.0 as 45 would fill the review queue with formatting.
// The tolerance is relative so it behaves the same for a seed rate of 20 and a
// plant population of 55000.
func quantityPresent(value float64, context []float64) bool {
	for _, c := range context {
		if math.Abs(c-value) <= 1e-6*math.Max(1, math.Abs(value)) {
			return true
		}
	}
	return false
}

// ContextPassages flattens what the answer was allowed to see, in marker order.
//
// Position matters: passages[n-1] is what the answer's [n] refers to. The
// quantity check resolves a sentence's markers through this slice, so a list
// built in any other order would check each number against the wrong source
// and produce findings that look specific and are arbitrary.
//
// One list, because a successful tool call becomes a citation like anything
// else: a figure that came back from the yield service is grounded even though
// it is in no document, and an evaluator that only looked at documents would
// flag every tool-derived number as invented — which would train reviewers to
// ignore the flag. A tool call that *failed* never becomes a citation, so it
// grounds nothing, which is the behaviour wanted and is enforced by the shape
// of the data rather than by a check that could be forgotten.
func ContextPassages(citations []Citation) []string {
	highest := 0
	for _, c := range citations {
		if c.Marker > highest {
			highest = c.Marker
		}
	}

	if highest == 0 {
		// Nothing has been numbered yet — the caller is evaluating a bare list.
		// Input order is the best available reading of "[1] is the first one".
		passages := make([]string, 0, len(citations))
		for _, c := range citations {
			passages = append(passages, c.Title+". "+c.Snippet)
		}
		return passages
	}

	passages := make([]string, highest)
	for _, c := range citations {
		if c.Marker >= 1 && c.Marker <= highest {
			passages[c.Marker-1] = c.Title + ". " + c.Snippet
		}
	}
	return passages
}
