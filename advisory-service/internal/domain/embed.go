package domain

import (
	"hash/fnv"
	"math"
	"strconv"
	"strings"
)

// DefaultEmbeddingDim is the width of a stored vector.
//
// 384 to match the smallest widely-deployed sentence-transformer, so a
// deployment that later points EMBEDDING_URL at a real model does not have to
// reindex to change the column type. The dimension is fixed per database by
// the migration; a mismatch is rejected at write time rather than silently
// truncated, because a truncated vector still has a cosine similarity and the
// nonsense it produces looks exactly like a weak match.
const DefaultEmbeddingDim = 384

// LexicalVector builds a deterministic vector from text by feature hashing.
//
// This is NOT a semantic embedding, and nothing in this service pretends it
// is. It is a hashed bag of words and character n-grams: it will match "urea
// top dressing" to "top dressing with urea" and will not match it to "nitrogen
// application", because it has no idea those are related. It exists so that a
// deployment with no embedding endpoint still has working retrieval rather
// than an empty context and an assistant that refuses every question — and so
// that the retrieval path is exercised in tests without a network call.
//
// Character 4-grams are mixed in alongside word tokens because Telugu, Kannada
// and Tamil agglutinate: "పొలంలో" and "పొలం" are the same word inflected, and
// word-level hashing alone treats them as unrelated, which would make lexical
// retrieval markedly worse in exactly the languages that most need it.
func LexicalVector(text string, dim int) []float32 {
	if dim <= 0 {
		dim = DefaultEmbeddingDim
	}
	counts := make(map[uint64]float64)

	tokens := Tokenize(text)
	for i, tok := range tokens {
		counts[hash64("w:"+tok)]++
		if i+1 < len(tokens) {
			counts[hash64("b:"+tok+" "+tokens[i+1])]++
		}
		for _, gram := range charNGrams(tok, 4) {
			counts[hash64("c:"+gram)] += 0.5
		}
	}

	vec := make([]float32, dim)
	for h, count := range counts {
		idx := int(h % uint64(dim))
		// Sublinear term frequency. A crop guide that says "nitrogen" forty
		// times should not be forty times more about nitrogen than one that
		// says it once.
		weight := 1 + math.Log(count)
		// A second bit of the same hash decides the sign, so two features
		// colliding on one index cancel as often as they reinforce. Without it
		// every collision inflates the vector in the same direction and the
		// whole index drifts towards matching everything.
		if h&(1<<63) != 0 {
			weight = -weight
		}
		vec[idx] += float32(weight)
	}

	normalize(vec)
	return vec
}

func charNGrams(token string, n int) []string {
	runes := []rune(token)
	if len(runes) < n {
		return nil
	}
	out := make([]string, 0, len(runes)-n+1)
	for i := 0; i+n <= len(runes); i++ {
		out = append(out, string(runes[i:i+n]))
	}
	return out
}

func hash64(s string) uint64 {
	h := fnv.New64a()
	_, _ = h.Write([]byte(s))
	return h.Sum64()
}

func normalize(vec []float32) {
	var sum float64
	for _, v := range vec {
		sum += float64(v) * float64(v)
	}
	if sum == 0 {
		return
	}
	inv := float32(1 / math.Sqrt(sum))
	for i := range vec {
		vec[i] *= inv
	}
}

// CosineSimilarity of two vectors, 0 when either is empty or of a different
// width.
//
// Mismatched widths return 0 rather than comparing the overlap. Two vectors of
// different dimensions came from different embedders, and scoring them against
// each other produces a number that ranks documents by which model indexed
// them.
func CosineSimilarity(a, b []float32) float64 {
	if len(a) == 0 || len(a) != len(b) {
		return 0
	}
	var dot, na, nb float64
	for i := range a {
		dot += float64(a[i]) * float64(b[i])
		na += float64(a[i]) * float64(a[i])
		nb += float64(b[i]) * float64(b[i])
	}
	if na == 0 || nb == 0 {
		return 0
	}
	return dot / (math.Sqrt(na) * math.Sqrt(nb))
}

// LexicalOverlap is the share of the query's tokens that appear in the text.
//
// Used to rescore vector hits. A hashed vector can rank a passage highly on
// collisions alone; requiring that the passage actually contains some of the
// words asked about is a cheap guard against citing something that shares no
// vocabulary with the question at all.
func LexicalOverlap(query, text string) float64 {
	q := Tokenize(query)
	if len(q) == 0 {
		return 0
	}
	present := make(map[string]struct{}, len(q))
	for _, tok := range Tokenize(text) {
		present[tok] = struct{}{}
	}
	var hit int
	seen := make(map[string]struct{}, len(q))
	for _, tok := range q {
		if _, dup := seen[tok]; dup {
			continue
		}
		seen[tok] = struct{}{}
		if _, ok := present[tok]; ok {
			hit++
		}
	}
	return float64(hit) / float64(len(seen))
}

// VectorLiteral renders a vector in pgvector's text form.
//
// pgvector accepts '[1,2,3]'. Built here rather than with fmt.Sprint on the
// slice, which renders '[1 2 3]' — space-separated, which pgvector rejects at
// insert time on every row.
func VectorLiteral(vec []float32) string {
	if len(vec) == 0 {
		return "[]"
	}
	var b strings.Builder
	b.Grow(len(vec) * 8)
	b.WriteByte('[')
	for i, v := range vec {
		if i > 0 {
			b.WriteByte(',')
		}
		// 'g' with six significant figures: ample for a unit-normalised vector
		// and a third the size of full precision, which matters when a
		// thousand-chunk document is one INSERT per chunk.
		b.WriteString(strconv.FormatFloat(float64(v), 'g', 6, 32))
	}
	b.WriteByte(']')
	return b.String()
}
