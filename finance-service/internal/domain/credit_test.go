package domain

import (
	"strings"
	"testing"
	"time"
)

var creditNow = time.Date(2026, time.September, 15, 0, 0, 0, 0, time.UTC)

func factorNamed(t *testing.T, a CreditAssessment, code string) ScoreFactor {
	t.Helper()
	for _, f := range a.Factors {
		if f.Code == code {
			return f
		}
	}
	t.Fatalf("no %s factor on the assessment", code)
	return ScoreFactor{}
}

// The rule the whole assessment turns on: a thin file is not a bad file.
func TestATooShortRecordProducesNoScoreAtAll(t *testing.T) {
	assessment := AssessCredit("farm-1", historyOf(4000, 3800), creditNow)

	if assessment.Status != ScoreInsufficientHistory {
		t.Fatalf("status = %s, want INSUFFICIENT_HISTORY", assessment.Status)
	}
	if assessment.Score != 0 {
		t.Errorf("score = %d; a farmer with two harvests must not be handed a number "+
			"that reads like a default history", assessment.Score)
	}
	if assessment.Band != "" {
		t.Errorf("band = %s; there is no band without a score", assessment.Band)
	}
	if !strings.Contains(assessment.Caveat, "indistinguishable") {
		t.Errorf("the caveat does not explain why there is no score: %q", assessment.Caveat)
	}
}

func TestAnAssessmentAlwaysCarriesItsCaveat(t *testing.T) {
	for name, history := range map[string][]YieldSeason{
		"thin":  historyOf(4000),
		"solid": steadyHistory(8, 4000),
	} {
		assessment := AssessCredit("farm-1", history, creditNow)
		if !strings.Contains(assessment.Caveat, "not a lending decision") {
			t.Errorf("%s: the assessment does not say it is not a lending decision: %q",
				name, assessment.Caveat)
		}
		if !strings.Contains(assessment.Caveat, "other borrowing") {
			t.Errorf("%s: the caveat does not say what it cannot see: %q", name, assessment.Caveat)
		}
	}
}

// Every factor has to carry its own arithmetic, or the score cannot be argued
// with — and a credit reading nobody can contest is the kind that excludes
// people for reasons nobody can name.
func TestTheFactorsAddUpToTheScore(t *testing.T) {
	assessment := AssessCredit("farm-1",
		historyOf(3800, 4100, 3900, 4200, 4000, 4300), creditNow)

	if assessment.Status != ScoreScored {
		t.Fatalf("status = %s, want SCORED", assessment.Status)
	}
	if len(assessment.Factors) == 0 {
		t.Fatal("the score has no factors behind it")
	}

	total := float64(baseScore)
	for _, f := range assessment.Factors {
		if f.Explanation == "" {
			t.Errorf("factor %s has no explanation", f.Code)
		}
		total += f.Points
	}
	if int(total+0.5) != assessment.Score {
		t.Errorf("the factors sum to %.0f but the score is %d", total, assessment.Score)
	}
}

// Variability, not level, is what a season's repayment depends on.
func TestASteadyFarmScoresAboveAVolatileOneAtTheSameMean(t *testing.T) {
	steady := AssessCredit("farm-1", historyOf(3000, 3000, 3000, 3000, 3000, 3000), creditNow)
	volatile := AssessCredit("farm-2", historyOf(5000, 1000, 5000, 1000, 5000, 1000), creditNow)

	if steady.Score <= volatile.Score {
		t.Errorf("steady farm scores %d and the volatile one %d at the same mean yield",
			steady.Score, volatile.Score)
	}
	if volatile.YieldVariability <= steady.YieldVariability {
		t.Error("the volatile farm's variability is not measured as higher")
	}
}

// A farm on poor land that reliably produces 1.5 t/ha is a predictable
// borrower. Scoring it against a district mean would punish it for its soil.
func TestABadSeasonIsMeasuredAgainstTheFarmsOwnNormal(t *testing.T) {
	poorButSteady := AssessCredit("farm-1",
		historyOf(1500, 1500, 1500, 1500, 1500, 1500), creditNow)

	losses := factorNamed(t, poorButSteady, "LOSS_FREQUENCY")
	if losses.Points < 0 {
		t.Errorf("a field that reliably produces 1.5 t/ha was penalised %.0f points for "+
			"bad seasons; it has not had one", losses.Points)
	}
}

func TestRepeatedFailuresAreCountedAgainstTheScore(t *testing.T) {
	failing := AssessCredit("farm-1", historyOf(4000, 500, 4200, 400, 3900, 600), creditNow)

	losses := factorNamed(t, failing, "LOSS_FREQUENCY")
	if losses.Points >= 0 {
		t.Errorf("three of six seasons below 60%% of the farm's own average scored "+
			"%.0f points", losses.Points)
	}
}

