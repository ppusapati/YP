// Package domain holds sustainability-service's entities and the carbon
// accounting.
package domain

import (
	"errors"
	"fmt"
	"sort"
	"strings"
	"time"
)

// Errors the domain returns.
var (
	ErrMissingField    = errors.New("sustainability: field is required")
	ErrInvalidArea     = errors.New("sustainability: area must be positive")
	ErrInvalidQuantity = errors.New("sustainability: quantity must be positive")
	ErrUnknownCategory = errors.New("sustainability: input category is required")
	ErrInvalidYear     = errors.New("sustainability: year is outside the range this service covers")
)

// InputCategory is what was applied, grouped by how it emits.
type InputCategory string

const (
	CategorySyntheticN  InputCategory = "SYNTHETIC_N"
	CategoryUrea        InputCategory = "UREA"
	CategoryPhosphate   InputCategory = "PHOSPHATE"
	CategoryPotash      InputCategory = "POTASH"
	CategoryOrganicN    InputCategory = "ORGANIC_N"
	CategoryLime        InputCategory = "LIME"
	CategoryPesticide   InputCategory = "PESTICIDE"
	CategorySeed        InputCategory = "SEED"
	CategoryDiesel      InputCategory = "DIESEL"
	CategoryElectricity InputCategory = "ELECTRICITY"
	CategoryResidueBurn InputCategory = "RESIDUE_BURN"
)

// WaterRegime is how a paddy was watered.
type WaterRegime string

const (
	RegimeContinuousFlood  WaterRegime = "CONTINUOUS_FLOOD"
	RegimeSingleDrainage   WaterRegime = "SINGLE_DRAINAGE"
	RegimeMultipleDrainage WaterRegime = "MULTIPLE_DRAINAGE"
	RegimeAWD              WaterRegime = "AWD"
	RegimeRainfed          WaterRegime = "RAINFED"
	RegimeUpland           WaterRegime = "UPLAND"
)

// EmissionSource is one line of a footprint.
type EmissionSource string

const (
	SourceDirectN2O   EmissionSource = "DIRECT_N2O"
	SourceIndirectN2O EmissionSource = "INDIRECT_N2O"
	SourceUreaCO2     EmissionSource = "UREA_CO2"
	SourceLimeCO2     EmissionSource = "LIME_CO2"
	SourceRiceCH4     EmissionSource = "RICE_CH4"
	SourceEnergy      EmissionSource = "ENERGY"
	SourceResidueBurn EmissionSource = "RESIDUE_BURN"
	SourceUpstream    EmissionSource = "UPSTREAM"
)

// Completeness is how much of a source's activity data was recorded.
type Completeness string

const (
	// CompletenessRecorded means activity data exists for this source.
	CompletenessRecorded Completeness = "RECORDED"
	// CompletenessMissing means nothing was recorded and the figure is
	// therefore unknown, not zero.
	CompletenessMissing Completeness = "MISSING"
	// CompletenessNotApplicable means nothing is expected — an upland field has
	// no paddy methane.
	CompletenessNotApplicable Completeness = "NOT_APPLICABLE"
)

// ─────────────────────────────────────────────────────────────────────────────
// Emission factors
// ─────────────────────────────────────────────────────────────────────────────

// Global warming potentials, IPCC AR6, 100-year horizon.
//
// AR6 rather than AR5, and stated rather than folded into a combined factor:
// N2O moved from 265 to 273 and methane from 28 to 27 between the two reports,
// so a footprint that does not say which set it used cannot be compared with
// one that does.
const (
	gwpN2O = 273.0
	gwpCH4 = 27.0 // biogenic methane, which is what a paddy emits
)

// Mass conversions.
const (
	// N2O is 44/28 times the mass of the nitrogen in it. The IPCC factors are
	// expressed per kg of N2O-N, so this conversion is not optional — leaving
	// it out understates nitrous oxide by 36%.
	n2oNToN2O = 44.0 / 28.0
	// CO2 is 44/12 times the mass of the carbon in it.
	cToCO2 = 44.0 / 12.0
)

