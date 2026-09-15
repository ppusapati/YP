package domain

import (
	"fmt"
	"math"
	"sort"
	"strings"
	"time"
)

// CreditBand is the coarse reading of a credit score.
type CreditBand string

const (
	BandPoor      CreditBand = "POOR"
	BandFair      CreditBand = "FAIR"
	BandGood      CreditBand = "GOOD"
	BandExcellent CreditBand = "EXCELLENT"
)

// ScoreStatus says whether a score could be produced at all.
type ScoreStatus string

const (
	ScoreScored ScoreStatus = "SCORED"
	// ScoreInsufficientHistory is its own outcome, not a low score. A farmer
	// with one harvest on record has not demonstrated bad repayment capacity —
	// they have demonstrated nothing, and a number that reads like a default
	// history is the difference between waiting a season and being turned away.
	ScoreInsufficientHistory ScoreStatus = "INSUFFICIENT_HISTORY"
)

// ScoreFactor is one thing that moved the score, and by how much.
type ScoreFactor struct {
	Code        string  `json:"code"`
	Label       string  `json:"label"`
	Points      float64 `json:"points"`
	Value       float64 `json:"value"`
	Explanation string  `json:"explanation"`
}

// CreditAssessment is a repayment-capacity reading built from farm records.
type CreditAssessment struct {
	ID       string `json:"id" db:"id"`
	TenantID string `json:"tenant_id" db:"tenant_id"`
	FarmID   string `json:"farm_id" db:"farm_id"`

	Status ScoreStatus `json:"status" db:"status"`
	Score  int         `json:"score" db:"score"`
	Band   CreditBand  `json:"band" db:"band"`

	Factors []ScoreFactor `json:"factors" db:"factors"`

	SeasonsConsidered int     `json:"seasons_considered" db:"seasons_considered"`
	MeanYieldKgHa     float64 `json:"mean_yield_kg_ha" db:"mean_yield_kg_ha"`
	YieldVariability  float64 `json:"yield_variability" db:"yield_variability"`
	MeanProfitPerHa   float64 `json:"mean_profit_per_hectare" db:"mean_profit_per_hectare"`
	IndicativeLimit   float64 `json:"indicative_limit" db:"indicative_limit"`

	Caveat     string    `json:"caveat" db:"caveat"`
	AssessedAt time.Time `json:"assessed_at" db:"assessed_at"`
}

// Score range, matching what Indian lenders read.
const (
	minScore  = 300
	maxScore  = 900
	baseScore = 550
)

// minSeasonsToScore is the shortest record that can carry a score.
//
// Three harvested seasons. Two points describe a line through any two numbers
// and say nothing about variability, which is most of what a lender is buying.
const minSeasonsToScore = 3

// Band thresholds.
const (
	bandFairFrom      = 550
	bandGoodFrom      = 680
	bandExcellentFrom = 780
)

// workingCapitalMultiple turns demonstrated profit into an indicative limit.
//
// One season's mean profit across the farm's cropped area, which is roughly
// what a crop loan is for. Deliberately conservative and deliberately called
// indicative: this service has no sight of the farmer's other borrowing, and a
// limit that ignored existing debt would be the most dangerous number here.
const workingCapitalMultiple = 1.0

// standardCaveat is attached to every assessment.
const standardCaveat = "This is a reading of the harvest records held on this platform. " +
	"It is not a lending decision and it does not see the farmer's other " +
	"borrowing, their repayment history with any lender, or any land or asset " +
	"they hold. A lender's own checks decide."

