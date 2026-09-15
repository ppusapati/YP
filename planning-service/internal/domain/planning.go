// Package domain holds planning-service's entities and the agronomy.
package domain

import (
	"errors"
	"fmt"
	"strings"
	"time"
)

// Errors the domain returns.
var (
	ErrMissingField   = errors.New("planning: field is required")
	ErrMissingCrop    = errors.New("planning: crop is required")
	ErrUnknownSeason  = errors.New("planning: season is required")
	ErrInvalidArea    = errors.New("planning: area must be positive")
	ErrInvalidYear    = errors.New("planning: year is outside the range this planner covers")
	ErrNotDraft       = errors.New("planning: only a draft plan can be changed")
	ErrVersionStale   = errors.New("planning: the plan was changed by someone else")
	ErrUnknownCrop    = errors.New("planning: this crop is not in the crop calendar")
	ErrSeasonMismatch = errors.New("planning: this crop is not grown in that season")
)

// Season is the Indian cropping calendar.
//
// Not spring/summer/autumn: the calendar here runs on the monsoon, and a
// planner that assumed temperate seasons would put every sowing window in the
// wrong three months.
type Season string

const (
	// Kharif is monsoon-sown, roughly June to October.
	Kharif Season = "KHARIF"
	// Rabi is the winter crop, October to March, on residual moisture or
	// irrigation.
	Rabi Season = "RABI"
	// Zaid is the short summer crop between rabi and kharif; it needs
	// irrigation, because nothing falls out of the sky in April and May.
	Zaid Season = "ZAID"
)

// PlanStatus is where a season plan has got to.
type PlanStatus string

const (
	PlanDraft     PlanStatus = "DRAFT"
	PlanCommitted PlanStatus = "COMMITTED"
	PlanCompleted PlanStatus = "COMPLETED"
	PlanAbandoned PlanStatus = "ABANDONED"
)

// CropFamily groups crops that share soil-borne pathogens and nutrient demands.
//
// The family is what rotation is actually about. Two different crops from the
// same family — tomato then chilli, both Solanaceae — build up the same
// wilts and nematodes in the soil, and a rotation check that compared crop
// names would call that a rotation.
type CropFamily string

const (
	FamilyCereal     CropFamily = "CEREAL"     // Poaceae: wheat, rice, maize, sorghum
	FamilyLegume     CropFamily = "LEGUME"     // Fabaceae: gram, soybean, groundnut
	FamilyBrassica   CropFamily = "BRASSICA"   // mustard, cabbage
	FamilySolanaceae CropFamily = "SOLANACEAE" // tomato, potato, chilli, brinjal
	FamilyCucurbit   CropFamily = "CUCURBIT"   // melon, gourd, cucumber
	FamilyMalvaceae  CropFamily = "MALVACEAE"  // cotton, okra
	FamilyFibre      CropFamily = "FIBRE"      // jute
	FamilyOilseed    CropFamily = "OILSEED"    // sunflower, sesame, castor
	FamilySugar      CropFamily = "SUGAR"      // sugarcane
)

// CropProfile is what the planner knows about one crop.
type CropProfile struct {
	Name   string
	Family CropFamily

	// Seasons the crop is grown in.
	Seasons []Season

	// NitrogenFixedKgHa is what a legume leaves behind for the next crop.
	//
	// Zero for everything else. A legume credit that is ignored means a farmer
	// buys urea they do not need — which is money, and nitrogen that ends up
	// in the groundwater rather than the crop.
	NitrogenFixedKgHa float64

	// NitrogenDemandKgHa is the crop's own requirement, for the budget.
	NitrogenDemandKgHa float64

	// SowingOffsetDays is when the window opens, relative to the season's
	// start, and how long it stays open.
	SowingOffsetDays int
	SowingLengthDays int

	// SeedRateKgHa and SeedCostPerKg drive the seed line of the budget.
	SeedRateKgHa  float64
	SeedCostPerKg float64

	// WaterDemandMm over the season, for the irrigation line.
	WaterDemandMm float64
}