// IPCC 2019 Refinement default emission factors for managed soils.
const (
	// ef1Synthetic is direct N2O-N per kg of synthetic N applied.
	ef1Synthetic = 0.01
	// ef1Organic is the same for manure and compost. The 2019 refinement
	// separates the two; the older single 0.01 understated organic sources.
	ef1Organic = 0.006

	// fracGasfSynthetic is the share of synthetic N that volatilises as NH3
	// and NOx; fracGasm is the same for organic N, which is much higher
	// because manure sits on the surface.
	fracGasfSynthetic = 0.11
	fracGasmOrganic   = 0.21
	// ef4 is N2O-N per kg of that volatilised nitrogen once it redeposits.
	ef4 = 0.01

	// fracLeach is the share of applied N lost to water in a wet climate, and
	// ef5 the N2O-N it causes downstream. Indian kharif cropping is wet by
	// definition, so the wet-climate value is the right default here; a dry
	// rabi field on the Deccan leaches less and this overstates it.
	fracLeach = 0.24
	ef5       = 0.011
)

// Carbon released directly by two products.
const (
	// ureaCO2CPerKg is carbon released per kg of urea as it hydrolyses. The
	// CO2 was fixed during manufacture and comes straight back out in the
	// field, so it is counted here and not in the upstream line.
	ureaCO2CPerKg = 0.20
	// limeCO2CPerKg for limestone. Dolomite is 0.13; the higher-emitting of
	// the two is not assumed, because most agricultural lime in India is
	// limestone and overstating by default is its own kind of wrong answer.
	limeCO2CPerKg = 0.12
	// ureaNFraction is the nitrogen content of urea.
	ureaNFraction = 0.46
)

// Energy factors.
const (
	// dieselCO2PerLitre includes combustion only.
	dieselCO2PerLitre = 2.68
	// gridCO2PerKWh is the Indian grid average. A footprint computed for
	// another country with this number would be wrong by a factor of three in
	// either direction, which is why it is named rather than inline.
	gridCO2PerKWh = 0.71
)

// Upstream (cradle-to-gate) manufacturing factors, kg CO2e per kg of product.
//
// These are off the farm and are the least certain numbers here — they depend
// on the plant, its vintage and its gas supply. They are reported as their own
// line so a reader can take the field emissions without them.
const (
	upstreamPerKgUreaN      = 3.4
	upstreamPerKgSyntheticN = 5.9 // ammonium nitrate and blends, which are worse
	upstreamPerKgP2O5       = 1.2
	upstreamPerKgK2O        = 0.6
	upstreamPerKgPesticide  = 18.0
	upstreamPerLitreDiesel  = 0.62
)

// Residue burning, IPCC defaults per tonne of dry matter burned.
const (
	residueCH4PerTonne = 2.7
	residueN2OPerTonne = 0.07
)

// riceBaselineCH4PerHaDay is the IPCC baseline methane for continuously
// flooded rice with no organic amendment.
const riceBaselineCH4PerHaDay = 1.30

// riceScalingFactor is the water-regime multiplier on the baseline.
//
// This is usually the largest single number in a rice field's footprint, and
// the spread between a continuously flooded paddy and one under alternate
// wetting and drying is more than a factor of two. A service that reported
// rice without asking how it was watered would be reporting a number it had
// made up.
func riceScalingFactor(regime WaterRegime) (float64, bool) {
	switch regime {
	case RegimeContinuousFlood:
		return 1.00, true
	case RegimeSingleDrainage:
		return 0.71, true
	case RegimeMultipleDrainage:
		return 0.55, true
	case RegimeAWD:
		return 0.52, true
	case RegimeRainfed:
		return 0.54, true
	case RegimeUpland:
		return 0.0, true
	default:
		return 0, false
	}
}