// A farm that records revenue and not costs would otherwise show a profit
// equal to its revenue and beat one that keeps honest books.
func TestMissingCostDataNeitherHelpsNorHurts(t *testing.T) {
	noCosts := make([]YieldSeason, 0, 6)
	for i := 0; i < 6; i++ {
		noCosts = append(noCosts, YieldSeason{
			Year: 2020 + i, Crop: "wheat", YieldKgHa: 4000, AreaHa: 2,
		})
	}

	assessment := AssessCredit("farm-1", noCosts, creditNow)
	profitability := factorNamed(t, assessment, "PROFITABILITY")

	if profitability.Points != 0 {
		t.Errorf("profitability scored %.0f with no cost data recorded; it should be "+
			"neutral", profitability.Points)
	}
	if !strings.Contains(profitability.Explanation, "most improve it") {
		t.Errorf("the factor does not tell the farmer what to do about it: %q",
			profitability.Explanation)
	}
}

func TestALossMakingFarmIsPenalised(t *testing.T) {
	losing := make([]YieldSeason, 0, 6)
	for i := 0; i < 6; i++ {
		losing = append(losing, YieldSeason{
			Year: 2020 + i, Crop: "wheat", YieldKgHa: 4000,
			AreaHa: 2, ProfitPerHa: -8000,
		})
	}

	assessment := AssessCredit("farm-1", losing, creditNow)
	if factorNamed(t, assessment, "PROFITABILITY").Points >= 0 {
		t.Error("a farm losing money every season was not penalised on profitability")
	}
	if assessment.IndicativeLimit != 0 {
		t.Errorf("indicative limit = %.0f for a loss-making farm", assessment.IndicativeLimit)
	}
}

// Weighting record depth heavily would make the score a proxy for how long
// somebody has been on the platform rather than for how they farm.
func TestRecordDepthIsAModestFactor(t *testing.T) {
	short := AssessCredit("farm-1", steadyHistory(3, 4000), creditNow)
	long := AssessCredit("farm-2", steadyHistory(12, 4000), creditNow)

	gap := long.Score - short.Score
	if gap <= 0 {
		t.Errorf("a twelve-season record scores %d against a three-season one's %d",
			long.Score, short.Score)
	}
	if gap > 80 {
		t.Errorf("record depth moved the score by %d points; it should not dominate "+
			"how the farm actually performs", gap)
	}
}

func TestDiversificationIsRewarded(t *testing.T) {
	monoculture := steadyHistory(6, 4000)

	mixed := make([]YieldSeason, len(monoculture))
	copy(mixed, monoculture)
	crops := []string{"wheat", "chickpea", "mustard"}
	for i := range mixed {
		mixed[i].Crop = crops[i%len(crops)]
	}

	single := AssessCredit("farm-1", monoculture, creditNow)
	multi := AssessCredit("farm-2", mixed, creditNow)

	if multi.Score <= single.Score {
		t.Errorf("a three-crop farm scores %d and a monoculture %d", multi.Score, single.Score)
	}
}

func TestScoreStaysInRange(t *testing.T) {
	for name, history := range map[string][]YieldSeason{
		"disastrous": historyOf(6000, 100, 200, 150, 5800, 120, 180, 90),
		"exemplary":  steadyHistory(15, 5000),
	} {
		assessment := AssessCredit("farm-1", history, creditNow)
		if assessment.Score < minScore || assessment.Score > maxScore {
			t.Errorf("%s: score %d is outside %d-%d", name, assessment.Score, minScore, maxScore)
		}
	}
}

func TestBandsFollowTheScore(t *testing.T) {
	cases := map[int]CreditBand{
		320: BandPoor,
		549: BandPoor,
		550: BandFair,
		679: BandFair,
		680: BandGood,
		779: BandGood,
		780: BandExcellent,
		900: BandExcellent,
	}
	for score, want := range cases {
		if got := bandFor(score); got != want {
			t.Errorf("bandFor(%d) = %s, want %s", score, got, want)
		}
	}
}

// Seasons with no recorded yield are not a harvest and must not count towards
// the minimum that unlocks a score.
func TestUnharvestedSeasonsDoNotCountTowardsTheMinimum(t *testing.T) {
	history := []YieldSeason{
		{Year: 2023, Crop: "wheat", YieldKgHa: 4000, AreaHa: 2},
		{Year: 2024, Crop: "wheat", YieldKgHa: 0, AreaHa: 2},
		{Year: 2025, Crop: "wheat", YieldKgHa: 0, AreaHa: 2},
	}

	assessment := AssessCredit("farm-1", history, creditNow)
	if assessment.Status != ScoreInsufficientHistory {
		t.Fatalf("status = %s; two blank seasons were counted as harvests", assessment.Status)
	}
	if assessment.SeasonsConsidered != 1 {
		t.Errorf("seasons considered = %d, want 1", assessment.SeasonsConsidered)
	}
}
