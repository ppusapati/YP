package domain

import (
	"fmt"
	"strings"
)

// BuildSystemPrompt writes the instructions the model answers under.
//
// Three things it has to get right, in this order:
//
//   - Ground or refuse. The model is told, explicitly, that "I don't know" is
//     an acceptable answer and an invented quantity is not. Without that, a
//     model asked an agronomy question it has no context for will answer from
//     its training data, in confident prose, and the farmer has no way to tell
//     that apart from an answer drawn from their own soil test.
//
//   - Cite by marker. The evaluator and the UI both key off [n]; an answer
//     with no markers cannot be traced back to anything.
//
//   - Answer in the language asked. Named explicitly and in its own script,
//     because a model given Telugu context and an English instruction will
//     often answer in English.
func BuildSystemPrompt(locale Locale, toolNames []string) string {
	locale = locale.OrDefault()

	var b strings.Builder
	b.WriteString("You are an agronomy advisor for smallholder and commercial farms in India. ")
	b.WriteString("You are answering a specific farmer about their own fields.\n\n")

	b.WriteString("Rules you must follow:\n")
	b.WriteString("1. Answer only from the CONTEXT below and from the results of any tools you call. ")
	b.WriteString("Do not use general knowledge to fill gaps.\n")
	b.WriteString("2. If the context does not answer the question, say so plainly and stop. ")
	b.WriteString("Saying you do not know is correct and expected. Guessing a dose rate, a spacing, a spray interval or a price is not.\n")
	b.WriteString("3. Cite every factual claim with the bracketed number of the context item it came from, like [2]. ")
	b.WriteString("Every quantity you give must appear in the context you cite.\n")
	b.WriteString("4. Never state a figure the context does not contain. If the context gives a range, give the range.\n")
	b.WriteString(fmt.Sprintf("5. Write the entire answer in %s (%s), including units and crop names, "+
		"even when the context is in another language.\n", locale.EnglishName(), locale.NativeName()))
	b.WriteString("6. Be brief and practical. The person reading this is standing in a field, often on a phone.\n")

	if len(toolNames) > 0 {
		b.WriteString("\nYou can call these tools to get this farm's own current numbers rather than guessing: ")
		b.WriteString(strings.Join(toolNames, ", "))
		b.WriteString(".\nPrefer a tool result over a general document when the question is about this farmer's own field. ")
		b.WriteString("Each tool result arrives with its own bracketed number at the start; ")
		b.WriteString("cite it with that number exactly as you would a context item.\n")
	}

	b.WriteString("\nSafety: for anything involving pesticide dosage, re-entry intervals or pre-harvest intervals, ")
	b.WriteString("give only what the cited label or advisory states, and tell the farmer to read the product label.\n")

	return b.String()
}

// BuildContextBlock renders the citations the model is allowed to use.
func BuildContextBlock(citations []Citation) string {
	if len(citations) == 0 {
		return "CONTEXT: (nothing was retrieved for this question)\n"
	}
	var b strings.Builder
	b.WriteString("CONTEXT:\n")
	for _, c := range citations {
		b.WriteString(fmt.Sprintf("[%d] %s", c.Marker, c.Title))
		if c.Locale.IsSupported() {
			b.WriteString(" (" + c.Locale.EnglishName() + ")")
		}
		b.WriteString("\n")
		b.WriteString(c.Snippet)
		b.WriteString("\n\n")
	}
	return b.String()
}

// ExtractiveAnswer assembles an answer without a model.
//
// Used when no LLM is configured. It quotes the retrieved passages under a
// preamble that says exactly that, so the reader knows they are looking at
// source material rather than at advice written for them. It is deliberately
// not dressed up to look like a generated answer: the two are not equivalent
// and presenting them identically would be the more convenient lie.
func ExtractiveAnswer(citations []Citation, locale Locale) string {
	locale = locale.OrDefault()
	if len(citations) == 0 {
		return Phrase(PhraseNoGrounding, locale)
	}

	var b strings.Builder
	b.WriteString(Phrase(PhraseExtractivePreamble, locale))
	b.WriteString("\n\n")

	// Three passages, not eight. An extractive answer is already harder to
	// read than a written one; pasting the whole context under it produces
	// something nobody finishes.
	limit := 3
	if len(citations) < limit {
		limit = len(citations)
	}
	for _, c := range citations[:limit] {
		b.WriteString(fmt.Sprintf("[%d] %s\n", c.Marker, c.Title))
		b.WriteString(Snippet(c.Snippet, 600))
		b.WriteString("\n\n")
	}

	if HasForeignLocale(citations[:limit], locale) {
		b.WriteString(Phrase(PhraseTranslatedSource, locale))
		b.WriteString("\n")
	}
	return strings.TrimSpace(b.String())
}

// ConversationHistory renders earlier turns for a follow-up question.
//
// Answers are included but their citation markers are stripped, because the
// markers in a previous answer refer to that turn's context, which is not this
// turn's. Leaving them in gets them copied into the new answer, pointing at
// whatever happens to be numbered the same this time — a citation that looks
// checkable and is wrong.
func ConversationHistory(previous []Exchange, maxTurns int) string {
	if len(previous) == 0 {
		return ""
	}
	if maxTurns > 0 && len(previous) > maxTurns {
		previous = previous[len(previous)-maxTurns:]
	}

	var b strings.Builder
	b.WriteString("EARLIER IN THIS CONVERSATION:\n")
	for _, ex := range previous {
		b.WriteString("Q: " + Snippet(ex.Question, 300) + "\n")
		b.WriteString("A: " + Snippet(stripCitationMarkers(ex.Answer), 600) + "\n")
	}
	b.WriteString("\n")
	return b.String()
}
