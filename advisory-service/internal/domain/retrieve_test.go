package domain

import (
	"strings"
	"testing"
	"time"
)

func TestAssembleContextRefusesAForeignTenant(t *testing.T) {
	// The repository filters by tenant and the tables have row-level security,
	// so this can only happen if one of those has broken. It fails the request
	// rather than dropping the row: a silently filtered breach leaves nothing
	// behind to investigate.
	_, err := AssembleContext("tenant-a", []Citation{
		{ID: "1", TenantID: "tenant-a", Title: "Mine", Snippet: "ok"},
		{ID: "2", TenantID: "tenant-b", Title: "Theirs", Snippet: "not ok"},
	})
	if err == nil {
		t.Fatal("a citation belonging to another tenant must fail the request")
	}
	if !strings.Contains(err.Error(), "an internal error occurred") {
		t.Errorf("the error must not leak the other tenant's data, got %q", err.Error())
	}
}

func TestAssembleContextNumbersCitationsFromOne(t *testing.T) {
	got, err := AssembleContext("t", []Citation{
		{ID: "a", TenantID: "t", Title: "One", Snippet: "x"},
		{ID: "b", TenantID: "t", Title: "Two", Snippet: "y"},
	})
	if err != nil {
		t.Fatal(err)
	}
	if got[0].Marker != 1 || got[1].Marker != 2 {
		t.Fatalf("markers = %d, %d; want 1, 2", got[0].Marker, got[1].Marker)
	}
}

func TestAssembleContextStaysInsideTheRuneBudget(t *testing.T) {
	long := strings.Repeat("क", 5000)
	var citations []Citation
	for i := 0; i < 10; i++ {
		citations = append(citations, Citation{ID: string(rune('a' + i)), TenantID: "t", Title: "T", Snippet: long})
	}

	got, err := AssembleContext("t", citations)
	if err != nil {
		t.Fatal(err)
	}

	var used int
	for _, c := range got {
		used += len([]rune(c.Snippet)) + len([]rune(c.Title))
	}
	if used > ContextBudgetRunes {
		t.Fatalf("assembled %d runes of context, budget is %d", used, ContextBudgetRunes)
	}
	if len(got) == 0 {
		t.Fatal("the budget should trim the context, not empty it")
	}
}

func TestRankCitationsPrefersTheAskedLocaleWithoutExcludingOthers(t *testing.T) {
	candidates := []Citation{
		{ID: "en", TenantID: "t", Title: "Wheat top dressing", Snippet: ureaPassage, Score: 0.5, Locale: LocaleEN},
		{ID: "hi", TenantID: "t", Title: "गेहूं में यूरिया", Snippet: "यूरिया दो भागों में डालें।", Score: 0.5, Locale: LocaleHI},
	}
	ranked := RankCitations("urea top dressing for wheat", candidates, LocaleHI)

	if len(ranked) != 2 {
		t.Fatalf("a source in another language must still be offered, got %d", len(ranked))
	}
	// The English passage shares every word with the question, so lexical
	// overlap should still carry it above a same-locale passage that does not.
	if ranked[0].ID != "en" {
		t.Errorf("expected the passage that actually answers the question first, got %q", ranked[0].ID)
	}
}

func TestHasForeignLocale(t *testing.T) {
	if !HasForeignLocale([]Citation{{Locale: LocaleEN}}, LocaleTA) {
		t.Error("an English source under a Tamil question is a foreign locale")
	}
	if HasForeignLocale([]Citation{{Locale: LocaleTA}}, LocaleTA) {
		t.Error("a Tamil source under a Tamil question is not")
	}
}

func TestBudgetRollsAtMidnightUTC(t *testing.T) {
	day1 := time.Date(2026, 3, 1, 23, 59, 0, 0, time.UTC)
	b := DefaultBudget("t", day1)
	b = b.WithSpend(Usage{CostMicros: 1_500_000})
	b.SpentQuestions = 199

	if b.Exhausted() {
		t.Fatal("not exhausted yet")
	}

	day2 := day1.Add(2 * time.Minute)
	rolled := b.Rolled(day2)
	if rolled.SpentCostMicros != 0 || rolled.SpentQuestions != 0 {
		t.Fatalf("the window should have rolled, got %+v", rolled)
	}
	if !rolled.WindowStart.Equal(DayStart(day2)) {
		t.Errorf("window start = %v", rolled.WindowStart)
	}
}

func TestBudgetExhaustionReasons(t *testing.T) {
	now := time.Now().UTC()
	b := DefaultBudget("t", now)
	b.SpentQuestions = DefaultDailyQuestionLimit
	if b.ExhaustedReason() != "daily question limit reached" {
		t.Errorf("reason = %q", b.ExhaustedReason())
	}

	b = DefaultBudget("t", now)
	b.SpentCostMicros = DefaultDailyCostMicros
	if b.ExhaustedReason() != "daily cost budget reached" {
		t.Errorf("reason = %q", b.ExhaustedReason())
	}

	// Zero means unconfigured, not zero-tolerance. A tenant with cost tracking
	// switched off should not be refused on the first question.
	b = Budget{TenantID: "t", WindowStart: DayStart(now)}
	b.SpentQuestions = 10_000
	if b.Exhausted() {
		t.Error("an unconfigured ceiling must not block")
	}
}

func TestEstimateTokensCountsIndicScriptsHigher(t *testing.T) {
	// Same sentence, two scripts. Charging Telugu at the Latin rate is the
	// direction that lets a budget be exceeded rather than enforced.
	latin := EstimateTokens("Apply sixty kilograms of urea per hectare at first irrigation")
	telugu := EstimateTokens("మొదటి నీటిపారుదల సమయంలో హెక్టారుకు అరవై కిలోల యూరియా వేయండి")
	if telugu <= latin {
		t.Errorf("Telugu estimate %d should exceed the Latin estimate %d", telugu, latin)
	}
}

func TestEstimateCostMicros(t *testing.T) {
	price := ModelPrice{InputMicrosPerMillion: 3_000_000, OutputMicrosPerMillion: 15_000_000}
	got := EstimateCostMicros(price, 1_000_000, 100_000)
	want := int64(3_000_000 + 1_500_000)
	if got != want {
		t.Errorf("cost = %d, want %d", got, want)
	}
	if EstimateCostMicros(ModelPrice{}, 1_000_000, 1_000_000) != 0 {
		t.Error("an unpriced model should cost zero rather than guess")
	}
}