// cropCalendar is what this service knows about Indian field crops.
//
// Deliberately a small, explicit table rather than a lookup against
// crop-service. The rotation and budget rules need the family, the nitrogen
// balance and the sowing offsets together, and a planner that silently fell
// back to defaults for an unknown crop would produce a confident plan for a
// crop it knows nothing about.
var cropCalendar = map[string]CropProfile{
	"rice": {
		Name: "Rice", Family: FamilyCereal, Seasons: []Season{Kharif, Rabi},
		NitrogenDemandKgHa: 120, SowingOffsetDays: 5, SowingLengthDays: 35,
		SeedRateKgHa: 40, SeedCostPerKg: 45, WaterDemandMm: 1200,
	},
	"wheat": {
		Name: "Wheat", Family: FamilyCereal, Seasons: []Season{Rabi},
		NitrogenDemandKgHa: 120, SowingOffsetDays: 20, SowingLengthDays: 30,
		SeedRateKgHa: 100, SeedCostPerKg: 32, WaterDemandMm: 450,
	},
	"maize": {
		Name: "Maize", Family: FamilyCereal, Seasons: []Season{Kharif, Rabi, Zaid},
		NitrogenDemandKgHa: 150, SowingOffsetDays: 0, SowingLengthDays: 30,
		SeedRateKgHa: 20, SeedCostPerKg: 230, WaterDemandMm: 550,
	},
	"sorghum": {
		Name: "Sorghum", Family: FamilyCereal, Seasons: []Season{Kharif, Rabi},
		NitrogenDemandKgHa: 80, SowingOffsetDays: 0, SowingLengthDays: 30,
		SeedRateKgHa: 10, SeedCostPerKg: 180, WaterDemandMm: 400,
	},
	"cotton": {
		Name: "Cotton", Family: FamilyMalvaceae, Seasons: []Season{Kharif},
		NitrogenDemandKgHa: 150, SowingOffsetDays: 0, SowingLengthDays: 30,
		SeedRateKgHa: 2, SeedCostPerKg: 900, WaterDemandMm: 800,
	},
	"soybean": {
		Name: "Soybean", Family: FamilyLegume, Seasons: []Season{Kharif},
		NitrogenFixedKgHa: 60, NitrogenDemandKgHa: 30,
		SowingOffsetDays: 0, SowingLengthDays: 21,
		SeedRateKgHa: 70, SeedCostPerKg: 90, WaterDemandMm: 500,
	},
	"chickpea": {
		Name: "Chickpea", Family: FamilyLegume, Seasons: []Season{Rabi},
		NitrogenFixedKgHa: 40, NitrogenDemandKgHa: 20,
		SowingOffsetDays: 15, SowingLengthDays: 30,
		SeedRateKgHa: 75, SeedCostPerKg: 110, WaterDemandMm: 300,
	},
	"groundnut": {
		Name: "Groundnut", Family: FamilyLegume, Seasons: []Season{Kharif, Zaid},
		NitrogenFixedKgHa: 50, NitrogenDemandKgHa: 25,
		SowingOffsetDays: 0, SowingLengthDays: 25,
		SeedRateKgHa: 100, SeedCostPerKg: 95, WaterDemandMm: 550,
	},
	"pigeonpea": {
		Name: "Pigeon pea", Family: FamilyLegume, Seasons: []Season{Kharif},
		NitrogenFixedKgHa: 55, NitrogenDemandKgHa: 25,
		SowingOffsetDays: 0, SowingLengthDays: 25,
		SeedRateKgHa: 15, SeedCostPerKg: 140, WaterDemandMm: 450,
	},
	"mustard": {
		Name: "Mustard", Family: FamilyBrassica, Seasons: []Season{Rabi},
		NitrogenDemandKgHa: 80, SowingOffsetDays: 10, SowingLengthDays: 25,
		SeedRateKgHa: 5, SeedCostPerKg: 140, WaterDemandMm: 250,
	},
	"sugarcane": {
		Name: "Sugarcane", Family: FamilySugar, Seasons: []Season{Kharif, Rabi},
		NitrogenDemandKgHa: 250, SowingOffsetDays: 0, SowingLengthDays: 45,
		SeedRateKgHa: 6000, SeedCostPerKg: 3, WaterDemandMm: 1800,
	},
	"tomato": {
		Name: "Tomato", Family: FamilySolanaceae, Seasons: []Season{Kharif, Rabi, Zaid},
		NitrogenDemandKgHa: 120, SowingOffsetDays: 0, SowingLengthDays: 30,
		SeedRateKgHa: 0.3, SeedCostPerKg: 9000, WaterDemandMm: 600,
	},
	"chilli": {
		Name: "Chilli", Family: FamilySolanaceae, Seasons: []Season{Kharif, Rabi},
		NitrogenDemandKgHa: 120, SowingOffsetDays: 0, SowingLengthDays: 30,
		SeedRateKgHa: 1, SeedCostPerKg: 6000, WaterDemandMm: 600,
	},
	"potato": {
		Name: "Potato", Family: FamilySolanaceae, Seasons: []Season{Rabi},
		NitrogenDemandKgHa: 180, SowingOffsetDays: 10, SowingLengthDays: 25,
		SeedRateKgHa: 2500, SeedCostPerKg: 22, WaterDemandMm: 500,
	},
	"sunflower": {
		Name: "Sunflower", Family: FamilyOilseed, Seasons: []Season{Rabi, Zaid},
		NitrogenDemandKgHa: 80, SowingOffsetDays: 10, SowingLengthDays: 25,
		SeedRateKgHa: 8, SeedCostPerKg: 380, WaterDemandMm: 450,
	},
}

