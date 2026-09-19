// Package quantile estimates quantiles over a sliding window of samples.
//
// It exists because two places in this module computed percentiles and neither
// computed a percentile.
//
// `observability/graph` indexed an unsorted slice — `values[len*p/100]` — which
// returns whichever sample happened to land at that position, under a comment
// admitting "would need proper sorting for real percentile, but simplified
// here". It also kept only the *first* thousand samples, beneath a comment
// saying "keep recent latencies (last 1000)", so a dependency that degraded
// after its first thousand calls reported a p99 frozen at its healthiest hour.
//
// `loadbalancer/algorithms` set `P50 = mean` and `P95 = 0.95 × max`. The mean
// of a latency distribution sits well above its median because the distribution
// is right-skewed — that is the whole reason anyone asks for a median. And
// `0.95 × max` is an affine transform of the maximum, so it moves only when the
// maximum moves, and the maximum there never decayed: one slow call at startup
// pinned p95 high for the life of the process. Any routing decision keyed on
// p95 was keyed on the worst request ever seen.
//
// Both are used for deciding where to send traffic and when to page someone, so
// a number that merely looks like a percentile is worse than no number.
package quantile

import (
	"math"
	"sort"
	"sync"
)

// Window holds the most recent samples and estimates quantiles over them.
//
// The window slides. A fixed prefix of the first N samples describes the
// service's startup and nothing after it, which is the opposite of what a
// latency percentile is for.
//
// Safe for concurrent use.
type Window struct {
	mu   sync.RWMutex
	buf  []int64
	next int  // where the next sample goes
	full bool // whether buf has wrapped at least once
}

// DefaultSize is the sample count used when none is given.
//
// A thousand samples resolves a p99 to about ten observations, which is enough
// for the figure to move for a reason rather than because one request was slow.
const DefaultSize = 1000

// New returns a window holding at most size samples.
func New(size int) *Window {
	if size <= 0 {
		size = DefaultSize
	}
	return &Window{buf: make([]int64, size)}
}

// Add records one sample, evicting the oldest when the window is full.
func (w *Window) Add(v int64) {
	w.mu.Lock()
	defer w.mu.Unlock()

	w.buf[w.next] = v
	w.next++
	if w.next == len(w.buf) {
		w.next = 0
		w.full = true
	}
}

// Len is how many samples the window currently holds.
func (w *Window) Len() int {
	w.mu.RLock()
	defer w.mu.RUnlock()
	return w.lenLocked()
}

func (w *Window) lenLocked() int {
	if w.full {
		return len(w.buf)
	}
	return w.next
}

// Quantile returns the q-th quantile, q in [0, 1], using linear interpolation
// between the two nearest ranks.
//
// Interpolating rather than picking a nearest rank matters most where it is
// asked most: on a small window, the nearest rank for q=0.99 jumps between two
// samples with nothing in between, so the reported p99 steps rather than moves.
//
// Returns 0 when the window is empty, which callers should distinguish from a
// genuine zero by checking Len.
func (w *Window) Quantile(q float64) int64 {
	if math.IsNaN(q) {
		return 0
	}
	q = math.Min(1, math.Max(0, q))

	w.mu.RLock()
	n := w.lenLocked()
	if n == 0 {
		w.mu.RUnlock()
		return 0
	}
	// Copied, then sorted. Sorting the window in place would reorder the ring
	// and lose which sample is oldest, and it would need the write lock on
	// what is a read.
	sorted := make([]int64, n)
	copy(sorted, w.buf[:n])
	w.mu.RUnlock()

	sort.Slice(sorted, func(i, j int) bool { return sorted[i] < sorted[j] })

	if n == 1 {
		return sorted[0]
	}

	pos := q * float64(n-1)
	lo := int(math.Floor(pos))
	hi := int(math.Ceil(pos))
	if lo == hi {
		return sorted[lo]
	}

	frac := pos - float64(lo)
	return sorted[lo] + int64(math.Round(float64(sorted[hi]-sorted[lo])*frac))
}

// Reset empties the window.
func (w *Window) Reset() {
	w.mu.Lock()
	defer w.mu.Unlock()
	w.next, w.full = 0, false
}