// AssessCredit reads a farm's harvest record into a score.
//
// Every factor carries its own points and the measurement behind them, because
// a score a farmer cannot take apart is one they cannot contest — and a credit
// reading that cannot be contested is the kind that quietly excludes people for
// reasons nobody can name.
//
// A record too short to read produces INSUFFICIENT_HISTORY and no score at all.
// Emitting 420 for a farmer with one harvest would be indistinguishable from
// emitting 420 for one who lost three crops in a row.
func AssessCredit(farmID string, history []YieldSeason, now time.Time) CreditAssessment {
	assessment := CreditAssessment{
		FarmID:     farmID,
		AssessedAt: now,
		Caveat:     standardCaveat,
	}

	usable := make([]YieldSeason, 0, len(history))
	for _, season := range history {
		if season.YieldKgHa > 0 {
			usable = append(usable, season)
		}
	}
	sort.Slice(usable, func(i, j int) bool { return usable[i].Year < usable[j].Year })
	assessment.SeasonsConsidered = len(usable)

	if len(usable) < minSeasonsToScore {
		assessment.Status = ScoreInsufficientHistory
		assessment.Caveat = fmt.Sprintf(
			"This farm has %d harvested season%s on record and a score needs at least "+
				"%d. No score has been produced, because a number here would be "+
				"indistinguishable from one earned by a farm that did badly. %s",
			len(usable), plural(len(usable)), minSeasonsToScore, standardCaveat)
		return assessment
	}

	assessment.Status = ScoreScored
	assessment.MeanYieldKgHa = meanYield(usable)
	assessment.YieldVariability = coefficientOfVariation(usable)
	assessment.MeanProfitPerHa = meanProfit(usable)

	assessment.Factors = []ScoreFactor{
		stabilityFactor(assessment.YieldVariability),
		trendFactor(usable),
		recordDepthFactor(len(usable)),
		profitabilityFactor(usable),
		lossFrequencyFactor(usable),
		diversificationFactor(usable),
	}

	score := float64(baseScore)
	for _, factor := range assessment.Factors {
		score += factor.Points
	}
	assessment.Score = int(math.Round(clamp(score, minScore, maxScore)))
	assessment.Band = bandFor(assessment.Score)
	assessment.IndicativeLimit = indicativeLimit(usable)

	return assessment
}

// stabilityFactor rewards a predictable yield.
//
// Variability, not level, is what a crop lender is exposed to: a farm averaging
// 3 t/ha every year is a better risk than one alternating 5 and 1, even though
// the second has the higher mean.
func stabilityFactor(cv float64) ScoreFactor {
	// A CV of 0.15 is steady for a rainfed Indian field; 0.45 is a farm whose
	// income halves in a bad year.
	points := 0.0
	switch {
	case cv <= 0.15:
		points = 110
	case cv <= 0.25:
		points = 70
	case cv <= 0.35:
		points = 20
	case cv <= 0.50:
		points = -40
	default:
		points = -90
	}

	return ScoreFactor{
		Code:   "YIELD_STABILITY",
		Label:  "Yield stability",
		Points: points,
		Value:  cv,
		Explanation: fmt.Sprintf(
			"Yields vary by %.0f%% around their average. Variability, not the average "+
				"itself, is what a season's repayment depends on.", cv*100),
	}
}

// trendFactor reads the direction of travel.
func trendFactor(history []YieldSeason) ScoreFactor {
	slope := yieldSlope(history)
	mean := meanYield(history)

	relative := 0.0
	if mean > 0 {
		relative = slope / mean
	}

	points := clamp(relative*400, -60, 60)
	direction := "flat"
	switch {
	case relative > 0.02:
		direction = "improving"
	case relative < -0.02:
		direction = "declining"
	}

	return ScoreFactor{
		Code:   "YIELD_TREND",
		Label:  "Yield trend",
		Points: points,
		Value:  relative,
		Explanation: fmt.Sprintf(
			"Yields are %s at about %.1f%% a year across the record.", direction, relative*100),
	}
}

// recordDepthFactor rewards a longer record — modestly.
//
// Modestly on purpose. A farm with ten years of records is better understood
// than one with three, but it is not ten years' worth better, and weighting
// this heavily would make the score a proxy for how long someone has been on
// the platform rather than for how they farm.
func recordDepthFactor(seasons int) ScoreFactor {
	points := clamp(float64(seasons-minSeasonsToScore)*8, 0, 50)
	return ScoreFactor{
		Code:   "RECORD_DEPTH",
		Label:  "Depth of record",
		Points: points,
		Value:  float64(seasons),
		Explanation: fmt.Sprintf(
			"%d harvested season%s on record. A longer record makes every other "+
				"factor here more reliable.", seasons, plural(seasons)),
	}
}

// profitabilityFactor reads demonstrated margin.
//
// Only counted where cost data exists. A farm that records revenue and not
// costs would otherwise show a profit equal to its revenue and score better
// than one that keeps honest books.
func profitabilityFactor(history []YieldSeason) ScoreFactor {
	withCosts := 0
	for _, season := range history {
		if season.ProfitPerHa != 0 {
			withCosts++
		}
	}

	if withCosts == 0 {
		return ScoreFactor{
			Code:   "PROFITABILITY",
			Label:  "Profitability",
			Points: 0,
			Value:  0,
			Explanation: "No cost or revenue figures are recorded, so margin could not " +
				"be read. This neither helps nor hurts the score — but recording them " +
				"is the single thing that would most improve it.",
		}
	}

	profit := meanProfit(history)
	points := 0.0
	switch {
	case profit <= 0:
		points = -80
	case profit < 15000:
		points = 10
	case profit < 35000:
		points = 55
	default:
		points = 90
	}

	return ScoreFactor{
		Code:   "PROFITABILITY",
		Label:  "Profitability",
		Points: points,
		Value:  profit,
		Explanation: fmt.Sprintf(
			"An average margin of ₹%.0f per hectare across %d season%s with cost data.",
			profit, withCosts, plural(withCosts)),
	}
}