// LookupCrop returns what the planner knows about a crop.
//
// Returns ok=false rather than a zero profile, because a plan built from an
// empty profile has a sowing window on the season's first day, no nitrogen
// demand and a seed cost of nothing — a confident plan for a crop the service
// knows nothing about.
func LookupCrop(name string) (CropProfile, bool) {
	profile, ok := cropCalendar[normaliseCrop(name)]
	return profile, ok
}

// KnownCrops is every crop in the calendar, for a picker.
func KnownCrops() []string {
	out := make([]string, 0, len(cropCalendar))
	for _, profile := range cropCalendar {
		out = append(out, profile.Name)
	}
	return out
}

func normaliseCrop(name string) string {
	var b strings.Builder
	for _, r := range strings.ToLower(strings.TrimSpace(name)) {
		if r >= 'a' && r <= 'z' {
			b.WriteRune(r)
		}
	}
	return b.String()
}

// GrownIn reports whether the crop is sown in a season.
func (p CropProfile) GrownIn(season Season) bool {
	for _, s := range p.Seasons {
		if s == season {
			return true
		}
	}
	return false
}

// seasonStart is the first day of a season in a given year.
//
// These are the calendar anchors, not the sowing dates: the window is offset
// from here by the crop's own timing, and shifted again when rainfall history
// says the monsoon arrives late in this particular place.
func seasonStart(season Season, year int) (time.Time, bool) {
	switch season {
	case Kharif:
		return time.Date(year, time.June, 1, 0, 0, 0, 0, time.UTC), true
	case Rabi:
		return time.Date(year, time.October, 15, 0, 0, 0, 0, time.UTC), true
	case Zaid:
		return time.Date(year, time.March, 15, 0, 0, 0, 0, time.UTC), true
	default:
		return time.Time{}, false
	}
}

// SowingWindow is when a crop can go in the ground.
type SowingWindow struct {
	Crop   string `json:"crop"`
	Season Season `json:"season"`

	Opens   time.Time `json:"opens"`
	Closes  time.Time `json:"closes"`
	Optimal time.Time `json:"optimal"`

	Basis string `json:"basis"`

	// WeatherInformed is false when the window came from the crop calendar
	// alone. Said out loud rather than presented with the same confidence as
	// one derived from years of rainfall at this field.
	WeatherInformed bool `json:"weather_informed"`
}

