package domain

import (
	"strconv"
	"strings"
	"testing"
	"time"
)

func day(year int, month time.Month, d int) time.Time {
	return time.Date(year, month, d, 0, 0, 0, 0, time.UTC)
}

var checkNow = day(2026, time.September, 15)

// cleanOrganicRecord is three years of inputs that would pass NPOP.
func cleanOrganicRecord() []InputUse {
	var out []InputUse
	for _, year := range []int{2024, 2025, 2026} {
		out = append(out,
			InputUse{
				ID: "fym-" + strconv.Itoa(year), Category: CategoryOrganicN,
				Product: "Farmyard manure", Quantity: 4000, NitrogenKg: 20,
				Year: year, AppliedOn: day(year, time.June, 1), AppliedBy: "R. Kumar",
			},
			InputUse{
				ID: "neem-" + strconv.Itoa(year), Category: CategoryPesticide,
				Product: "Neem oil 1500 ppm", Quantity: 5,
				Year: year, AppliedOn: day(year, time.July, 10), AppliedBy: "R. Kumar",
			},
		)
	}
	return out
}

func TestOrganicCheckPassesACleanThreeYearRecord(t *testing.T) {
	check := CheckCertification(StandardNPOP, "field-1",
		day(2023, time.April, 1), cleanOrganicRecord(), checkNow)

	if check.Status != StatusEligible {
		t.Fatalf("status = %s, want ELIGIBLE. Summary: %s\nFindings: %+v",
			check.Status, check.Summary, check.Findings)
	}
	if check.RecordYears != 3 {
		t.Errorf("record years = %d, want 3", check.RecordYears)
	}
}

// The rule the whole check exists for: one urea application inside the window
// restarts the conversion clock. Reporting that as anything short of a blocker
// would be telling a farmer they can sell produce they cannot.
func TestOneProhibitedInputBlocksOrganicCertification(t *testing.T) {
	inputs := append(cleanOrganicRecord(), InputUse{
		ID: "urea-slip", Category: CategoryUrea, Product: "Urea 46%",
		Quantity: 100, NitrogenKg: 46, Year: 2025,
		AppliedOn: day(2025, time.August, 3),
	})

	check := CheckCertification(StandardNPOP, "field-1",
		day(2023, time.April, 1), inputs, checkNow)

	if check.Status != StatusBlocked {
		t.Fatalf("status = %s, want BLOCKED after a urea application", check.Status)
	}
	if len(check.Findings) == 0 || check.Findings[0].Severity != SeverityBlocker {
		t.Fatalf("the urea application is not the first finding: %+v", check.Findings)
	}
	if check.Findings[0].EvidenceID != "urea-slip" {
		t.Errorf("the blocker points at %q, not at the offending record",
			check.Findings[0].EvidenceID)
	}
	if !strings.Contains(check.Findings[0].Message, "restarts") {
		t.Errorf("the finding does not say the conversion period restarts: %q",
			check.Findings[0].Message)
	}
}

// An input applied before conversion began is not a violation — that is the
// point of a conversion period.
func TestProhibitedInputBeforeConversionDoesNotBlock(t *testing.T) {
	inputs := append(cleanOrganicRecord(), InputUse{
		ID: "old-urea", Category: CategoryUrea, Product: "Urea",
		Quantity: 200, NitrogenKg: 92, Year: 2022,
		AppliedOn: day(2022, time.July, 1),
	})

	check := CheckCertification(StandardNPOP, "field-1",
		day(2023, time.April, 1), inputs, checkNow)

	if check.Status == StatusBlocked {
		t.Fatalf("a urea application from before conversion began blocked the claim: %+v",
			check.Findings)
	}
}

// A standard that needs three years of records and finds one has not been
// satisfied. "Eligible, no issues found" because there was nothing to find is
// how a service produces a document that fails at the first audit.
func TestTooLittleHistoryIsNotAPass(t *testing.T) {
	inputs := []InputUse{{
		ID: "fym-1", Category: CategoryOrganicN, Product: "Compost",
		Quantity: 2000, NitrogenKg: 20, Year: 2026,
		AppliedOn: day(2026, time.June, 1), AppliedBy: "R. Kumar",
	}}

	check := CheckCertification(StandardNPOP, "field-1",
		day(2023, time.April, 1), inputs, checkNow)

	if check.Status != StatusInsufficientRecord {
		t.Fatalf("status = %s, want INSUFFICIENT_RECORDS with one year of records",
			check.Status)
	}
	if !strings.Contains(check.Summary, "not enough record") {
		t.Errorf("summary does not explain the gap: %q", check.Summary)
	}
}

