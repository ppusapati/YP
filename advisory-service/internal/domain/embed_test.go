package domain

import (
	"strings"
	"testing"
)

func TestLexicalVectorIsDeterministic(t *testing.T) {
	// Determinism is not a nicety here. The vector is written at ingestion and
	// the query vector is built at read time by the same function; if the two
	// disagreed across processes, retrieval would return nothing and look like
	// an empty corpus.
	a := LexicalVector("urea top dressing for irrigated wheat", DefaultEmbeddingDim)
	b := LexicalVector("urea top dressing for irrigated wheat", DefaultEmbeddingDim)
	if len(a) != DefaultEmbeddingDim {
		t.Fatalf("dimension = %d", len(a))
	}
	for i := range a {
		if a[i] != b[i] {
			t.Fatalf("vectors differ at %d: %v vs %v", i, a[i], b[i])
		}
	}
}

func TestLexicalVectorRanksTheRelatedPassageHigher(t *testing.T) {
	query := LexicalVector("how much urea for wheat top dressing", DefaultEmbeddingDim)
	related := LexicalVector(ureaPassage, DefaultEmbeddingDim)
	unrelated := LexicalVector(
		"Drip irrigation lateral spacing for banana is 1.8 metres with 4 litre per hour emitters.",
		DefaultEmbeddingDim)

	if CosineSimilarity(query, related) <= CosineSimilarity(query, unrelated) {
		t.Fatalf("related %.4f should beat unrelated %.4f",
			CosineSimilarity(query, related), CosineSimilarity(query, unrelated))
	}
}

func TestLexicalVectorMatchesInflectedTeluguThroughCharacterNGrams(t *testing.T) {
	// Word-level hashing alone treats "పొలం" and "పొలంలో" as unrelated, which
	// is most of Telugu, Kannada and Tamil.
	a := LexicalVector("పొలం", DefaultEmbeddingDim)
	b := LexicalVector("పొలంలో", DefaultEmbeddingDim)
	if CosineSimilarity(a, b) <= 0 {
		t.Fatalf("an inflected form should still share n-grams, similarity = %.4f",
			CosineSimilarity(a, b))
	}
}

func TestCosineSimilarityRefusesMismatchedWidths(t *testing.T) {
	// Two vectors of different widths came from different embedders, and
	// scoring them would rank documents by which model indexed them.
	if got := CosineSimilarity([]float32{1, 0, 0}, []float32{1, 0}); got != 0 {
		t.Errorf("similarity = %v, want 0", got)
	}
	if got := CosineSimilarity(nil, nil); got != 0 {
		t.Errorf("similarity = %v, want 0", got)
	}
}

func TestVectorLiteralIsCommaSeparated(t *testing.T) {
	// pgvector parses '[1,2,3]' and rejects '[1 2 3]', which is what
	// fmt.Sprint on a slice produces — on every row, at insert time.
	got := VectorLiteral([]float32{0.5, -0.25, 0})
	if !strings.HasPrefix(got, "[") || !strings.HasSuffix(got, "]") {
		t.Fatalf("literal = %q", got)
	}
	if strings.Contains(got, " ") {
		t.Fatalf("literal must not contain spaces, got %q", got)
	}
	if strings.Count(got, ",") != 2 {
		t.Fatalf("literal = %q", got)
	}
}

func TestLexicalOverlap(t *testing.T) {
	if got := LexicalOverlap("urea wheat", "urea is applied to wheat"); got != 1 {
		t.Errorf("overlap = %.2f, expected every one of the query's words", got)
	}
	// Exact, not fuzzy: "for" is not in the passage, so two of three. This is
	// the ranking signal, where being strict is fine — the groundedness check
	// is the one that has to tolerate morphology.
	if got := LexicalOverlap("urea for wheat", "urea is applied to wheat"); got < 0.66 || got > 0.67 {
		t.Errorf("overlap = %.2f, want 2/3", got)
	}
	if got := LexicalOverlap("urea for wheat", "banana drip emitters"); got != 0 {
		t.Errorf("overlap = %.2f, want 0", got)
	}
	if got := LexicalOverlap("", "anything"); got != 0 {
		t.Errorf("an empty query cannot overlap anything, got %.2f", got)
	}
}

func TestChunkTextOverlapsAndStaysNearTarget(t *testing.T) {
	var b strings.Builder
	for i := 0; i < 60; i++ {
		b.WriteString("Apply the recommended dose at the correct growth stage. ")
	}
	chunks := ChunkText(b.String())
	if len(chunks) < 2 {
		t.Fatalf("expected the text to split, got %d chunk(s)", len(chunks))
	}
	for i, c := range chunks {
		// The target plus the overlap, plus one sentence's slack.
		if n := len([]rune(c)); n > ChunkTargetRunes+ChunkOverlapRunes+120 {
			t.Errorf("chunk %d is %d runes, target %d", i, n, ChunkTargetRunes)
		}
	}
}

func TestChunkTextHardSplitsTextWithNoSentenceEnd(t *testing.T) {
	// A table or a paragraph with no punctuation. Left alone it becomes one
	// enormous passage that matches everything weakly and cites unreadably.
	wall := strings.Repeat("क", 4000)
	chunks := ChunkText(wall)
	if len(chunks) < 2 {
		t.Fatalf("expected a hard split, got %d chunk(s)", len(chunks))
	}
}

func TestChunkTextIsBoundedPerDocument(t *testing.T) {
	var b strings.Builder
	for i := 0; i < 200_000; i++ {
		b.WriteString("x. ")
	}
	if n := len(ChunkText(b.String())); n > MaxChunksPerDocument {
		t.Fatalf("a document produced %d chunks, cap is %d", n, MaxChunksPerDocument)
	}
}

func TestChunkTextOnEmptyInput(t *testing.T) {
	if got := ChunkText("   \n "); got != nil {
		t.Errorf("expected no chunks, got %q", got)
	}
}