// MonsoonOnset is what the weather history says about a field.
type MonsoonOnset struct {
	// DayOfYear the rains typically arrive, averaged over the years available.
	DayOfYear int
	// Years the average is drawn from.
	Years int
}

// minOnsetYears is the shortest rainfall history worth shifting a window by.
//
// Three years. Monsoon onset varies by a fortnight between years, so one or
// two years says nothing — and a sowing window moved on the strength of a
// single wet season is worse than the calendar default, because it looks
// field-specific.
const minOnsetYears = 3

// ComputeSowingWindow works out when a crop can be sown.
//
// With rainfall history the window follows the monsoon's local onset, which is
// what actually decides when a kharif crop goes in; a field in Vidarbha and one
// in Konkan are three weeks apart and the calendar does not know that. Without
// it the window is the crop calendar's, and says so.
func ComputeSowingWindow(crop string, season Season, year int, onset *MonsoonOnset) (SowingWindow, error) {
	profile, ok := LookupCrop(crop)
	if !ok {
		return SowingWindow{}, ErrUnknownCrop
	}
	if !profile.GrownIn(season) {
		return SowingWindow{}, fmt.Errorf("%w: %s is grown in %v, not %s",
			ErrSeasonMismatch, profile.Name, profile.Seasons, season)
	}

	start, ok := seasonStart(season, year)
	if !ok {
		return SowingWindow{}, ErrUnknownSeason
	}

	window := SowingWindow{
		Crop:   profile.Name,
		Season: season,
		Basis:  fmt.Sprintf("%s crop calendar", season),
	}

	// Only kharif follows the monsoon. Rabi is sown after the kharif harvest
	// on residual moisture, and zaid is irrigated by definition — shifting
	// either by rainfall onset would be borrowing a rule from the wrong season.
	if season == Kharif && onset != nil && onset.Years >= minOnsetYears {
		onsetDate := time.Date(year, time.January, 1, 0, 0, 0, 0, time.UTC).
			AddDate(0, 0, onset.DayOfYear-1)
		start = onsetDate
		window.WeatherInformed = true
		window.Basis = fmt.Sprintf(
			"monsoon onset around day %d, averaged over %d years at this field",
			onset.DayOfYear, onset.Years)
	}

	window.Opens = start.AddDate(0, 0, profile.SowingOffsetDays)
	window.Closes = window.Opens.AddDate(0, 0, profile.SowingLengthDays)
	// The middle of the window, where yield potential is usually highest: sown
	// early and the crop meets the heat at flowering, sown late and it runs out
	// of season.
	window.Optimal = window.Opens.AddDate(0, 0, profile.SowingLengthDays/2)

	return window, nil
}

// RotationVerdict is what the rotation check makes of a proposed crop.
type RotationVerdict string

const (
	RotationGood       RotationVerdict = "GOOD"
	RotationAcceptable RotationVerdict = "ACCEPTABLE"
	RotationPoor       RotationVerdict = "POOR"
)

// RotationCheck is the verdict on a crop following what came before it.
type RotationCheck struct {
	Crop         string          `json:"crop"`
	PreviousCrop string          `json:"previous_crop"`
	Verdict      RotationVerdict `json:"verdict"`
	Rationale    string          `json:"rationale"`

	// NitrogenCreditKgHa is what the previous crop left behind.
	NitrogenCreditKgHa float64 `json:"nitrogen_credit_kg_ha"`
}