func TestFieldStillInConversionIsNotEligible(t *testing.T) {
	// Conversion started in 2025, so the field is eligible from 2028.
	inputs := cleanOrganicRecord()
	for i := range inputs {
		inputs[i].AppliedOn = inputs[i].AppliedOn.AddDate(2, 0, 0)
		inputs[i].Year += 2
	}

	check := CheckCertification(StandardNPOP, "field-1",
		day(2025, time.April, 1), inputs, day(2027, time.September, 15))

	if check.Status != StatusInConversion {
		t.Fatalf("status = %s, want IN_CONVERSION", check.Status)
	}
	if check.EligibleFrom.Year() != 2028 {
		t.Errorf("eligible from %s, want 2028 — three years after conversion began",
			check.EligibleFrom.Format("2006-01-02"))
	}
}

// A blacklist would pass every formulation it had not heard of, which is the
// wrong direction for a certification check to fail in.
func TestUnrecognisedPesticideFailsClosed(t *testing.T) {
	inputs := append(cleanOrganicRecord(), InputUse{
		ID: "unknown-spray", Category: CategoryPesticide,
		Product: "Cropguard Ultra", Quantity: 2, Year: 2026,
		AppliedOn: day(2026, time.August, 1),
	})

	check := CheckCertification(StandardNPOP, "field-1",
		day(2023, time.April, 1), inputs, checkNow)

	if check.Status != StatusBlocked {
		t.Fatalf("status = %s; an unrecognised crop protection product should not pass",
			check.Status)
	}
}

func TestPermittedBiopesticidesPass(t *testing.T) {
	for _, product := range []string{
		"Neem oil", "Bacillus thuringiensis var kurstaki", "Trichoderma viride",
		"Bordeaux mixture", "Pheromone traps", "Panchagavya",
	} {
		permitted, reason := IsOrganicPermitted(CategoryPesticide, product)
		if !permitted {
			t.Errorf("%q was rejected: %s", product, reason)
		}
	}
}

func TestResidueBurningIsProhibitedUnderOrganic(t *testing.T) {
	permitted, reason := IsOrganicPermitted(CategoryResidueBurn, "paddy stubble")
	if permitted {
		t.Fatal("in-field residue burning should not pass an organic check")
	}
	if reason == "" {
		t.Error("the rejection gives no reason")
	}
}

// An organic farm still runs a tractor.
func TestDieselIsNotProhibitedUnderOrganic(t *testing.T) {
	if permitted, _ := IsOrganicPermitted(CategoryDiesel, "HSD"); !permitted {
		t.Fatal("diesel is not prohibited under organic standards")
	}
}

