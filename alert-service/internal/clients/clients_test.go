package clients

import (
	"testing"
	"time"

	diagnosisv1 "p9e.in/samavaya/agriculture/plant-diagnosis-service/api/v1"
)

// soil-service records moisture_pct as a percentage; the AI gateway's
// soil_moisture is a fraction on the same scale as its own default of 0.30.
// Without the conversion a typical 30% sample arrives as 30.0 — a hundred
// times saturated — and it compiles, runs and looks like a reading.
func TestMoisturePercentBecomesAFraction(t *testing.T) {
	for _, tc := range []struct {
		pct   float64
		want  float64
		found bool
	}{
		{30.0, 0.30, true},  // the gateway's own default, for scale
		{12.5, 0.125, true}, // dry
		{48.0, 0.48, true},  // near saturation
		{100.0, 1.0, true},  // the top of the percentage scale is 1.0, not 100
		{0, 0, false},       // not recorded, not bone dry
		{-1, 0, false},      // nonsense reading
	} {
		got, found := moistureFraction(tc.pct)
		if found != tc.found {
			t.Errorf("moistureFraction(%v) found = %v, want %v", tc.pct, found, tc.found)
		}
		if got != tc.want {
			t.Errorf("moistureFraction(%v) = %v, want %v", tc.pct, got, tc.want)
		}
	}
}

// ---------------------------------------------------------------------------

// The alert engine reads pest_confidence against a 0.6 threshold and
// disease_confidence against 0.5, both probabilities. plant-diagnosis already
// stores confidence_score as a probability, so the number passes straight
// through — this pins that, because a "helpful" ×100 here would put every
// diagnosis over every threshold.
func TestDiagnosisConfidencesPassThroughUnscaled(t *testing.T) {
	got := detectionsFromResult(&diagnosisv1.DiagnosisResult{
		DetectedDiseases: []*diagnosisv1.DiseaseInfo{
			{DiseaseName: "Late blight", ConfidenceScore: 0.82},
		},
		PestDamage: []*diagnosisv1.PestDamage{
			{PestName: "Fall armyworm", ConfidenceScore: 0.71},
		},
	})
	if got == nil {
		t.Fatal("detectionsFromResult = nil for a result with findings")
	}
	if got.DiseaseConfidence != 0.82 || got.DiseaseName != "Late blight" {
		t.Errorf("disease = %v %q, want 0.82 \"Late blight\"", got.DiseaseConfidence, got.DiseaseName)
	}
	if got.PestConfidence != 0.71 || got.PestSpecies != "Fall armyworm" {
		t.Errorf("pest = %v %q, want 0.71 \"Fall armyworm\"", got.PestConfidence, got.PestSpecies)
	}
}

// The gateway has room for one finding of each kind; a diagnosis can report
// several. The worst one is sent, not the first listed — reporting the mildest
// of three problems is a way of saying a sick field is well.
func TestTheWorstFindingOfEachKindIsSent(t *testing.T) {
	got := detectionsFromResult(&diagnosisv1.DiagnosisResult{
		DetectedDiseases: []*diagnosisv1.DiseaseInfo{
			{DiseaseName: "Leaf spot", ConfidenceScore: 0.30},
			{DiseaseName: "Late blight", ConfidenceScore: 0.88},
			{DiseaseName: "Rust", ConfidenceScore: 0.44},
		},
		PestDamage: []*diagnosisv1.PestDamage{
			{PestName: "Aphid", ConfidenceScore: 0.20},
			{PestName: "Stem borer", ConfidenceScore: 0.65},
		},
		NutrientDeficiencies: []*diagnosisv1.NutrientDeficiency{
			{Nutrient: "Potassium", Severity: diagnosisv1.Severity_SEVERITY_MILD},
			{Nutrient: "Nitrogen", Severity: diagnosisv1.Severity_SEVERITY_SEVERE},
		},
	})
	if got == nil {
		t.Fatal("detectionsFromResult = nil for a result with findings")
	}
	if got.DiseaseName != "Late blight" {
		t.Errorf("disease = %q, want the most confident \"Late blight\"", got.DiseaseName)
	}
	if got.PestSpecies != "Stem borer" {
		t.Errorf("pest = %q, want the most confident \"Stem borer\"", got.PestSpecies)
	}
	if got.NutrientType != "Nitrogen" || got.NutrientSeverity != 0.75 {
		t.Errorf("nutrient = %q %v, want \"Nitrogen\" 0.75", got.NutrientType, got.NutrientSeverity)
	}
}