// defaultFloodedDays is the cultivation period used when none is recorded.
//
// 110 days, a typical transplanted kharif paddy. Used only when the caller
// gives no figure, and the line says it was assumed.
const defaultFloodedDays = 110

// ─────────────────────────────────────────────────────────────────────────────
// Footprint
// ─────────────────────────────────────────────────────────────────────────────

// EmissionLine is one source's contribution.
type EmissionLine struct {
	Source       EmissionSource `json:"source"`
	KgCO2e       float64        `json:"kg_co2e"`
	Basis        string         `json:"basis"`
	Completeness Completeness   `json:"completeness"`
}

// Footprint is one field's greenhouse gas account for one crop year.
type Footprint struct {
	ID       string `json:"id" db:"id"`
	TenantID string `json:"tenant_id" db:"tenant_id"`
	FieldID  string `json:"field_id" db:"field_id"`
	FarmID   string `json:"farm_id" db:"farm_id"`
	Crop     string `json:"crop" db:"crop"`
	Year     int    `json:"year" db:"year"`

	AreaHectares float64     `json:"area_hectares" db:"area_hectares"`
	WaterRegime  WaterRegime `json:"water_regime" db:"water_regime"`

	Lines []EmissionLine `json:"lines" db:"lines"`

	TotalKgCO2e    float64          `json:"total_kg_co2e" db:"total_kg_co2e"`
	KgCO2ePerHa    float64          `json:"kg_co2e_per_hectare" db:"kg_co2e_per_hectare"`
	KgCO2ePerTonne float64          `json:"kg_co2e_per_tonne" db:"kg_co2e_per_tonne"`
	YieldTonnes    float64          `json:"yield_tonnes" db:"yield_tonnes"`
	MissingSources []EmissionSource `json:"missing_sources" db:"missing_sources"`
	Complete       bool             `json:"complete" db:"complete"`

	ComputedAt time.Time `json:"computed_at" db:"computed_at"`
	Method     string    `json:"method" db:"method"`
}

// FootprintParams is what a footprint is computed from beyond the input records.
type FootprintParams struct {
	FieldID      string
	FarmID       string
	Crop         string
	Year         int
	AreaHectares float64
	WaterRegime  WaterRegime
	FloodedDays  int
	YieldTonnes  float64
}

// methodLabel names the method so two footprints can be compared.
const methodLabel = "IPCC 2019 Refinement, Tier 1; AR6 GWP100"

// ComputeFootprint accounts for a field's emissions over one crop year.
//
// The rule that shapes everything here: a source with no activity data behind
// it is reported as *missing*, not as zero. A field with no diesel record has
// an unknown fuel footprint, and a report that quietly calls it nothing
// produces a flattering total that falls apart the first time an auditor asks
// for the fuel bills. Missing sources are listed on the footprint and the
// total is marked incomplete, so every surface that shows the number has to
// show that with it.
func ComputeFootprint(params FootprintParams, inputs []InputUse) (Footprint, error) {
	if strings.TrimSpace(params.FieldID) == "" {
		return Footprint{}, ErrMissingField
	}
	if params.AreaHectares <= 0 {
		return Footprint{}, ErrInvalidArea
	}

	fp := Footprint{
		FieldID:      params.FieldID,
		FarmID:       params.FarmID,
		Crop:         params.Crop,
		Year:         params.Year,
		AreaHectares: params.AreaHectares,
		WaterRegime:  params.WaterRegime,
		YieldTonnes:  params.YieldTonnes,
		Method:       methodLabel,
	}

	totals := totalsByCategory(inputs)

	fp.Lines = append(fp.Lines, nitrogenLines(totals)...)
	fp.Lines = append(fp.Lines, ureaLine(totals), limeLine(totals))
	fp.Lines = append(fp.Lines, riceLine(params))
	fp.Lines = append(fp.Lines, energyLine(totals))
	fp.Lines = append(fp.Lines, residueLine(totals))
	fp.Lines = append(fp.Lines, upstreamLine(totals))

	for _, line := range fp.Lines {
		fp.TotalKgCO2e += line.KgCO2e
		if line.Completeness == CompletenessMissing {
			fp.MissingSources = append(fp.MissingSources, line.Source)
		}
	}
	fp.Complete = len(fp.MissingSources) == 0
	fp.KgCO2ePerHa = fp.TotalKgCO2e / params.AreaHectares

	// Left at zero rather than divided by a guessed yield. Intensity per tonne
	// is the number a buyer quotes in a contract, and one computed against an
	// assumed yield is a number somebody signs.
	if params.YieldTonnes > 0 {
		fp.KgCO2ePerTonne = fp.TotalKgCO2e / params.YieldTonnes
	}

	return fp, nil
}