// Nitrogen with no figure behind it is a real problem for a nutrient budget,
// but it is not the same problem as applying urea, and conflating the two
// makes the blockers harder to find.
func TestUnquantifiedNitrogenIsMajorNotBlocking(t *testing.T) {
	inputs := []InputUse{}
	for _, year := range []int{2024, 2025, 2026} {
		inputs = append(inputs, InputUse{
			ID: "fym-" + strconv.Itoa(year), Category: CategoryOrganicN,
			Product: "Some manure", Quantity: 3000, NitrogenKg: 0,
			Year: year, AppliedOn: day(year, time.June, 1), AppliedBy: "R. Kumar",
		})
	}

	check := CheckCertification(StandardNPOP, "field-1",
		day(2023, time.April, 1), inputs, checkNow)

	if check.Status == StatusBlocked {
		t.Fatalf("an unquantified nitrogen figure blocked the claim outright: %+v", check.Findings)
	}
	found := false
	for _, f := range check.Findings {
		if f.Code == "UNQUANTIFIED_NITROGEN" {
			found = true
			if f.Severity != SeverityMajor {
				t.Errorf("severity = %s, want MAJOR", f.Severity)
			}
		}
	}
	if !found {
		t.Error("nitrogen with no figure behind it was not raised at all")
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// GlobalGAP
// ─────────────────────────────────────────────────────────────────────────────

// GlobalGAP does not prohibit synthetic inputs; it asks that every application
// is recorded. Running the organic rules against it would be assessing the
// wrong thing and calling it a result.
func TestGlobalGAPDoesNotProhibitSyntheticInputs(t *testing.T) {
	inputs := []InputUse{}
	for _, year := range []int{2025, 2026} {
		inputs = append(inputs, InputUse{
			ID: "urea-" + strconv.Itoa(year), Category: CategoryUrea, Product: "Urea 46%",
			Quantity: 200, NitrogenKg: 92, Year: year,
			AppliedOn: day(year, time.July, 1), AppliedBy: "R. Kumar",
		})
	}

	check := CheckCertification(StandardGlobalGAP, "field-1", time.Time{}, inputs, checkNow)

	if check.Status != StatusEligible {
		t.Fatalf("status = %s, want ELIGIBLE — GlobalGAP allows synthetic fertiliser. "+
			"Findings: %+v", check.Status, check.Findings)
	}
}

func TestGlobalGAPFlagsAnApplicationWithNoDate(t *testing.T) {
	inputs := []InputUse{}
	for _, year := range []int{2025, 2026} {
		inputs = append(inputs, InputUse{
			ID: "urea-" + strconv.Itoa(year), Category: CategoryUrea, Product: "Urea",
			Quantity: 200, Year: year, AppliedBy: "R. Kumar",
			CreatedAt: day(year, time.July, 1),
		})
	}

	check := CheckCertification(StandardGlobalGAP, "field-1", time.Time{}, inputs, checkNow)

	found := false
	for _, f := range check.Findings {
		if f.Code == "NO_APPLICATION_DATE" {
			found = true
		}
	}
	if !found {
		t.Error("an application with no date was not flagged; without it a pre-harvest " +
			"interval cannot be verified")
	}
}

func TestGlobalGAPBlocksAnUnidentifiedPesticide(t *testing.T) {
	inputs := []InputUse{{
		ID: "spray-1", Category: CategoryPesticide, Product: "",
		Quantity: 2, Year: 2026, AppliedOn: day(2026, time.August, 1),
		AppliedBy: "R. Kumar",
	}}

	check := CheckCertification(StandardGlobalGAP, "field-1", time.Time{}, inputs, checkNow)
	if check.Status != StatusBlocked {
		t.Fatalf("status = %s; a crop protection application with no product name "+
			"cannot be checked at all", check.Status)
	}
}

// Fairtrade and Rainforest turn on labour, price and habitat records this
// service does not hold. Saying so beats running the wrong rules and reporting
// a verdict.
func TestStandardsThisServiceCannotAssessSayso(t *testing.T) {
	for _, standard := range []CertificationStandard{StandardFairtrade, StandardRainforest} {
		check := CheckCertification(standard, "field-1", time.Time{}, cleanOrganicRecord(), checkNow)
		if check.Status != StatusInsufficientRecord {
			t.Errorf("%s status = %s, want INSUFFICIENT_RECORDS", standard, check.Status)
		}
		if !strings.Contains(check.Summary, "does not hold") {
			t.Errorf("%s summary does not say what is missing: %q", standard, check.Summary)
		}
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Findings order and export
// ─────────────────────────────────────────────────────────────────────────────

// A blocker buried under twenty record-keeping notes gets missed.
func TestBlockersSortAboveEverythingElse(t *testing.T) {
	inputs := append(cleanOrganicRecord(),
		InputUse{
			ID: "manure-no-n", Category: CategoryOrganicN, Product: "Manure",
			Quantity: 1000, Year: 2026, AppliedOn: day(2026, time.January, 5),
		},
		InputUse{
			ID: "urea-slip", Category: CategoryUrea, Product: "Urea",
			Quantity: 50, NitrogenKg: 23, Year: 2026,
			AppliedOn: day(2026, time.August, 20),
		},
	)

	check := CheckCertification(StandardNPOP, "field-1",
		day(2023, time.April, 1), inputs, checkNow)

	if len(check.Findings) < 2 {
		t.Fatalf("expected at least two findings, got %d", len(check.Findings))
	}
	if check.Findings[0].Severity != SeverityBlocker {
		t.Errorf("the first finding is %s, not the blocker", check.Findings[0].Severity)
	}
}

// The value of the pack is that it says the same thing whether or not the
// answer is convenient.
func TestExportPackCarriesTheFindingsNotJustTheCleanRows(t *testing.T) {
	inputs := append(cleanOrganicRecord(), InputUse{
		ID: "urea-slip", Category: CategoryUrea, Product: "Urea 46%",
		Quantity: 100, NitrogenKg: 46, Year: 2025,
		AppliedOn: day(2025, time.August, 3),
	})
	check := CheckCertification(StandardNPOP, "field-1",
		day(2023, time.April, 1), inputs, checkNow)

	content, err := ExportPack(check, inputs)
	if err != nil {
		t.Fatalf("ExportPack: %v", err)
	}
	text := string(content)

	for _, want := range []string{"BLOCKED", "PROHIBITED_INPUT", "urea-slip", "Urea 46%"} {
		if !strings.Contains(text, want) {
			t.Errorf("the pack does not contain %q — an export that omits the "+
				"inconvenient rows is not evidence", want)
		}
	}
	if !strings.Contains(text, "Farmyard manure") {
		t.Error("the pack is missing the ordinary input records")
	}
}

func TestExportPackOfACleanRecordSaysThereAreNoFindings(t *testing.T) {
	check := CheckCertification(StandardNPOP, "field-1",
		day(2023, time.April, 1), cleanOrganicRecord(), checkNow)

	content, err := ExportPack(check, cleanOrganicRecord())
	if err != nil {
		t.Fatalf("ExportPack: %v", err)
	}
	if !strings.Contains(string(content), "no findings") {
		t.Error("a clean pack does not say that there were no findings")
	}
}

func TestExportFilenameNamesTheStandardAndField(t *testing.T) {
	check := CertificationCheck{FieldID: "field-1", Standard: StandardNPOP}
	name := ExportFilename(check, checkNow)
	if name != "npop-field-1-2026-09-15.csv" {
		t.Errorf("filename = %q", name)
	}
}