// CheckRotation judges a crop against what the field grew last.
//
// The comparison is by *family*, not by crop name. Tomato then chilli are two
// different crops and the same Solanaceae, and they build up the same soil-borne
// wilts and nematodes — a check that compared names would call that a rotation
// and let a farmer plant into a problem they cannot see until the crop is in.
//
// An empty previous crop is not a failure. A newly broken field, or one whose
// history predates the platform, gets a neutral verdict that says the history
// is missing rather than a "good" that implies it was checked.
func CheckRotation(crop, previousCrop string) RotationCheck {
	check := RotationCheck{Crop: crop, PreviousCrop: previousCrop}

	profile, ok := LookupCrop(crop)
	if !ok {
		check.Verdict = RotationAcceptable
		check.Rationale = fmt.Sprintf(
			"%s is not in the crop calendar, so its rotation cannot be checked. "+
				"Treat this as unverified rather than approved.", crop)
		return check
	}
	check.Crop = profile.Name

	if strings.TrimSpace(previousCrop) == "" {
		check.Verdict = RotationAcceptable
		check.Rationale = "No previous crop is recorded for this field, so there is " +
			"nothing to check the rotation against."
		return check
	}

	previous, ok := LookupCrop(previousCrop)
	if !ok {
		check.Verdict = RotationAcceptable
		check.Rationale = fmt.Sprintf(
			"The previous crop %q is not in the crop calendar, so the rotation "+
				"cannot be checked.", previousCrop)
		return check
	}
	check.PreviousCrop = previous.Name
	check.NitrogenCreditKgHa = previous.NitrogenFixedKgHa

	switch {
	case previous.Family == profile.Family:
		check.Verdict = RotationPoor
		check.Rationale = fmt.Sprintf(
			"%s and %s are both %s. Growing the same family twice in a row builds "+
				"up the soil-borne diseases and nematodes that survive between "+
				"seasons, and it draws on the same nutrients twice.",
			profile.Name, previous.Name, familyLabel(profile.Family))

	case previous.Family == FamilyLegume:
		check.Verdict = RotationGood
		check.Rationale = fmt.Sprintf(
			"%s follows %s, a legume, which leaves about %.0f kg/ha of nitrogen "+
				"in the soil. Reduce the nitrogen you buy by that much rather than "+
				"applying a full dose.",
			profile.Name, previous.Name, previous.NitrogenFixedKgHa)

	case profile.Family == FamilyLegume:
		check.Verdict = RotationGood
		check.Rationale = fmt.Sprintf(
			"%s is a legume following %s. It fixes about %.0f kg/ha of nitrogen "+
				"for whatever is sown next season, and breaks the disease cycle of "+
				"the previous family.",
			profile.Name, previous.Name, profile.NitrogenFixedKgHa)

	default:
		check.Verdict = RotationAcceptable
		check.Rationale = fmt.Sprintf(
			"%s follows %s — a different family, so the disease cycle is broken. "+
				"A legume in between would also have fixed nitrogen for this crop.",
			profile.Name, previous.Name)
	}

	return check
}

func familyLabel(f CropFamily) string {
	switch f {
	case FamilyCereal:
		return "cereals"
	case FamilyLegume:
		return "legumes"
	case FamilyBrassica:
		return "brassicas"
	case FamilySolanaceae:
		return "in the nightshade family"
	case FamilyCucurbit:
		return "cucurbits"
	case FamilyMalvaceae:
		return "in the mallow family"
	case FamilyOilseed:
		return "oilseeds"
	case FamilySugar:
		return "sugar crops"
	default:
		return strings.ToLower(string(f))
	}
}

// InputKind is a purchased input a plan budgets for.
type InputKind string

const (
	InputSeed       InputKind = "SEED"
	InputFertiliser InputKind = "FERTILISER"
	InputPesticide  InputKind = "PESTICIDE"
	InputLabour     InputKind = "LABOUR"
	InputMachinery  InputKind = "MACHINERY"
	InputIrrigation InputKind = "IRRIGATION"
)

// InputLine is one budgeted purchase.
type InputLine struct {
	Kind      InputKind `json:"kind"`
	Item      string    `json:"item"`
	Quantity  float64   `json:"quantity"`
	Unit      string    `json:"unit"`
	UnitCost  float64   `json:"unit_cost"`
	TotalCost float64   `json:"total_cost"`
	Note      string    `json:"note"`
}

