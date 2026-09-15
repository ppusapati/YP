package domain

import (
	"strings"
	"testing"
	"time"
)

var (
	lossStart = time.Date(2026, time.August, 1, 0, 0, 0, 0, time.UTC)
	lossEnd   = time.Date(2026, time.August, 20, 0, 0, 0, 0, time.UTC)
)

func scene(day int, value, cloud float64) NDVIObservation {
	return NDVIObservation{
		At:         time.Date(2026, time.July, day, 0, 0, 0, 0, time.UTC),
		Value:      value,
		CloudCover: cloud,
		Reference:  "scene-july-" + string(rune('0'+day%10)),
	}
}

func sceneOn(t time.Time, value, cloud float64) NDVIObservation {
	return NDVIObservation{At: t, Value: value, CloudCover: cloud, Reference: "scene"}
}

// ─────────────────────────────────────────────────────────────────────────────
// Payout arithmetic
// ─────────────────────────────────────────────────────────────────────────────

func TestIndicatedPayoutIsTheShortfallAgainstTheThreshold(t *testing.T) {
	// Half the threshold yield on 2 ha at ₹50,000/ha cover.
	payout := IndicatedPayout(4000, 2000, 50000, 2)
	if !closeTo(payout, 50000, 1) {
		t.Errorf("payout = %.0f, want 50000 — a 50%% shortfall on ₹100,000 of cover", payout)
	}
}

func TestNoPayoutAboveTheThreshold(t *testing.T) {
	if payout := IndicatedPayout(4000, 4200, 50000, 2); payout != 0 {
		t.Errorf("payout = %.0f for a yield above the threshold", payout)
	}
}

