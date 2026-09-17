package domain

import (
	"strings"
	"time"
	"unicode"
)

// Budget is one tenant's ceiling on advisory spend.
type Budget struct {
	TenantID             string
	DailyCostMicros      int64
	DailyQuestionLimit   int
	RequestLatencyBudget time.Duration

	SpentCostMicros int64
	SpentQuestions  int
	// WindowStart is midnight UTC of the day the spend above belongs to.
	WindowStart time.Time
}

// Budget defaults, applied when a tenant has no row of its own.
//
// Deliberately present rather than unlimited. A service that calls a metered
// API on behalf of whoever asks, with no ceiling until an operator sets one,
// has its first incident on the day someone points a script at it — and the
// bill arrives before the alert does. A default that is generous for a person
// and ruinous for a loop is the right shape.
const (
	DefaultDailyCostMicros      int64 = 2_000_000 // 2 units of the billing currency
	DefaultDailyQuestionLimit         = 200
	DefaultRequestLatencyBudget       = 25 * time.Second
)

// DefaultBudget is what a tenant gets before anyone configures it.
func DefaultBudget(tenantID string, now time.Time) Budget {
	return Budget{
		TenantID:             tenantID,
		DailyCostMicros:      DefaultDailyCostMicros,
		DailyQuestionLimit:   DefaultDailyQuestionLimit,
		RequestLatencyBudget: DefaultRequestLatencyBudget,
		WindowStart:          DayStart(now),
	}
}

// DayStart is midnight UTC of the day containing t.
func DayStart(t time.Time) time.Time {
	t = t.UTC()
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC)
}

// WindowResetsAt is when the daily counters go back to zero.
func (b Budget) WindowResetsAt() time.Time {
	return DayStart(b.WindowStart).Add(24 * time.Hour)
}

// Rolled returns the budget with its counters cleared if the day has turned.
//
// Done in the domain rather than by a scheduled job. A nightly reset task that
// does not run leaves every tenant permanently exhausted, and the failure is
// silent until someone asks a question; deriving the window from the clock on
// every read cannot fail to run.
func (b Budget) Rolled(now time.Time) Budget {
	start := DayStart(now)
	if b.WindowStart.Equal(start) {
		return b
	}
	b.WindowStart = start
	b.SpentCostMicros = 0
	b.SpentQuestions = 0
	return b
}

// ExhaustedReason returns why the budget is spent, or "" when it is not.
func (b Budget) ExhaustedReason() string {
	if b.DailyQuestionLimit > 0 && b.SpentQuestions >= b.DailyQuestionLimit {
		return "daily question limit reached"
	}
	if b.DailyCostMicros > 0 && b.SpentCostMicros >= b.DailyCostMicros {
		return "daily cost budget reached"
	}
	return ""
}

// Exhausted reports whether any configured ceiling has been hit.
func (b Budget) Exhausted() bool { return b.ExhaustedReason() != "" }

// LatencyBudget is the per-request ceiling, with the default applied.
func (b Budget) LatencyBudget() time.Duration {
	if b.RequestLatencyBudget <= 0 {
		return DefaultRequestLatencyBudget
	}
	return b.RequestLatencyBudget
}

// WithSpend adds one exchange's usage to the window.
func (b Budget) WithSpend(u Usage) Budget {
	b.SpentCostMicros += u.CostMicros
	b.SpentQuestions++
	return b
}

// ── Cost ─────────────────────────────────────────────────────────────────────

// ModelPrice is what one model costs, per million tokens, in micros.
type ModelPrice struct {
	InputMicrosPerMillion  int64
	OutputMicrosPerMillion int64
}

// EstimateCostMicros prices one exchange.
//
// Prices are configuration, not a constant compiled in here: they change, they
// differ per contract, and a stale table baked into the binary would enforce a
// budget in a currency that no longer matches the invoice. An unpriced model
// costs zero and the caller is expected to say so in the log rather than
// pretend the exchange was free.
func EstimateCostMicros(price ModelPrice, promptTokens, completionTokens int) int64 {
	if promptTokens < 0 {
		promptTokens = 0
	}
	if completionTokens < 0 {
		completionTokens = 0
	}
	in := price.InputMicrosPerMillion * int64(promptTokens) / 1_000_000
	out := price.OutputMicrosPerMillion * int64(completionTokens) / 1_000_000
	return in + out
}

// EstimateTokens approximates a token count for the pre-flight budget check.
//
// Only an estimate, and only used before the call — the reported usage that is
// billed and stored comes back from the provider. It is here because a budget
// checked only after the fact is not a budget: the request that blows through
// the ceiling is the one that already ran.
//
// Latin text runs about four characters per token. Devanagari, Bengali,
// Gurmukhi, Tamil, Telugu and Kannada run far worse on byte-pair vocabularies
// trained mostly on English — commonly under two characters per token — so
// they are counted separately. Treating a Telugu question as four characters
// per token would underestimate it threefold, which is exactly the direction
// that lets a budget be exceeded rather than enforced.
func EstimateTokens(text string) int {
	var latin, other int
	for _, r := range text {
		if r <= unicode.MaxASCII {
			latin++
			continue
		}
		if unicode.IsSpace(r) {
			latin++
			continue
		}
		other++
	}
	tokens := latin/4 + other*2/3
	if tokens < 1 && strings.TrimSpace(text) != "" {
		return 1
	}
	return tokens
}