// InputBudget is what a plan expects to spend.
type InputBudget struct {
	Lines          []InputLine `json:"lines"`
	TotalCost      float64     `json:"total_cost"`
	CostPerHectare float64     `json:"cost_per_hectare"`
	Currency       string      `json:"currency"`
}

// Indicative Indian input prices, in rupees.
//
// A budget built from these is an estimate to plan against, not a quote. They
// are named constants rather than magic numbers so the assumption is visible
// to whoever reads a plan that turned out wrong.
const (
	ureaCostPerKgN      = 35.0 // urea is 46% N; this is the cost per kg of N
	dapCostPerKgP       = 95.0
	mopCostPerKgK       = 40.0
	pesticideCostPerHa  = 3500.0
	labourCostPerHa     = 9000.0
	machineryCostPerHa  = 6500.0
	irrigationCostPerMm = 12.0 // per hectare-mm delivered
)

// BuildBudget estimates what a season's inputs will cost.
//
// The nitrogen line is where the rotation earns its keep: a legume predecessor
// leaves nitrogen in the soil, and subtracting that credit is the difference
// between a realistic budget and one that buys urea the field does not need.
// The credit cannot take the requirement below zero — a soil cannot owe
// nitrogen back.
func BuildBudget(crop string, areaHectares float64, nitrogenCreditKgHa float64) (InputBudget, error) {
	profile, ok := LookupCrop(crop)
	if !ok {
		return InputBudget{}, ErrUnknownCrop
	}
	if areaHectares <= 0 {
		return InputBudget{}, ErrInvalidArea
	}

	budget := InputBudget{Currency: "INR"}

	// Seed.
	seedQty := profile.SeedRateKgHa * areaHectares
	budget.Lines = append(budget.Lines, InputLine{
		Kind:      InputSeed,
		Item:      profile.Name + " seed",
		Quantity:  seedQty,
		Unit:      "kg",
		UnitCost:  profile.SeedCostPerKg,
		TotalCost: seedQty * profile.SeedCostPerKg,
	})

	// Nitrogen, net of what the previous crop left.
	netN := profile.NitrogenDemandKgHa - nitrogenCreditKgHa
	note := ""
	if nitrogenCreditKgHa > 0 {
		if netN < 0 {
			netN = 0
			note = fmt.Sprintf(
				"the previous legume left about %.0f kg/ha, more than this crop needs; "+
					"no nitrogen is budgeted", nitrogenCreditKgHa)
		} else {
			note = fmt.Sprintf(
				"%.0f kg/ha of the crop's %.0f kg/ha requirement is covered by the "+
					"previous legume", nitrogenCreditKgHa, profile.NitrogenDemandKgHa)
		}
	}
	nQty := netN * areaHectares
	budget.Lines = append(budget.Lines, InputLine{
		Kind:      InputFertiliser,
		Item:      "Nitrogen (as urea)",
		Quantity:  nQty,
		Unit:      "kg N",
		UnitCost:  ureaCostPerKgN,
		TotalCost: nQty * ureaCostPerKgN,
		Note:      note,
	})

	// Phosphorus and potassium at a conventional share of the nitrogen demand.
	// Not soil-test-driven: that is prescription-service's job, and a planner
	// that pretended otherwise would produce a budget somebody trusted as a
	// recommendation.
	pQty := profile.NitrogenDemandKgHa * 0.5 * areaHectares
	budget.Lines = append(budget.Lines, InputLine{
		Kind: InputFertiliser, Item: "Phosphorus (as DAP)",
		Quantity: pQty, Unit: "kg P", UnitCost: dapCostPerKgP,
		TotalCost: pQty * dapCostPerKgP,
		Note:      "a planning estimate; a soil test and a prescription will refine it",
	})

	kQty := profile.NitrogenDemandKgHa * 0.4 * areaHectares
	budget.Lines = append(budget.Lines, InputLine{
		Kind: InputFertiliser, Item: "Potassium (as MOP)",
		Quantity: kQty, Unit: "kg K", UnitCost: mopCostPerKgK,
		TotalCost: kQty * mopCostPerKgK,
	})

	// Per-hectare operating costs.
	for _, line := range []struct {
		kind InputKind
		item string
		rate float64
	}{
		{InputPesticide, "Crop protection", pesticideCostPerHa},
		{InputLabour, "Labour", labourCostPerHa},
		{InputMachinery, "Machinery and fuel", machineryCostPerHa},
	} {
		budget.Lines = append(budget.Lines, InputLine{
			Kind: line.kind, Item: line.item,
			Quantity: areaHectares, Unit: "ha",
			UnitCost: line.rate, TotalCost: line.rate * areaHectares,
		})
	}

	// Irrigation, by the crop's season-long water demand.
	irrigationTotal := profile.WaterDemandMm * areaHectares * irrigationCostPerMm
	budget.Lines = append(budget.Lines, InputLine{
		Kind: InputIrrigation, Item: "Irrigation",
		Quantity: profile.WaterDemandMm * areaHectares, Unit: "ha-mm",
		UnitCost: irrigationCostPerMm, TotalCost: irrigationTotal,
		Note: "assumes the full season demand is irrigated; rainfall reduces it",
	})

	for _, line := range budget.Lines {
		budget.TotalCost += line.TotalCost
	}
	budget.CostPerHectare = budget.TotalCost / areaHectares

	return budget, nil
}

