package domain

import (
	"math"
	"strings"
	"testing"
)

func lineFor(t *testing.T, fp Footprint, source EmissionSource) EmissionLine {
	t.Helper()
	for _, line := range fp.Lines {
		if line.Source == source {
			return line
		}
	}
	t.Fatalf("the footprint has no %s line", source)
	return EmissionLine{}
}

func closeTo(got, want, tolerance float64) bool {
	return math.Abs(got-want) <= tolerance
}

func wheatParams() FootprintParams {
	return FootprintParams{
		FieldID:      "field-1",
		Crop:         "Wheat",
		Year:         2026,
		AreaHectares: 2,
		WaterRegime:  RegimeUpland,
	}
}

// The N2O arithmetic, checked against a hand calculation rather than against
// whatever the code happens to produce.
func TestDirectN2OFollowsTheIPCCFactor(t *testing.T) {
	inputs := []InputUse{
		{Category: CategorySyntheticN, Product: "CAN", Quantity: 400, NitrogenKg: 100, Year: 2026},
		{Category: CategoryDiesel, Quantity: 50, Year: 2026},
	}

	fp, err := ComputeFootprint(wheatParams(), inputs)
	if err != nil {
		t.Fatalf("ComputeFootprint: %v", err)
	}

	// 100 kg N x 0.01 = 1 kg N2O-N; x 44/28 = 1.571 kg N2O; x 273 = 429 kg CO2e.
	direct := lineFor(t, fp, SourceDirectN2O)
	if !closeTo(direct.KgCO2e, 428.9, 1.0) {
		t.Errorf("direct N2O = %.1f kg CO2e, want about 429 — 100 kg N x EF1 x 44/28 x GWP",
			direct.KgCO2e)
	}
}

// Leaving out the N2O-N to N2O mass conversion is the classic error here and
// understates nitrous oxide by 36%. This pins the ratio.
func TestNitrousOxideMassConversionIsApplied(t *testing.T) {
	inputs := []InputUse{
		{Category: CategorySyntheticN, Quantity: 100, NitrogenKg: 100, Year: 2026},
	}
	fp, _ := ComputeFootprint(wheatParams(), inputs)

	direct := lineFor(t, fp, SourceDirectN2O)
	withoutConversion := 100 * ef1Synthetic * gwpN2O
	if closeTo(direct.KgCO2e, withoutConversion, 1.0) {
		t.Errorf("direct N2O = %.1f, which is the figure you get without the 44/28 "+
			"conversion from N2O-N to N2O", direct.KgCO2e)
	}
}

func TestUreaReleasesItsOwnCO2(t *testing.T) {
	inputs := []InputUse{
		{Category: CategoryUrea, Product: "Urea", Quantity: 1000, NitrogenKg: 460, Year: 2026},
	}
	fp, _ := ComputeFootprint(wheatParams(), inputs)

	// 1000 kg urea x 0.20 kg C/kg x 44/12 = 733 kg CO2.
	urea := lineFor(t, fp, SourceUreaCO2)
	if !closeTo(urea.KgCO2e, 733.3, 1.0) {
		t.Errorf("urea CO2 = %.1f kg, want about 733", urea.KgCO2e)
	}
}

// The rule the whole design turns on.
func TestMissingActivityDataIsNotZero(t *testing.T) {
	fp, err := ComputeFootprint(wheatParams(), nil)
	if err != nil {
		t.Fatalf("ComputeFootprint: %v", err)
	}

	if fp.Complete {
		t.Fatal("a footprint with no input records at all reports itself as complete")
	}

	wantMissing := map[EmissionSource]bool{
		SourceDirectN2O:   true,
		SourceIndirectN2O: true,
		SourceEnergy:      true,
		SourceUpstream:    true,
	}
	for _, source := range fp.MissingSources {
		delete(wantMissing, source)
	}
	if len(wantMissing) > 0 {
		t.Errorf("these sources have no data and were not flagged missing: %v", wantMissing)
	}

	if !containsSubstring(fp.Summary(), "floor, not a total") {
		t.Errorf("summary = %q; an incomplete footprint has to say so wherever it is shown",
			fp.Summary())
	}
}

