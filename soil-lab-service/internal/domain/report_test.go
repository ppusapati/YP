package domain

import (
	"strings"
	"testing"
	"time"
)

var now = time.Date(2026, 3, 14, 9, 0, 0, 0, time.UTC)

func parse(t *testing.T, csv string, aliases map[string]string) []ReportRow {
	t.Helper()
	rows, err := ParseCSV([]byte(csv), aliases, now)
	if err != nil {
		t.Fatalf("parse: %v", err)
	}
	return rows
}

// ─────────────────────────────────────────────────────────────────────────────
// Header matching
// ─────────────────────────────────────────────────────────────────────────────

func TestNormaliseHeader(t *testing.T) {
	// A lab that changes "(ppm)" to "(mg/kg)" in a new export format must not
	// break the import: the unit is not what identifies the column.
	cases := map[string]string{
		"Avail. P (ppm)":   "availp",
		"avail p (mg/kg)":  "availp",
		"  pH  ":           "ph",
		"Organic Matter %": "organicmatter",
		"Field ID":         "fieldid",
	}
	for in, want := range cases {
		if got := normaliseHeader(in); got != want {
			t.Errorf("normaliseHeader(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestParseCSV_MatchesCommonHeaderSpellings(t *testing.T) {
	rows := parse(t, `Field ID,pH,Avail. N (ppm),Avail. P (ppm),K (ppm)
fld-1,6.8,220,18,190
`, nil)

	if len(rows) != 1 {
		t.Fatalf("rows = %d", len(rows))
	}
	if !rows[0].Usable() {
		t.Fatalf("row blocked: %s", rows[0].Blocker)
	}
	if len(rows[0].Results) != 4 {
		t.Fatalf("results = %d, want 4: %+v", len(rows[0].Results), rows[0].Results)
	}
}

func TestParseCSV_ALabsOwnAliasWins(t *testing.T) {
	// The alias was configured by somebody who has seen this lab's export; the
	// built-in table is a guess that works for most.
	rows := parse(t, `Field ID,P2O5
fld-1,42
`, map[string]string{"p2o5": string(AnalytePhosphorus)})

	if len(rows[0].Results) != 1 {
		t.Fatalf("results = %+v", rows[0].Results)
	}
	if rows[0].Results[0].Analyte != AnalytePhosphorus {
		t.Errorf("analyte = %s, want phosphorus", rows[0].Results[0].Analyte)
	}
}

func TestParseCSV_IgnoresColumnsItDoesNotRecognise(t *testing.T) {
	// A lab CSV carries plenty that is not a measurement — technician
	// initials, batch numbers. Inventing an analyte for them would put noise
	// into a fertiliser prescription.
	rows := parse(t, `Field ID,pH,Technician,Batch
fld-1,6.8,RP,B-2291
`, nil)

	if len(rows[0].Results) != 1 {
		t.Fatalf("results = %+v; only pH is a measurement", rows[0].Results)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// File-level failures
// ─────────────────────────────────────────────────────────────────────────────

func TestParseCSV_RefusesAFileWithNoFieldColumn(t *testing.T) {
	// Results that cannot be attached to a field are results nobody can use.
	_, err := ParseCSV([]byte("pH,N\n6.8,220\n"), nil, now)
	if err != ErrNoFieldColumn {
		t.Fatalf("expected ErrNoFieldColumn, got %v", err)
	}
}

func TestParseCSV_RefusesAnEmptyFile(t *testing.T) {
	if _, err := ParseCSV(nil, nil, now); err != ErrEmptyFile {
		t.Fatalf("expected ErrEmptyFile, got %v", err)
	}
}

func TestParseCSV_RefusesAHeaderWithNoData(t *testing.T) {
	if _, err := ParseCSV([]byte("Field ID,pH\n"), nil, now); err != ErrNoRows {
		t.Fatalf("expected ErrNoRows, got %v", err)
	}
}

func TestParseCSV_ToleratesRaggedRows(t *testing.T) {
	// Labs pad rows unevenly; a short row is a missing measurement, not a
	// malformed file.
	rows := parse(t, `Field ID,pH,N,P
fld-1,6.8,220,18
fld-2,7.1,240
`, nil)

	if len(rows) != 2 {
		t.Fatalf("rows = %d, want 2", len(rows))
	}
	if !rows[1].Usable() {
		t.Errorf("the short row was blocked: %s", rows[1].Blocker)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Row-level blockers
// ─────────────────────────────────────────────────────────────────────────────

func TestParseCSV_BlocksARowWithNoFieldID(t *testing.T) {
	// Not dropped. A soil report is the input to a fertiliser prescription,
	// and an import that quietly loses rows produces a prescription for half
	// a field.
	rows := parse(t, `Field ID,pH
fld-1,6.8
,7.1
`, nil)

	if len(rows) != 2 {
		t.Fatalf("rows = %d; nothing may be silently dropped", len(rows))
	}
	if rows[1].Usable() {
		t.Fatal("a row with no field was marked usable")
	}
	if !strings.Contains(rows[1].Blocker, "field identifier") {
		t.Errorf("blocker = %q", rows[1].Blocker)
	}
}

func TestParseCSV_BlocksARowWithNoReadings(t *testing.T) {
	rows := parse(t, `Field ID,pH
fld-1,
`, nil)

	if rows[0].Usable() {
		t.Fatal("a row with no readings was marked usable")
	}
	if !strings.Contains(rows[0].Blocker, "no readings") {
		t.Errorf("blocker = %q", rows[0].Blocker)
	}
}

func TestParseCSV_ABlankCellIsNotZero(t *testing.T) {
	// Storing a blank as zero would say the soil contains none of that
	// nutrient, which is the opposite of "the lab did not run that test".
	rows := parse(t, `Field ID,pH,N,P
fld-1,6.8,,18
`, nil)

	for _, r := range rows[0].Results {
		if r.Analyte == AnalyteNitrogen {
			t.Fatal("a blank nitrogen cell became a reading")
		}
	}
	if len(rows[0].Results) != 2 {
		t.Errorf("results = %+v", rows[0].Results)
	}
}

func TestParseCSV_BelowDetectionIsRecordedNotGuessed(t *testing.T) {
	// Labs write "<0.5" and "ND". Reading either as a number would invent a
	// value; dropping it would hide that the test was run.
	rows := parse(t, `Field ID,B
fld-1,<0.5
`, nil)

	if len(rows[0].Results) != 1 {
		t.Fatalf("results = %+v", rows[0].Results)
	}
	result := rows[0].Results[0]
	if !result.Suspect {
		t.Error("a non-numeric reading was not flagged")
	}
	if result.Value != 0 || !strings.Contains(result.Note, "<0.5") {
		t.Errorf("result = %+v; the note should carry what the lab actually said", result)
	}
}

func TestParseCSV_StripsThousandsSeparators(t *testing.T) {
	rows := parse(t, `Field ID,Ca
fld-1,"2,400"
`, nil)

	if rows[0].Results[0].Value != 2400 {
		t.Errorf("value = %v, want 2400", rows[0].Results[0].Value)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Dates
// ─────────────────────────────────────────────────────────────────────────────

func TestParseCSV_ReadsDayFirstDates(t *testing.T) {
	// Indian labs write 03/02/2026 meaning 3 February. Reading it as 2 March
	// puts a sample in the wrong season, which changes what a prescription
	// says.
	rows := parse(t, `Field ID,Date,pH
fld-1,03/02/2026,6.8
`, nil)

	if !rows[0].Usable() {
		t.Fatalf("row blocked: %s", rows[0].Blocker)
	}
	got := rows[0].CollectedOn
	if got.Month() != time.February || got.Day() != 3 {
		t.Errorf("collected on %s, want 3 February", got.Format("2 January 2006"))
	}
}

func TestParseCSV_ReadsISODates(t *testing.T) {
	rows := parse(t, `Field ID,Collection Date,pH
fld-1,2026-03-04,6.8
`, nil)

	if rows[0].CollectedOn.Format("2006-01-02") != "2026-03-04" {
		t.Errorf("collected on %s", rows[0].CollectedOn)
	}
}

func TestParseCSV_BlocksAnUnreadableDate(t *testing.T) {
	rows := parse(t, `Field ID,Date,pH
fld-1,last Tuesday,6.8
`, nil)

	if rows[0].Usable() {
		t.Fatal("a row with an unreadable date was marked usable")
	}
	if !strings.Contains(rows[0].Blocker, "not a date") {
		t.Errorf("blocker = %q", rows[0].Blocker)
	}
}

func TestParseCSV_BlocksAFutureCollectionDate(t *testing.T) {
	// A sample cannot have been collected next month; it is a typo or a
	// timezone bug, and either way the date drives the season a prescription
	// is calculated for.
	rows := parse(t, `Field ID,Date,pH
fld-1,2027-01-01,6.8
`, nil)

	if rows[0].Usable() {
		t.Fatal("a future collection date was accepted")
	}
	if !strings.Contains(rows[0].Blocker, "future") {
		t.Errorf("blocker = %q", rows[0].Blocker)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Plausibility
// ─────────────────────────────────────────────────────────────────────────────

func TestParseCSV_FlagsAUnitMismatch(t *testing.T) {
	// Phosphorus at 4,500 is not a rich soil; it is kg/ha that nobody
	// converted. Applied to a prescription it would tell a farmer to add
	// nothing to a field that needs feeding.
	rows := parse(t, `Field ID,P
fld-1,4500
`, nil)

	result := rows[0].Results[0]
	if !result.Suspect {
		t.Fatal("an implausible phosphorus reading was accepted")
	}
	if !strings.Contains(result.Note, "unit mismatch") {
		t.Errorf("note = %q; it should say what is probably wrong", result.Note)
	}
	// Kept, not dropped: a person needs to see what the lab sent.
	if result.Value != 4500 {
		t.Errorf("value = %v; the reading should be preserved", result.Value)
	}
}

func TestParseCSV_FlagsAnImpossiblePH(t *testing.T) {
	rows := parse(t, `Field ID,pH
fld-1,19
`, nil)

	if !rows[0].Results[0].Suspect {
		t.Error("pH 19 was accepted")
	}
}

func TestParseCSV_AcceptsAPlausibleReading(t *testing.T) {
	rows := parse(t, `Field ID,pH,P,K,OM
fld-1,6.8,18,190,1.2
`, nil)

	for _, r := range rows[0].Results {
		if r.Suspect {
			t.Errorf("%s %v was wrongly flagged: %s", r.Analyte, r.Value, r.Note)
		}
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Report status
// ─────────────────────────────────────────────────────────────────────────────

func TestSummarise_CleanReportIsParsed(t *testing.T) {
	report := LabReport{Rows: parse(t, `Field ID,pH
fld-1,6.8
fld-2,7.1
`, nil)}
	report.Summarise()

	if report.Status != StatusParsed {
		t.Fatalf("status = %s, want PARSED", report.Status)
	}
	if report.RowCount != 2 || report.BlockedCount != 0 {
		t.Errorf("counts = %d/%d", report.RowCount, report.BlockedCount)
	}
}

func TestSummarise_ABlockedRowNeedsReview(t *testing.T) {
	report := LabReport{Rows: parse(t, `Field ID,pH
fld-1,6.8
,7.1
`, nil)}
	report.Summarise()

	if report.Status != StatusNeedsReview {
		t.Fatalf("status = %s, want NEEDS_REVIEW", report.Status)
	}
	if report.BlockedCount != 1 {
		t.Errorf("blocked = %d", report.BlockedCount)
	}
}

func TestSummarise_ASuspectReadingNeedsReview(t *testing.T) {
	// Every row is usable, but one number is probably a unit mismatch — and
	// these numbers become a fertiliser prescription.
	report := LabReport{Rows: parse(t, `Field ID,P
fld-1,4500
`, nil)}
	report.Summarise()

	if report.Status != StatusNeedsReview {
		t.Fatalf("status = %s, want NEEDS_REVIEW", report.Status)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Applying
// ─────────────────────────────────────────────────────────────────────────────

func TestCanApply_RefusesAPartialImportUnlessAsked(t *testing.T) {
	// A partial import nobody chose leaves a field with results from half its
	// samples and no sign the rest are missing.
	report := LabReport{Rows: parse(t, `Field ID,pH
fld-1,6.8
,7.1
`, nil)}
	report.Summarise()

	err := report.CanApply(false)
	if err == nil {
		t.Fatal("a partially blocked report was applied without being asked")
	}
	if !strings.Contains(err.Error(), "skip_blocked") {
		t.Errorf("the refusal does not say how to proceed: %v", err)
	}

	if err := report.CanApply(true); err != nil {
		t.Fatalf("skip_blocked was refused: %v", err)
	}
}

func TestCanApply_RefusesWhenEveryRowIsBlocked(t *testing.T) {
	report := LabReport{Rows: parse(t, `Field ID,pH
,6.8
`, nil)}
	report.Summarise()

	if err := report.CanApply(true); err != ErrNothingToApply {
		t.Fatalf("expected ErrNothingToApply, got %v", err)
	}
}

func TestCanApply_RefusesToApplyTwice(t *testing.T) {
	report := LabReport{Status: StatusApplied, Rows: parse(t, "Field ID,pH\nfld-1,6.8\n", nil)}

	if err := report.CanApply(false); err != ErrAlreadyApplied {
		t.Fatalf("expected ErrAlreadyApplied, got %v", err)
	}
}

func TestCanApply_RefusesARejectedReport(t *testing.T) {
	report := LabReport{Status: StatusRejected, Rows: parse(t, "Field ID,pH\nfld-1,6.8\n", nil)}

	if err := report.CanApply(false); err != ErrRejected {
		t.Fatalf("expected ErrRejected, got %v", err)
	}
}

func TestToSoilSample_LeavesSuspectReadingsOut(t *testing.T) {
	// The report keeps them so a person can see what the lab sent, but a value
	// flagged as a probable unit mismatch must not reach a prescription — and
	// a prescription cannot tell a suspect number from a good one.
	rows := parse(t, `Field ID,pH,P
fld-1,6.8,4500
`, nil)

	sample := rows[0].ToSoilSample("Deccan Soil Labs")

	if _, ok := sample.Values[AnalytePhosphorus]; ok {
		t.Fatal("a suspect reading reached the soil sample")
	}
	if sample.Values[AnalytePH] != 6.8 {
		t.Errorf("the good reading was lost: %+v", sample.Values)
	}
	if !strings.Contains(sample.Notes, "phosphorus_ppm") {
		t.Errorf("the sample does not say what was omitted: %q", sample.Notes)
	}
}

func TestToSoilSample_CarriesTheLabReference(t *testing.T) {
	rows := parse(t, `Field ID,Sample ID,pH
fld-1,LAB-7781,6.8
`, nil)

	sample := rows[0].ToSoilSample("Deccan Soil Labs")

	if !strings.Contains(sample.Notes, "LAB-7781") {
		t.Errorf("notes = %q; the lab reference is how a result is traced back", sample.Notes)
	}
	if sample.CollectedBy != "Deccan Soil Labs" {
		t.Errorf("collected by = %q", sample.CollectedBy)
	}
}

func TestUsableRows(t *testing.T) {
	report := LabReport{Rows: parse(t, `Field ID,pH
fld-1,6.8
,7.1
fld-3,7.4
`, nil)}

	if got := len(report.UsableRows()); got != 2 {
		t.Errorf("usable rows = %d, want 2", got)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Duplicate detection
// ─────────────────────────────────────────────────────────────────────────────

func TestHashContent_KeyedOnBytesNotFilename(t *testing.T) {
	// The same results get re-sent as "results.csv", "results (1).csv" and
	// "results-final.csv". Three sets of soil samples from one set of readings
	// would triple every field's history.
	content := []byte("Field ID,pH\nfld-1,6.8\n")

	if HashContent(content) != HashContent(content) {
		t.Fatal("the same bytes hashed differently")
	}
	if HashContent(content) == HashContent([]byte("Field ID,pH\nfld-1,6.9\n")) {
		t.Fatal("different bytes hashed the same")
	}
}