// categoryTotals is the quantity and nitrogen recorded per category.
type categoryTotals struct {
	quantity map[InputCategory]float64
	nitrogen map[InputCategory]float64
	seen     map[InputCategory]bool
}

func totalsByCategory(inputs []InputUse) categoryTotals {
	t := categoryTotals{
		quantity: map[InputCategory]float64{},
		nitrogen: map[InputCategory]float64{},
		seen:     map[InputCategory]bool{},
	}
	for _, in := range inputs {
		t.quantity[in.Category] += in.Quantity
		t.nitrogen[in.Category] += in.NitrogenKg
		t.seen[in.Category] = true
	}
	return t
}

// anySeen reports whether any of the categories has a record.
func (t categoryTotals) anySeen(categories ...InputCategory) bool {
	for _, c := range categories {
		if t.seen[c] {
			return true
		}
	}
	return false
}

// nitrogenLines is the direct and indirect N2O from applied nitrogen.
func nitrogenLines(t categoryTotals) []EmissionLine {
	syntheticN := t.nitrogen[CategorySyntheticN] + t.nitrogen[CategoryUrea]
	organicN := t.nitrogen[CategoryOrganicN]

	recorded := t.anySeen(CategorySyntheticN, CategoryUrea, CategoryOrganicN)
	completeness := CompletenessRecorded
	if !recorded {
		completeness = CompletenessMissing
	}

	directN := syntheticN*ef1Synthetic + organicN*ef1Organic
	direct := directN * n2oNToN2O * gwpN2O

	volatilisedN := syntheticN*fracGasfSynthetic + organicN*fracGasmOrganic
	leachedN := (syntheticN + organicN) * fracLeach
	indirectN := volatilisedN*ef4 + leachedN*ef5
	indirect := indirectN * n2oNToN2O * gwpN2O

	basisSuffix := fmt.Sprintf("%.0f kg synthetic N and %.0f kg organic N", syntheticN, organicN)
	if !recorded {
		basisSuffix = "no nitrogen application was recorded for this field and year, " +
			"so this is unknown rather than zero"
	}

	return []EmissionLine{
		{
			Source:       SourceDirectN2O,
			KgCO2e:       direct,
			Basis:        "direct N2O from " + basisSuffix,
			Completeness: completeness,
		},
		{
			Source: SourceIndirectN2O,
			KgCO2e: indirect,
			Basis: "N2O from the nitrogen that volatilised or leached away, from " +
				basisSuffix,
			Completeness: completeness,
		},
	}
}

func ureaLine(t categoryTotals) EmissionLine {
	urea := t.quantity[CategoryUrea]
	line := EmissionLine{
		Source:       SourceUreaCO2,
		KgCO2e:       urea * ureaCO2CPerKg * cToCO2,
		Completeness: CompletenessRecorded,
		Basis:        fmt.Sprintf("CO2 released as %.0f kg of urea hydrolyses in the soil", urea),
	}
	if !t.seen[CategoryUrea] {
		// Not applicable rather than missing: a field can genuinely apply no
		// urea, and the nitrogen line already flags an unrecorded nitrogen
		// application. Flagging it twice would make every non-urea field look
		// as though its records had a hole in them.
		line.Completeness = CompletenessNotApplicable
		line.Basis = "no urea was applied"
	}
	return line
}