// A field that applied no lime genuinely emitted no lime CO2. Flagging that as
// a gap would make every ordinary field look as though its records were broken,
// and a completeness signal that fires on everything is one people switch off.
func TestAbsentCategoriesThatAreGenuinelyZeroAreNotFlagged(t *testing.T) {
	inputs := []InputUse{
		{Category: CategoryUrea, Product: "Urea", Quantity: 200, NitrogenKg: 92, Year: 2026},
		{Category: CategoryDiesel, Quantity: 60, Year: 2026},
	}
	fp, _ := ComputeFootprint(wheatParams(), inputs)

	lime := lineFor(t, fp, SourceLimeCO2)
	if lime.Completeness != CompletenessNotApplicable {
		t.Errorf("lime completeness = %s, want NOT_APPLICABLE for a field that limed nothing",
			lime.Completeness)
	}
	for _, source := range fp.MissingSources {
		if source == SourceLimeCO2 {
			t.Error("lime was flagged as a gap in the record rather than as a genuine zero")
		}
	}
	if !fp.Complete {
		t.Errorf("a field with nitrogen and fuel recorded should be complete; missing: %v",
			fp.MissingSources)
	}
}

// Fuel is different from lime: every field is worked and almost every one is
// pumped, so no energy record is a hole, not a zero.
func TestNoEnergyRecordIsAGapNotAZero(t *testing.T) {
	inputs := []InputUse{
		{Category: CategoryUrea, Product: "Urea", Quantity: 200, NitrogenKg: 92, Year: 2026},
	}
	fp, _ := ComputeFootprint(wheatParams(), inputs)

	energy := lineFor(t, fp, SourceEnergy)
	if energy.Completeness != CompletenessMissing {
		t.Errorf("energy completeness = %s, want MISSING", energy.Completeness)
	}
	if fp.Complete {
		t.Error("a footprint with no fuel record claims to be complete")
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Rice
// ─────────────────────────────────────────────────────────────────────────────

func TestFloodedRiceMethaneDominatesTheFootprint(t *testing.T) {
	params := FootprintParams{
		FieldID:      "field-1",
		Crop:         "Paddy",
		Year:         2026,
		AreaHectares: 1,
		WaterRegime:  RegimeContinuousFlood,
		FloodedDays:  110,
	}
	inputs := []InputUse{
		{Category: CategoryUrea, Product: "Urea", Quantity: 260, NitrogenKg: 120, Year: 2026},
		{Category: CategoryDiesel, Quantity: 60, Year: 2026},
	}

	fp, err := ComputeFootprint(params, inputs)
	if err != nil {
		t.Fatalf("ComputeFootprint: %v", err)
	}

	// 1.30 kg CH4/ha/day x 1.00 x 110 days x 1 ha = 143 kg CH4; x 27 = 3861.
	ch4 := lineFor(t, fp, SourceRiceCH4)
	if !closeTo(ch4.KgCO2e, 3861, 5) {
		t.Errorf("paddy methane = %.0f kg CO2e, want about 3861", ch4.KgCO2e)
	}
	if ch4.KgCO2e <= fp.TotalKgCO2e/2 {
		t.Errorf("methane is %.0f of a %.0f kg total; on a flooded paddy it should "+
			"dominate, and a footprint that says otherwise has lost the largest source",
			ch4.KgCO2e, fp.TotalKgCO2e)
	}
}

func TestAlternateWettingAndDryingHalvesTheMethane(t *testing.T) {
	base := FootprintParams{
		FieldID: "field-1", Crop: "Rice", Year: 2026,
		AreaHectares: 1, FloodedDays: 110,
	}

	flooded := base
	flooded.WaterRegime = RegimeContinuousFlood
	awd := base
	awd.WaterRegime = RegimeAWD

	floodedFp, _ := ComputeFootprint(flooded, nil)
	awdFp, _ := ComputeFootprint(awd, nil)

	floodedCH4 := lineFor(t, floodedFp, SourceRiceCH4).KgCO2e
	awdCH4 := lineFor(t, awdFp, SourceRiceCH4).KgCO2e

	if awdCH4 >= floodedCH4 {
		t.Fatalf("AWD methane %.0f is not below continuous flooding's %.0f", awdCH4, floodedCH4)
	}
	if ratio := awdCH4 / floodedCH4; !closeTo(ratio, 0.52, 0.01) {
		t.Errorf("AWD/flooded ratio = %.2f, want 0.52 — the IPCC scaling factor", ratio)
	}
}

// The water regime decides most of a paddy's footprint, so guessing it would
// be the service deciding the answer on the farmer's behalf.
func TestRiceWithNoWaterRegimeIsUnknownNotAssumed(t *testing.T) {
	params := FootprintParams{
		FieldID: "field-1", Crop: "Rice", Year: 2026, AreaHectares: 1,
	}
	fp, _ := ComputeFootprint(params, nil)

	ch4 := lineFor(t, fp, SourceRiceCH4)
	if ch4.Completeness != CompletenessMissing {
		t.Errorf("rice methane completeness = %s, want MISSING", ch4.Completeness)
	}
	if ch4.KgCO2e != 0 {
		t.Errorf("methane = %.0f for an unrecorded water regime; the figure should be "+
			"absent rather than guessed", ch4.KgCO2e)
	}
	if fp.Complete {
		t.Error("a rice footprint with no water regime claims to be complete")
	}
}

// "Paddy", "Basmati Rice" and "rice (kharif)" are the same crop. A strict match
// would silently drop the largest line on the footprint for most of them.
func TestRiceIsRecognisedUnderItsCommonNames(t *testing.T) {
	for _, crop := range []string{"Rice", "rice", "Paddy", "PADDY", "Basmati Rice", "paddy (kharif)"} {
		params := FootprintParams{
			FieldID: "f", Crop: crop, Year: 2026, AreaHectares: 1,
			WaterRegime: RegimeContinuousFlood, FloodedDays: 100,
		}
		fp, _ := ComputeFootprint(params, nil)
		if lineFor(t, fp, SourceRiceCH4).KgCO2e <= 0 {
			t.Errorf("crop %q produced no paddy methane", crop)
		}
	}
}

func TestNonRiceHasNoMethaneLine(t *testing.T) {
	fp, _ := ComputeFootprint(wheatParams(), nil)
	ch4 := lineFor(t, fp, SourceRiceCH4)
	if ch4.Completeness != CompletenessNotApplicable {
		t.Errorf("wheat methane completeness = %s, want NOT_APPLICABLE", ch4.Completeness)
	}
	for _, source := range fp.MissingSources {
		if source == SourceRiceCH4 {
			t.Error("a wheat field was flagged as missing paddy methane data")
		}
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Intensity
// ─────────────────────────────────────────────────────────────────────────────

func TestIntensityPerTonneIsOmittedWithoutAYield(t *testing.T) {
	inputs := []InputUse{
		{Category: CategoryUrea, Product: "Urea", Quantity: 200, NitrogenKg: 92, Year: 2026},
		{Category: CategoryDiesel, Quantity: 40, Year: 2026},
	}

	fp, _ := ComputeFootprint(wheatParams(), inputs)
	if fp.KgCO2ePerTonne != 0 {
		t.Errorf("per-tonne intensity = %.1f with no yield recorded; that number ends up "+
			"in a buyer's contract and must not be computed against a guess",
			fp.KgCO2ePerTonne)
	}

	params := wheatParams()
	params.YieldTonnes = 8
	withYield, _ := ComputeFootprint(params, inputs)
	if !closeTo(withYield.KgCO2ePerTonne, withYield.TotalKgCO2e/8, 0.01) {
		t.Errorf("per-tonne intensity = %.1f, want total/8", withYield.KgCO2ePerTonne)
	}
}

func TestPerHectareUsesTheFieldArea(t *testing.T) {
	inputs := []InputUse{
		{Category: CategoryUrea, Product: "Urea", Quantity: 200, NitrogenKg: 92, Year: 2026},
		{Category: CategoryDiesel, Quantity: 40, Year: 2026},
	}
	fp, _ := ComputeFootprint(wheatParams(), inputs) // 2 ha

	if !closeTo(fp.KgCO2ePerHa, fp.TotalKgCO2e/2, 0.01) {
		t.Errorf("per-hectare = %.1f, want total/2", fp.KgCO2ePerHa)
	}
}

func TestComputeFootprintRejectsAZeroArea(t *testing.T) {
	params := wheatParams()
	params.AreaHectares = 0
	if _, err := ComputeFootprint(params, nil); err == nil {
		t.Fatal("a zero area would divide the intensity by zero and should be refused")
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Upstream
// ─────────────────────────────────────────────────────────────────────────────

// Upstream is reported separately so a reader who needs field emissions alone
// can subtract it. Folded into the other lines it could not be undone.
func TestUpstreamIsItsOwnLine(t *testing.T) {
	inputs := []InputUse{
		{Category: CategoryUrea, Product: "Urea", Quantity: 200, NitrogenKg: 92, Year: 2026},
		{Category: CategoryPesticide, Product: "Neem oil", Quantity: 5, Year: 2026},
		{Category: CategoryDiesel, Quantity: 40, Year: 2026},
	}
	fp, _ := ComputeFootprint(wheatParams(), inputs)

	upstream := lineFor(t, fp, SourceUpstream)
	// 92 kg urea-N x 3.4 + 5 kg pesticide x 18 + 40 L diesel x 0.62 = 427.6.
	if !closeTo(upstream.KgCO2e, 427.6, 1.0) {
		t.Errorf("upstream = %.1f kg CO2e, want about 428", upstream.KgCO2e)
	}

	field := fp.TotalKgCO2e - upstream.KgCO2e
	if field <= 0 {
		t.Error("the field-only total cannot be recovered by subtracting the upstream line")
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Nitrogen derivation
// ─────────────────────────────────────────────────────────────────────────────

func TestDeriveNitrogenFromCommonProducts(t *testing.T) {
	cases := []struct {
		category InputCategory
		product  string
		quantity float64
		want     float64
	}{
		{CategoryUrea, "Urea", 100, 46},
		{CategoryUrea, "Urea 46% (IFFCO)", 100, 46},
		{CategorySyntheticN, "DAP", 100, 18},
		{CategorySyntheticN, "Ammonium Sulphate", 100, 21},
		{CategoryOrganicN, "Farmyard manure", 1000, 5},
		{CategoryOrganicN, "Neem cake", 100, 5},
		{CategoryDiesel, "HSD", 100, 0},
	}
	for _, tc := range cases {
		got, ok := DeriveNitrogen(tc.category, tc.product, tc.quantity)
		if !ok {
			t.Errorf("DeriveNitrogen(%s, %q) reported the product as unknown",
				tc.category, tc.product)
			continue
		}
		if !closeTo(got, tc.want, 0.01) {
			t.Errorf("DeriveNitrogen(%s, %q, %.0f) = %.2f, want %.2f",
				tc.category, tc.product, tc.quantity, got, tc.want)
		}
	}
}

// An invented nitrogen fraction propagates into the N2O line, which is usually
// the largest number on a non-rice footprint.
func TestDeriveNitrogenRefusesAProductItDoesNotKnow(t *testing.T) {
	if _, ok := DeriveNitrogen(CategorySyntheticN, "SuperGro Plus", 100); ok {
		t.Fatal("an unrecognised fertiliser should not be assigned a plausible nitrogen fraction")
	}
}

// The category is a declaration even when the product name is not.
func TestUreaCategoryAlwaysYieldsNitrogen(t *testing.T) {
	got, ok := DeriveNitrogen(CategoryUrea, "white prills from the co-op", 100)
	if !ok {
		t.Fatal("a urea application should always yield nitrogen")
	}
	if !closeTo(got, 46, 0.01) {
		t.Errorf("nitrogen = %.1f, want 46", got)
	}
}

func TestDefaultUnitDistinguishesFuelFromFertiliser(t *testing.T) {
	if DefaultUnit(CategoryDiesel) != "L" {
		t.Error("diesel should be recorded in litres; kg and litres differ by 20%")
	}
	if DefaultUnit(CategoryElectricity) != "kWh" {
		t.Error("electricity should be recorded in kWh")
	}
	if DefaultUnit(CategoryUrea) != "kg" {
		t.Error("fertiliser should be recorded in kg")
	}
}

func TestInputValidation(t *testing.T) {
	valid := InputUse{FieldID: "f", Category: CategoryUrea, Quantity: 100, Year: 2026}
	if err := valid.Validate(); err != nil {
		t.Fatalf("a valid record was rejected: %v", err)
	}

	cases := map[string]InputUse{
		"no field":      {Category: CategoryUrea, Quantity: 1, Year: 2026},
		"no category":   {FieldID: "f", Quantity: 1, Year: 2026},
		"zero quantity": {FieldID: "f", Category: CategoryUrea, Year: 2026},
		"absurd year":   {FieldID: "f", Category: CategoryUrea, Quantity: 1, Year: 1970},
	}
	for name, in := range cases {
		if err := in.Validate(); err == nil {
			t.Errorf("%s was accepted", name)
		}
	}
}

func containsSubstring(haystack, needle string) bool {
	return strings.Contains(haystack, needle)
}