// SeasonPlan is one field's plan for one season.
type SeasonPlan struct {
	ID       string `json:"id" db:"id"`
	TenantID string `json:"tenant_id" db:"tenant_id"`
	FieldID  string `json:"field_id" db:"field_id"`
	FarmID   string `json:"farm_id" db:"farm_id"`

	Season Season `json:"season" db:"season"`
	Year   int    `json:"year" db:"year"`

	Crop         string  `json:"crop" db:"crop"`
	Variety      string  `json:"variety" db:"variety"`
	AreaHectares float64 `json:"area_hectares" db:"area_hectares"`

	Status PlanStatus `json:"status" db:"status"`

	SowingWindow  SowingWindow  `json:"sowing_window" db:"sowing_window"`
	RotationCheck RotationCheck `json:"rotation_check" db:"rotation_check"`
	Budget        InputBudget   `json:"budget" db:"budget"`

	TargetYieldTonnesHa float64 `json:"target_yield_tonnes_ha" db:"target_yield_tonnes_ha"`
	Notes               string  `json:"notes" db:"notes"`

	CreatedBy string    `json:"created_by" db:"created_by"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
	Version   int64     `json:"version" db:"version"`
}

// planYearRange is how far ahead and behind a plan may be dated.
//
// A plan for 2050 is a typo; one for 1990 is a data-entry slip. Neither is a
// season anybody is planning.
const (
	minPlanYear = 2000
	maxPlanYear = 2100
)

// Validate checks a plan can be created.
func (p *SeasonPlan) Validate() error {
	if strings.TrimSpace(p.FieldID) == "" {
		return ErrMissingField
	}
	if strings.TrimSpace(p.Crop) == "" {
		return ErrMissingCrop
	}
	if p.Season == "" {
		return ErrUnknownSeason
	}
	if p.AreaHectares <= 0 {
		return ErrInvalidArea
	}
	if p.Year < minPlanYear || p.Year > maxPlanYear {
		return ErrInvalidYear
	}
	return nil
}

// Editable reports whether a plan may still be changed.
//
// Only a draft. Once a plan is committed the seed is ordered and the labour is
// booked against it, so editing it afterwards would make the record disagree
// with what was actually bought — a new plan supersedes it instead.
func (p *SeasonPlan) Editable() bool { return p.Status == PlanDraft }

// ListPlansParams filters a plan query.
type ListPlansParams struct {
	TenantID string
	FieldID  string
	FarmID   string
	Season   Season
	Year     int
	Status   PlanStatus
	Limit    int
	Offset   int
}
