package domain

import (
	"strings"
)

// ChunkTargetRunes is roughly how big an indexed passage should be.
//
// Measured in runes rather than bytes: a Telugu paragraph is three bytes per
// character, so a byte-sized chunker would cut Indic documents into passages a
// third the length of the English ones and quietly retrieve worse for exactly
// the languages this platform exists to serve.
const ChunkTargetRunes = 900

// ChunkOverlapRunes is how much of the previous passage each one repeats.
//
// Overlap exists because the sentence that answers a question is often the one
// straddling a boundary. Without it, "apply the second dose at" ends one chunk
// and "45 days after sowing" starts the next, and neither retrieves.
const ChunkOverlapRunes = 150

// MaxChunksPerDocument bounds ingestion.
//
// A 900-rune chunk means this caps a document at roughly 400k characters. A
// larger upload is far more likely to be a mistake — a whole book, a binary
// read as text — than a crop guide, and indexing it would spend the tenant's
// storage and every later query's time on it.
const MaxChunksPerDocument = 500

// ChunkText splits document text into overlapping passages on sentence
// boundaries.
//
// Sentence-aligned rather than fixed-width because a passage that starts
// mid-clause reads as nonsense when it is shown as a citation, and a citation
// nobody can read is not evidence of anything.
func ChunkText(text string) []string {
	text = strings.TrimSpace(text)
	if text == "" {
		return nil
	}

	sentences := SplitSentences(text)
	if len(sentences) == 0 {
		// No sentence terminators anywhere: a wall of text, a table dumped
		// without punctuation, or a language whose terminator is not in the
		// set above. Falling through to one enormous chunk would index the
		// document as a single passage that matches everything weakly and
		// cites unreadably, so it is hard-split instead.
		return hardSplit([]rune(text), ChunkTargetRunes, ChunkOverlapRunes)
	}

	var chunks []string
	var cur []string
	curLen := 0

	flush := func() {
		if len(cur) == 0 {
			return
		}
		chunks = append(chunks, strings.Join(cur, " "))
		cur = nil
		curLen = 0
	}

	for _, sentence := range sentences {
		runes := []rune(sentence)

		// A single sentence longer than a whole chunk — a list rendered as one
		// line, or a paragraph with no full stop. Split it rather than letting
		// it blow past the target.
		if len(runes) > ChunkTargetRunes {
			flush()
			chunks = append(chunks, hardSplit(runes, ChunkTargetRunes, ChunkOverlapRunes)...)
			continue
		}

		if curLen+len(runes) > ChunkTargetRunes {
			flush()
		}
		cur = append(cur, sentence)
		curLen += len(runes) + 1
	}
	flush()

	withOverlap := addOverlap(chunks)
	if len(withOverlap) > MaxChunksPerDocument {
		withOverlap = withOverlap[:MaxChunksPerDocument]
	}
	return withOverlap
}

// addOverlap prefixes each chunk with the tail of the one before it.
func addOverlap(chunks []string) []string {
	if len(chunks) < 2 {
		return chunks
	}
	out := make([]string, 0, len(chunks))
	out = append(out, chunks[0])
	for i := 1; i < len(chunks); i++ {
		prev := []rune(chunks[i-1])
		tail := prev
		if len(prev) > ChunkOverlapRunes {
			tail = prev[len(prev)-ChunkOverlapRunes:]
		}
		out = append(out, strings.TrimSpace(string(tail))+" "+chunks[i])
	}
	return out
}

// hardSplit cuts a rune slice into overlapping windows.
func hardSplit(runes []rune, size, overlap int) []string {
	if size <= 0 {
		return []string{string(runes)}
	}
	if overlap >= size {
		overlap = size / 4
	}
	step := size - overlap

	var out []string
	for start := 0; start < len(runes); start += step {
		end := start + size
		if end > len(runes) {
			end = len(runes)
		}
		piece := strings.TrimSpace(string(runes[start:end]))
		if piece != "" {
			out = append(out, piece)
		}
		if end == len(runes) {
			break
		}
	}
	return out
}

// Snippet trims a passage to something that fits in a citation card.
//
// The result is at most maxRunes long *including* the ellipsis. Truncating to
// maxRunes and then appending one more character is the obvious way to write
// this and returns maxRunes+1, which is fine for a card and not fine for
// anything that is counting against a budget — the caller's arithmetic is then
// wrong by one per trimmed item, every time.
func Snippet(text string, maxRunes int) string {
	text = strings.Join(strings.Fields(text), " ")
	runes := []rune(text)
	if len(runes) <= maxRunes {
		return text
	}
	if maxRunes <= 1 {
		return "…"
	}
	return strings.TrimSpace(string(runes[:maxRunes-1])) + "…"
}
