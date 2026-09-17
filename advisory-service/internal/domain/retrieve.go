package domain

import (
	"sort"

	p9errors "p9e.in/samavaya/packages/errors"
)

// ContextBudgetRunes bounds how much grounding goes into one prompt.
//
// A ceiling in runes rather than in passages: twelve short field records and
// twelve pages of a package of practices are not the same amount of context,
// and pricing a request by passage count is how a bill arrives that nobody
// predicted.
const ContextBudgetRunes = 12000

// MaxCitations bounds how many sources one answer may lean on.
//
// Twenty citations is not twenty times more grounded than five; it is a
// citation list nobody reads, which defeats the point of having one.
const MaxCitations = 8

// RankCitations orders retrieved candidates and keeps the best of them.
//
// The stored vector similarity is blended with how many of the question's own
// words actually appear in the passage. With the lexical embedder those two
// signals are correlated; with a real embedding endpoint they are not, and the
// overlap term is what stops a semantically-adjacent passage about a different
// crop from being cited as though it were about this one.
func RankCitations(question string, candidates []Citation, preferred Locale) []Citation {
	scored := make([]Citation, len(candidates))
	copy(scored, candidates)

	for i := range scored {
		overlap := LexicalOverlap(question, scored[i].Title+" "+scored[i].Snippet)
		score := 0.7*scored[i].Score + 0.3*overlap

		// A small thumb on the scale for material already in the language that
		// was asked in. Not a filter: a Telugu question about a disease whose
		// only guide is in English should still get the English guide, with
		// the answer saying the source was in another language. Excluding it
		// would answer "I don't know" while holding the answer.
		if preferred.IsSupported() && scored[i].Locale == preferred {
			score += 0.05
		}
		scored[i].Score = score
	}

	sort.SliceStable(scored, func(i, j int) bool {
		if scored[i].Score != scored[j].Score {
			return scored[i].Score > scored[j].Score
		}
		// Deterministic tie-break, so two runs over the same corpus cite the
		// same sources and a review of one exchange means something for the
		// next.
		return scored[i].ID < scored[j].ID
	})

	if len(scored) > MaxCitations {
		scored = scored[:MaxCitations]
	}
	return scored
}

// AssembleContext trims the citation list to the context budget and numbers it.
//
// Also the last place tenant ownership is checked. The repository filters by
// tenant and the tables have row-level security, so a foreign row arriving here
// means one of those two has failed — which is the exact moment to stop, not
// to quietly drop the row and carry on with an answer that looks normal. It
// returns an error rather than filtering, because a silently-filtered breach
// leaves no trace that a breach was attempted.
func AssembleContext(tenantID string, citations []Citation) ([]Citation, error) {
	out := make([]Citation, 0, len(citations))
	used := 0

	for _, c := range citations {
		if c.TenantID != "" && c.TenantID != tenantID {
			return nil, p9errors.InternalServer("CROSS_TENANT_CONTEXT",
				"an internal error occurred")
		}

		length := len([]rune(c.Snippet)) + len([]rune(c.Title))
		if used+length > ContextBudgetRunes {
			// Trim rather than drop when there is room for part of it: the
			// head of a passage is usually the part that matched.
			remaining := ContextBudgetRunes - used - len([]rune(c.Title))
			if remaining < 200 {
				break
			}
			c.Snippet = Snippet(c.Snippet, remaining)
			// Measured after trimming, not predicted before it. Snippet adds
			// an ellipsis when it truncates, so assuming the result is exactly
			// `remaining` runes long overruns the budget by one on every
			// trimmed citation — which is the kind of arithmetic that holds
			// until the day a token limit is the thing it overruns.
			length = len([]rune(c.Snippet)) + len([]rune(c.Title))
		}

		c.Marker = len(out) + 1
		out = append(out, c)
		used += length
	}
	return out, nil
}

// HasForeignLocale reports whether any citation is in a language other than the
// one the question was asked in.
func HasForeignLocale(citations []Citation, asked Locale) bool {
	for _, c := range citations {
		if c.Locale.IsSupported() && c.Locale != asked.OrDefault() {
			return true
		}
	}
	return false
}