func limeLine(t categoryTotals) EmissionLine {
	lime := t.quantity[CategoryLime]
	line := EmissionLine{
		Source:       SourceLimeCO2,
		KgCO2e:       lime * limeCO2CPerKg * cToCO2,
		Completeness: CompletenessRecorded,
		Basis:        fmt.Sprintf("CO2 from %.0f kg of agricultural lime reacting with soil acid", lime),
	}
	if !t.seen[CategoryLime] {
		line.Completeness = CompletenessNotApplicable
		line.Basis = "no lime was applied"
	}
	return line
}

// riceLine is methane from a flooded paddy.
//
// For a rice crop this is usually the largest line on the footprint, so an
// unspecified water regime is reported as missing rather than defaulted. The
// spread between continuous flooding and alternate wetting and drying is more
// than a factor of two, and picking one silently would decide most of the
// answer on the service's behalf.
func riceLine(params FootprintParams) EmissionLine {
	if !isRice(params.Crop) {
		return EmissionLine{
			Source:       SourceRiceCH4,
			Completeness: CompletenessNotApplicable,
			Basis:        "not a rice crop",
		}
	}

	factor, known := riceScalingFactor(params.WaterRegime)
	if !known {
		return EmissionLine{
			Source:       SourceRiceCH4,
			Completeness: CompletenessMissing,
			Basis: "no water regime was recorded for this paddy. Methane is usually " +
				"the largest source on a rice field and varies by more than a factor " +
				"of two with how it was watered, so it is left unknown rather than assumed",
		}
	}

	days := params.FloodedDays
	assumed := ""
	if days <= 0 {
		days = defaultFloodedDays
		assumed = fmt.Sprintf(" (a %d-day cultivation period was assumed)", defaultFloodedDays)
	}

	ch4 := riceBaselineCH4PerHaDay * factor * float64(days) * params.AreaHectares
	return EmissionLine{
		Source:       SourceRiceCH4,
		KgCO2e:       ch4 * gwpCH4,
		Completeness: CompletenessRecorded,
		Basis: fmt.Sprintf("%.0f kg of methane from %.1f ha of %s paddy over %d days%s",
			ch4, params.AreaHectares, regimeLabel(params.WaterRegime), days, assumed),
	}
}

func energyLine(t categoryTotals) EmissionLine {
	diesel := t.quantity[CategoryDiesel]
	electricity := t.quantity[CategoryElectricity]

	line := EmissionLine{
		Source:       SourceEnergy,
		KgCO2e:       diesel*dieselCO2PerLitre + electricity*gridCO2PerKWh,
		Completeness: CompletenessRecorded,
		Basis: fmt.Sprintf("%.0f litres of diesel and %.0f kWh of grid electricity",
			diesel, electricity),
	}
	if !t.anySeen(CategoryDiesel, CategoryElectricity) {
		// Missing, not zero, and not "not applicable". Every field is ploughed
		// and almost every one is irrigated, so no energy record means the
		// record has a hole in it, not that no fuel was burned.
		line.Completeness = CompletenessMissing
		line.Basis = "no fuel or electricity was recorded. Every field is worked and " +
			"almost every one is pumped, so this is a gap in the record rather than a zero"
	}
	return line
}

func residueLine(t categoryTotals) EmissionLine {
	burned := t.quantity[CategoryResidueBurn]
	line := EmissionLine{
		Source: SourceResidueBurn,
		KgCO2e: burned*residueCH4PerTonne*gwpCH4 +
			burned*residueN2OPerTonne*gwpN2O,
		Completeness: CompletenessRecorded,
		Basis: fmt.Sprintf("CH4 and N2O from burning %.1f tonnes of crop residue in the field",
			burned),
	}
	if !t.seen[CategoryResidueBurn] {
		line.Completeness = CompletenessNotApplicable
		line.Basis = "no residue burning was recorded"
	}
	return line
}