func TestPayoutIsCappedAtTheFullSumInsured(t *testing.T) {
	// A total loss cannot pay more than the cover.
	payout := IndicatedPayout(4000, 0, 50000, 2)
	if !closeTo(payout, 100000, 1) {
		t.Errorf("payout = %.0f, want the full 100000", payout)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Satellite evidence
// ─────────────────────────────────────────────────────────────────────────────

func TestNDVICollapseSupportsAClaim(t *testing.T) {
	observations := []NDVIObservation{
		scene(5, 0.68, 0.05),
		scene(20, 0.72, 0.10),
		sceneOn(lossStart.AddDate(0, 0, 5), 0.30, 0.10),
		sceneOn(lossStart.AddDate(0, 0, 14), 0.24, 0.05),
	}

	evidence := AssessNDVI(observations, lossStart, lossEnd)
	if evidence.Verdict != VerdictSupports {
		t.Fatalf("verdict = %s, want SUPPORTS after a 0.72 to 0.24 collapse. Summary: %s",
			evidence.Verdict, evidence.Summary)
	}
	if !closeTo(evidence.Baseline, 0.72, 0.001) {
		t.Errorf("baseline = %.2f, want the 0.72 peak before the loss", evidence.Baseline)
	}
	if !closeTo(evidence.Observed, 0.24, 0.001) {
		t.Errorf("observed = %.2f, want the 0.24 low during the loss", evidence.Observed)
	}
}

func TestAHealthyCanopyContradictsAClaim(t *testing.T) {
	observations := []NDVIObservation{
		scene(5, 0.66, 0.05),
		scene(20, 0.70, 0.05),
		sceneOn(lossStart.AddDate(0, 0, 7), 0.69, 0.05),
		sceneOn(lossStart.AddDate(0, 0, 15), 0.71, 0.05),
	}

	evidence := AssessNDVI(observations, lossStart, lossEnd)
	if evidence.Verdict != VerdictContradicts {
		t.Fatalf("verdict = %s, want CONTRADICTS for an undamaged canopy. Summary: %s",
			evidence.Verdict, evidence.Summary)
	}
}

// The case this design exists for: floods arrive with cloud, so the claims
// most likely to be genuine are exactly the ones the satellite cannot see.
func TestCloudyScenesDoNotContradictAClaim(t *testing.T) {
	observations := []NDVIObservation{
		scene(5, 0.68, 0.05),
		scene(20, 0.70, 0.05),
		// Cloud tops read high, which without the mask would look like a
		// perfectly healthy crop right through a flood.
		sceneOn(lossStart.AddDate(0, 0, 5), 0.75, 0.90),
		sceneOn(lossStart.AddDate(0, 0, 12), 0.78, 0.85),
	}

	evidence := AssessNDVI(observations, lossStart, lossEnd)
	if evidence.Verdict == VerdictContradicts {
		t.Fatalf("a flood claim was contradicted by cloud tops: %s", evidence.Summary)
	}
	if evidence.Verdict != VerdictInconclusive {
		t.Errorf("verdict = %s, want INCONCLUSIVE", evidence.Verdict)
	}
	if !strings.Contains(evidence.Summary, "absence of evidence") {
		t.Errorf("the summary does not say that silence is not a refutation: %q",
			evidence.Summary)
	}
	if !strings.Contains(evidence.Summary, "cloudy scene") {
		t.Errorf("the summary does not say the scenes were discarded: %q", evidence.Summary)
	}
}

func TestNoBaselineIsInconclusive(t *testing.T) {
	observations := []NDVIObservation{
		sceneOn(lossStart.AddDate(0, 0, 5), 0.30, 0.05),
	}

	evidence := AssessNDVI(observations, lossStart, lossEnd)
	if evidence.Verdict != VerdictInconclusive {
		t.Fatalf("verdict = %s with no pre-loss reading", evidence.Verdict)
	}
	if !strings.Contains(evidence.Summary, "before the loss") {
		t.Errorf("the summary does not say what is missing: %q", evidence.Summary)
	}
}

// After the window the field may have been replanted or cleared, and either
// would read as a recovery that never happened to the insured crop.
func TestReadingsAfterTheWindowAreNotUsed(t *testing.T) {
	observations := []NDVIObservation{
		scene(5, 0.70, 0.05),
		sceneOn(lossStart.AddDate(0, 0, 5), 0.22, 0.05),
		// A replanted crop six weeks later.
		sceneOn(lossEnd.AddDate(0, 0, 40), 0.75, 0.05),
	}

	evidence := AssessNDVI(observations, lossStart, lossEnd)
	if evidence.Verdict != VerdictSupports {
		t.Fatalf("verdict = %s; a post-window recovery masked the loss. Summary: %s",
			evidence.Verdict, evidence.Summary)
	}
}

// The baseline is the peak before the loss, not the mean of the run-up: NDVI
// climbs through the season, so a mean would sit below the canopy the crop had
// actually reached and would understate every drop.
func TestTheBaselineIsThePeakNotTheMean(t *testing.T) {
	observations := []NDVIObservation{
		scene(1, 0.20, 0.05), // early season, bare soil
		scene(10, 0.45, 0.05),
		scene(25, 0.70, 0.05), // full canopy
		sceneOn(lossStart.AddDate(0, 0, 6), 0.50, 0.05),
	}

	evidence := AssessNDVI(observations, lossStart, lossEnd)
	if !closeTo(evidence.Baseline, 0.70, 0.001) {
		t.Errorf("baseline = %.2f, want the 0.70 peak", evidence.Baseline)
	}
	// 0.70 to 0.50 is a 29% fall, which should register.
	if evidence.Verdict != VerdictSupports {
		t.Errorf("verdict = %s; against the mean of 0.45 this fall would have "+
			"disappeared. Summary: %s", evidence.Verdict, evidence.Summary)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Weather evidence
// ─────────────────────────────────────────────────────────────────────────────

func TestDroughtIsSupportedByARainfallDeficit(t *testing.T) {
	evidence := AssessWeather(CauseDrought, WeatherWindow{
		RainfallMM: 30, NormalRainfallMM: 180, HasNormal: true,
		DryDays: 24, Days: 45,
	})
	if evidence.Verdict != VerdictSupports {
		t.Fatalf("verdict = %s for 30 mm against a 180 mm normal. Summary: %s",
			evidence.Verdict, evidence.Summary)
	}
}

func TestDroughtIsContradictedByNormalRainfall(t *testing.T) {
	evidence := AssessWeather(CauseDrought, WeatherWindow{
		RainfallMM: 200, NormalRainfallMM: 180, HasNormal: true,
		DryDays: 3, Days: 45,
	})
	if evidence.Verdict != VerdictContradicts {
		t.Fatalf("verdict = %s for above-normal rainfall on a drought claim", evidence.Verdict)
	}
}

// Running one test for every cause would confirm a flood claim on the strength
// of a dry spell.
func TestAFloodClaimIsNotConfirmedByADrySpell(t *testing.T) {
	evidence := AssessWeather(CauseFlood, WeatherWindow{
		RainfallMM: 10, NormalRainfallMM: 180, HasNormal: true,
		DryDays: 20, Days: 30,
	})
	if evidence.Verdict == VerdictSupports {
		t.Fatalf("a flood claim was supported by 10 mm of rain: %s", evidence.Summary)
	}
}

func TestFloodIsSupportedByHeavyRain(t *testing.T) {
	evidence := AssessWeather(CauseFlood, WeatherWindow{
		RainfallMM: 420, NormalRainfallMM: 150, HasNormal: true, Days: 6,
	})
	if evidence.Verdict != VerdictSupports {
		t.Fatalf("verdict = %s for 420 mm in six days. Summary: %s",
			evidence.Verdict, evidence.Summary)
	}
}

// Reading a dry spell as evidence either way about a pest outbreak would be
// assessing the wrong thing and calling it a result.
func TestCausesTheWeatherCannotSpeakToSaySo(t *testing.T) {
	for _, cause := range []LossCause{CausePest, CauseDisease, CauseHail, CauseFire} {
		evidence := AssessWeather(cause, WeatherWindow{
			RainfallMM: 10, NormalRainfallMM: 180, HasNormal: true, DryDays: 25, Days: 30,
		})
		if evidence.Verdict != VerdictInconclusive {
			t.Errorf("%s: verdict = %s, want INCONCLUSIVE", cause, evidence.Verdict)
		}
		if !strings.Contains(evidence.Summary, "not something a rainfall") {
			t.Errorf("%s: the summary does not say why: %q", cause, evidence.Summary)
		}
	}
}

func TestNoWeatherRecordIsInconclusive(t *testing.T) {
	evidence := AssessWeather(CauseDrought, WeatherWindow{})
	if evidence.Verdict != VerdictInconclusive {
		t.Fatalf("verdict = %s with no weather record", evidence.Verdict)
	}
}

func TestDroughtWithoutALongRunNormalIsInconclusive(t *testing.T) {
	evidence := AssessWeather(CauseDrought, WeatherWindow{
		RainfallMM: 30, DryDays: 10, Days: 45,
	})
	if evidence.Verdict != VerdictInconclusive {
		t.Fatalf("verdict = %s; 30 mm means nothing without knowing what is normal here",
			evidence.Verdict)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Reported yield
// ─────────────────────────────────────────────────────────────────────────────

func TestAReportedYieldAboveTheThresholdContradictsTheClaim(t *testing.T) {
	evidence := AssessReportedYield(4200, 4000, nil)
	if evidence.Verdict != VerdictContradicts {
		t.Fatalf("verdict = %s for a yield above the insured threshold", evidence.Verdict)
	}
}

func TestAReportedShortfallSupportsTheClaim(t *testing.T) {
	evidence := AssessReportedYield(1500, 4000, steadyHistory(5, 4200))
	if evidence.Verdict != VerdictSupports {
		t.Fatalf("verdict = %s for a yield well below the threshold", evidence.Verdict)
	}
	if !strings.Contains(evidence.Summary, "averaged") {
		t.Errorf("the summary does not put the figure against the field's own record: %q",
			evidence.Summary)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// The pack as a whole
// ─────────────────────────────────────────────────────────────────────────────

// This service assembles evidence; an insurer decides. A summary that said
// "approved" would be read as a decision by everybody downstream.
func TestTheSummaryNeverDecidesTheClaim(t *testing.T) {
	packs := [][]Evidence{
		{{Verdict: VerdictSupports}, {Verdict: VerdictSupports}},
		{{Verdict: VerdictContradicts}, {Verdict: VerdictContradicts}},
		{{Verdict: VerdictSupports}, {Verdict: VerdictContradicts}},
		{{Verdict: VerdictInconclusive}},
	}

	for _, pack := range packs {
		summary := SummariseEvidence(pack)
		lower := strings.ToLower(summary)
		for _, word := range []string{"approved", "denied", "rejected", "payable"} {
			if strings.Contains(lower, word) {
				t.Errorf("the summary decides the claim with %q: %s", word, summary)
			}
		}
		if !strings.Contains(summary, "not a decision") {
			t.Errorf("the summary does not say it is not a decision: %s", summary)
		}
	}
}

// An empty pack is a reason to send an inspector, not a reason to refuse.
func TestAnInconclusivePackSaysToSendAnInspector(t *testing.T) {
	summary := SummariseEvidence([]Evidence{
		{Verdict: VerdictInconclusive}, {Verdict: VerdictInconclusive},
	})
	if !strings.Contains(summary, "send an inspector") {
		t.Errorf("summary = %q; it does not say what to do about knowing nothing", summary)
	}
}

func TestDisagreeingSourcesAskForAPerson(t *testing.T) {
	summary := SummariseEvidence([]Evidence{
		{Verdict: VerdictSupports}, {Verdict: VerdictContradicts},
	})
	if !strings.Contains(summary, "needs a person") {
		t.Errorf("summary = %q; disagreeing sources should be escalated", summary)
	}
}

func TestAnEmptyPackSaysSo(t *testing.T) {
	if !strings.Contains(SummariseEvidence(nil), "No evidence") {
		t.Error("an empty pack does not say it is empty")
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Validation
// ─────────────────────────────────────────────────────────────────────────────

func TestClaimValidation(t *testing.T) {
	valid := Claim{
		FieldID: "field-1", Cause: CauseDrought,
		ClaimedAreaHectares: 2, LossStartedOn: lossStart,
	}
	if err := valid.Validate(); err != nil {
		t.Fatalf("a valid claim was rejected: %v", err)
	}

	for name, mutate := range map[string]func(*Claim){
		"no field": func(c *Claim) { c.FieldID = "" },
		"no cause": func(c *Claim) { c.Cause = "" },
		"no area":  func(c *Claim) { c.ClaimedAreaHectares = 0 },
		"no date":  func(c *Claim) { c.LossStartedOn = time.Time{} },
	} {
		claim := valid
		mutate(&claim)
		if err := claim.Validate(); err == nil {
			t.Errorf("%s was accepted", name)
		}
	}
}

func TestOnlyOpenClaimsAreEditable(t *testing.T) {
	for status, want := range map[ClaimStatus]bool{
		ClaimDraft:         true,
		ClaimSubmitted:     true,
		ClaimEvidenceReady: false,
		ClaimSettled:       false,
		ClaimRejected:      false,
		ClaimWithdrawn:     false,
	} {
		claim := Claim{Status: status}
		if got := claim.Editable(); got != want {
			t.Errorf("a %s claim editable = %v, want %v", status, got, want)
		}
	}
}