// lossFrequencyFactor counts the seasons well below the farm's own normal.
//
// Against the farm's own average rather than a regional one: a farm on poor
// land that reliably produces 1.5 t/ha is a predictable borrower, and scoring
// it against a district mean would punish it for its soil rather than for its
// farming.
func lossFrequencyFactor(history []YieldSeason) ScoreFactor {
	mean := meanYield(history)
	if mean <= 0 {
		return ScoreFactor{Code: "LOSS_FREQUENCY", Label: "Bad seasons"}
	}

	bad := 0
	for _, season := range history {
		if season.YieldKgHa < mean*0.6 {
			bad++
		}
	}
	share := float64(bad) / float64(len(history))
	points := clamp(-share*250, -100, 0)

	return ScoreFactor{
		Code:   "LOSS_FREQUENCY",
		Label:  "Bad seasons",
		Points: points,
		Value:  share,
		Explanation: fmt.Sprintf(
			"%d of %d seasons came in below 60%% of this farm's own average.",
			bad, len(history)),
	}
}

// diversificationFactor rewards growing more than one thing.
func diversificationFactor(history []YieldSeason) ScoreFactor {
	crops := map[string]bool{}
	for _, season := range history {
		crop := strings.ToLower(strings.TrimSpace(season.Crop))
		if crop != "" {
			crops[crop] = true
		}
	}

	points := clamp(float64(len(crops)-1)*15, 0, 45)
	return ScoreFactor{
		Code:   "DIVERSIFICATION",
		Label:  "Crop diversification",
		Points: points,
		Value:  float64(len(crops)),
		Explanation: fmt.Sprintf(
			"%d distinct crop%s in the record. A farm that grows one thing fails "+
				"with it.", len(crops), plural(len(crops))),
	}
}

// indicativeLimit is a borrowing capacity from the records, not an offer.
func indicativeLimit(history []YieldSeason) float64 {
	profit := meanProfit(history)
	if profit <= 0 {
		return 0
	}

	area := 0.0
	for _, season := range history {
		if season.AreaHa > area {
			area = season.AreaHa
		}
	}
	if area <= 0 {
		return 0
	}
	return profit * area * workingCapitalMultiple
}

func bandFor(score int) CreditBand {
	switch {
	case score >= bandExcellentFrom:
		return BandExcellent
	case score >= bandGoodFrom:
		return BandGood
	case score >= bandFairFrom:
		return BandFair
	default:
		return BandPoor
	}
}

func meanYield(history []YieldSeason) float64 {
	if len(history) == 0 {
		return 0
	}
	sum := 0.0
	for _, season := range history {
		sum += season.YieldKgHa
	}
	return sum / float64(len(history))
}

func meanProfit(history []YieldSeason) float64 {
	sum, n := 0.0, 0
	for _, season := range history {
		if season.ProfitPerHa != 0 {
			sum += season.ProfitPerHa
			n++
		}
	}
	if n == 0 {
		return 0
	}
	return sum / float64(n)
}

// coefficientOfVariation is the standard deviation over the mean.
//
// Relative rather than absolute, so a 2 t/ha farm and a 6 t/ha one are
// comparable — a 500 kg swing is routine on the second and ruinous on the first.
func coefficientOfVariation(history []YieldSeason) float64 {
	mean := meanYield(history)
	if mean <= 0 || len(history) < 2 {
		return 0
	}

	variance := 0.0
	for _, season := range history {
		d := season.YieldKgHa - mean
		variance += d * d
	}
	variance /= float64(len(history) - 1)

	return math.Sqrt(variance) / mean
}

// yieldSlope is the least-squares trend in kg/ha per year.
func yieldSlope(history []YieldSeason) float64 {
	if len(history) < 2 {
		return 0
	}

	var sumX, sumY, sumXY, sumXX float64
	n := float64(len(history))
	for _, season := range history {
		x := float64(season.Year)
		y := season.YieldKgHa
		sumX += x
		sumY += y
		sumXY += x * y
		sumXX += x * x
	}

	denominator := n*sumXX - sumX*sumX
	if denominator == 0 {
		return 0
	}
	return (n*sumXY - sumX*sumY) / denominator
}