// nutrient_severity is graded, not guessed from a confidence. A model can be
// 99% sure of a barely visible deficiency, and sending 0.99 as the severity
// would raise a critical alert about a trace of yellowing.
func TestNutrientSeverityComesFromTheGradeNotTheConfidence(t *testing.T) {
	got := detectionsFromResult(&diagnosisv1.DiagnosisResult{
		NutrientDeficiencies: []*diagnosisv1.NutrientDeficiency{
			{Nutrient: "Magnesium", ConfidenceScore: 0.99, Severity: diagnosisv1.Severity_SEVERITY_MILD},
		},
	})
	if got == nil {
		t.Fatal("detectionsFromResult = nil")
	}
	if got.NutrientSeverity != 0.25 {
		t.Errorf("NutrientSeverity = %v, want MILD's 0.25 rather than the 0.99 confidence", got.NutrientSeverity)
	}
}

// The grades straddle the gateway's 0.5 threshold, which it compares with >=.
// MODERATE is the mildest grade that should reach a farmer; MILD is not.
func TestSeverityGradesStraddleTheGatewayThreshold(t *testing.T) {
	const gatewayThreshold = 0.5
	for _, tc := range []struct {
		grade  diagnosisv1.Severity
		want   float64
		graded bool
		alerts bool
	}{
		{diagnosisv1.Severity_SEVERITY_UNSPECIFIED, 0, false, false},
		{diagnosisv1.Severity_SEVERITY_MILD, 0.25, true, false},
		{diagnosisv1.Severity_SEVERITY_MODERATE, 0.5, true, true},
		{diagnosisv1.Severity_SEVERITY_SEVERE, 0.75, true, true},
		{diagnosisv1.Severity_SEVERITY_CRITICAL, 1.0, true, true},
	} {
		got, graded := severityScore(tc.grade)
		if graded != tc.graded {
			t.Errorf("severityScore(%v) graded = %v, want %v", tc.grade, graded, tc.graded)
		}
		if got != tc.want {
			t.Errorf("severityScore(%v) = %v, want %v", tc.grade, got, tc.want)
		}
		if alerts := graded && got >= gatewayThreshold; alerts != tc.alerts {
			t.Errorf("severityScore(%v) would alert = %v, want %v", tc.grade, alerts, tc.alerts)
		}
	}
}

// A diagnosis that found nothing reports nothing, rather than a struct of
// zeros with an empty species name in it.
func TestACleanDiagnosisReportsNothing(t *testing.T) {
	if got := detectionsFromResult(&diagnosisv1.DiagnosisResult{Summary: "healthy"}); got != nil {
		t.Errorf("detectionsFromResult = %+v for a clean diagnosis, want nil", got)
	}
	if got := detectionsFromResult(nil); got != nil {
		t.Errorf("detectionsFromResult(nil) = %+v, want nil", got)
	}
}

// An ungraded deficiency is "not graded", not "not severe", so on its own it
// is not a finding.
func TestAnUngradedDeficiencyIsNotAFinding(t *testing.T) {
	got := detectionsFromResult(&diagnosisv1.DiagnosisResult{
		NutrientDeficiencies: []*diagnosisv1.NutrientDeficiency{
			{Nutrient: "Zinc", ConfidenceScore: 0.7, Severity: diagnosisv1.Severity_SEVERITY_UNSPECIFIED},
		},
	})
	if got != nil {
		t.Errorf("detectionsFromResult = %+v, want nil for an ungraded deficiency", got)
	}
}

// Detections describe the field now. Without an age bound the newest diagnosis
// on a quiet field is last season's, and the farmer is told every scan about a
// pest that was dealt with months ago.
func TestAStaleDiagnosisIsNotCurrentEvidence(t *testing.T) {
	now := time.Date(2026, 9, 23, 12, 0, 0, 0, time.UTC)
	for _, tc := range []struct {
		name    string
		age     time.Duration
		stamped bool
		want    bool
	}{
		{"this morning", 6 * time.Hour, true, true},
		{"just inside the window", DefaultDiagnosisMaxAge - time.Minute, true, true},
		{"exactly at the window", DefaultDiagnosisMaxAge, true, true},
		{"just outside the window", DefaultDiagnosisMaxAge + time.Minute, true, false},
		{"last season", 180 * 24 * time.Hour, true, false},
		// Kept: created_at is not nullable and the listing is ordered by it,
		// so a missing one means transport, not age.
		{"no timestamp at all", 0, false, true},
	} {
		if got := withinMaxAge(now.Add(-tc.age), tc.stamped, DefaultDiagnosisMaxAge, now); got != tc.want {
			t.Errorf("%s: withinMaxAge = %v, want %v", tc.name, got, tc.want)
		}
	}
}