// upstreamLine is the manufacturing footprint of the inputs.
//
// Its own line rather than folded into the others, because it happens off the
// farm and is the least certain figure here — it depends on the fertiliser
// plant, its vintage and its gas supply. A reader who needs field emissions
// alone can take the total without this line; one folded in cannot be undone.
func upstreamLine(t categoryTotals) EmissionLine {
	total := t.nitrogen[CategoryUrea]*upstreamPerKgUreaN +
		t.nitrogen[CategorySyntheticN]*upstreamPerKgSyntheticN +
		t.quantity[CategoryPhosphate]*upstreamPerKgP2O5 +
		t.quantity[CategoryPotash]*upstreamPerKgK2O +
		t.quantity[CategoryPesticide]*upstreamPerKgPesticide +
		t.quantity[CategoryDiesel]*upstreamPerLitreDiesel

	line := EmissionLine{
		Source:       SourceUpstream,
		KgCO2e:       total,
		Completeness: CompletenessRecorded,
		Basis: "manufacture and delivery of the fertiliser, crop protection and fuel " +
			"used, which happen off the farm but happen because of it",
	}
	if !t.anySeen(CategorySyntheticN, CategoryUrea, CategoryPhosphate,
		CategoryPotash, CategoryPesticide, CategoryDiesel) {
		line.Completeness = CompletenessMissing
		line.Basis = "no purchased inputs were recorded, so their manufacturing " +
			"footprint is unknown rather than zero"
	}
	return line
}

// isRice recognises the crop names a rice paddy arrives under.
//
// Matched loosely on purpose: "Paddy", "rice", "Basmati Rice" and "paddy
// (kharif)" are all the same crop, and a strict match would silently drop the
// methane line — the largest number on the footprint — for most of them.
func isRice(crop string) bool {
	lower := strings.ToLower(crop)
	return strings.Contains(lower, "rice") || strings.Contains(lower, "paddy")
}

func regimeLabel(r WaterRegime) string {
	switch r {
	case RegimeContinuousFlood:
		return "continuously flooded"
	case RegimeSingleDrainage:
		return "single mid-season drainage"
	case RegimeMultipleDrainage:
		return "multiple drainage"
	case RegimeAWD:
		return "alternate wetting and drying"
	case RegimeRainfed:
		return "rainfed"
	case RegimeUpland:
		return "upland"
	default:
		return strings.ToLower(string(r))
	}
}

// Summary is a one-line account of a footprint, for a list or an alert.
func (f *Footprint) Summary() string {
	var b strings.Builder
	fmt.Fprintf(&b, "%.0f kg CO2e (%.0f kg/ha)", f.TotalKgCO2e, f.KgCO2ePerHa)
	if f.KgCO2ePerTonne > 0 {
		fmt.Fprintf(&b, ", %.0f kg/tonne", f.KgCO2ePerTonne)
	}
	if !f.Complete {
		names := make([]string, 0, len(f.MissingSources))
		for _, s := range f.MissingSources {
			names = append(names, sourceLabel(s))
		}
		sort.Strings(names)
		fmt.Fprintf(&b, ". This is a floor, not a total: no data for %s",
			strings.Join(names, ", "))
	}
	return b.String()
}

func sourceLabel(s EmissionSource) string {
	switch s {
	case SourceDirectN2O:
		return "nitrogen applied to the field"
	case SourceIndirectN2O:
		return "nitrogen lost to air and water"
	case SourceUreaCO2:
		return "urea"
	case SourceLimeCO2:
		return "lime"
	case SourceRiceCH4:
		return "paddy methane"
	case SourceEnergy:
		return "fuel and electricity"
	case SourceResidueBurn:
		return "residue burning"
	case SourceUpstream:
		return "input manufacture"
	default:
		return strings.ToLower(string(s))
	}
}

// ListFootprintsParams filters a footprint query.
type ListFootprintsParams struct {
	TenantID string
	FieldID  string
	FarmID   string
	Year     int
	Limit    int
	Offset   int
}
