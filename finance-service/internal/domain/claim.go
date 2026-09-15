package domain

import (
	"fmt"
	"sort"
	"strings"
	"time"
)

// LossCause is what the claimant says damaged the crop.
type LossCause string

const (
	CauseDrought        LossCause = "DROUGHT"
	CauseFlood          LossCause = "FLOOD"
	CauseUnseasonalRain LossCause = "UNSEASONAL_RAIN"
	CauseHail           LossCause = "HAIL"
	CauseCyclone        LossCause = "CYCLONE"
	CausePest           LossCause = "PEST"
	CauseDisease        LossCause = "DISEASE"
	CauseFire           LossCause = "FIRE"
)

// ClaimStatus is where a claim has got to.
type ClaimStatus string

const (
	ClaimDraft         ClaimStatus = "DRAFT"
	ClaimSubmitted     ClaimStatus = "SUBMITTED"
	ClaimEvidenceReady ClaimStatus = "EVIDENCE_READY"
	ClaimSettled       ClaimStatus = "SETTLED"
	ClaimRejected      ClaimStatus = "REJECTED"
	ClaimWithdrawn     ClaimStatus = "WITHDRAWN"
)

// EvidenceSource is where a piece of evidence came from.
type EvidenceSource string

const (
	EvidenceSatelliteNDVI   EvidenceSource = "SATELLITE_NDVI"
	EvidenceWeather         EvidenceSource = "WEATHER"
	EvidenceFieldInspection EvidenceSource = "FIELD_INSPECTION"
	EvidenceYieldRecord     EvidenceSource = "YIELD_RECORD"
	EvidencePhoto           EvidenceSource = "PHOTO"
)

// EvidenceVerdict is what one piece of evidence says about the claim.
type EvidenceVerdict string

const (
	VerdictSupports    EvidenceVerdict = "SUPPORTS"
	VerdictContradicts EvidenceVerdict = "CONTRADICTS"
	// VerdictInconclusive is a real answer and the most common one. A cloudy
	// fortnight over a monsoon flood leaves no usable satellite image, and
	// reading that silence as "contradicts" would deny a claim because of the
	// weather rather than because of the facts.
	VerdictInconclusive EvidenceVerdict = "INCONCLUSIVE"
)

// Evidence is one item in a claim's pack.
type Evidence struct {
	ID         string          `json:"id"`
	Source     EvidenceSource  `json:"source"`
	Verdict    EvidenceVerdict `json:"verdict"`
	Summary    string          `json:"summary"`
	Observed   float64         `json:"observed"`
	Baseline   float64         `json:"baseline"`
	Unit       string          `json:"unit"`
	ObservedAt time.Time       `json:"observed_at"`
	Reference  string          `json:"reference"`
}

// Claim is a loss claim against a quote.
type Claim struct {
	ID       string `json:"id" db:"id"`
	TenantID string `json:"tenant_id" db:"tenant_id"`
	QuoteID  string `json:"quote_id" db:"quote_id"`
	FieldID  string `json:"field_id" db:"field_id"`
	FarmID   string `json:"farm_id" db:"farm_id"`
	Crop     string `json:"crop" db:"crop"`
	Season   Season `json:"season" db:"season"`
	Year     int    `json:"year" db:"year"`

	Cause         LossCause `json:"cause" db:"cause"`
	LossStartedOn time.Time `json:"loss_started_on" db:"loss_started_on"`
	LossEndedOn   time.Time `json:"loss_ended_on" db:"loss_ended_on"`
	Description   string    `json:"description" db:"description"`

	Status ClaimStatus `json:"status" db:"status"`

	ClaimedAreaHectares float64 `json:"claimed_area_hectares" db:"claimed_area_hectares"`
	ReportedYieldKgHa   float64 `json:"reported_yield_kg_ha" db:"reported_yield_kg_ha"`
	ThresholdYieldKgHa  float64 `json:"threshold_yield_kg_ha" db:"threshold_yield_kg_ha"`
	IndicatedPayout     float64 `json:"indicated_payout" db:"indicated_payout"`

	Evidence        []Evidence `json:"evidence" db:"evidence"`
	EvidenceSummary string     `json:"evidence_summary" db:"evidence_summary"`

	SubmittedBy string    `json:"submitted_by" db:"submitted_by"`
	SubmittedAt time.Time `json:"submitted_at" db:"submitted_at"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
	Version     int64     `json:"version" db:"version"`
}

// NDVIObservation is one satellite reading of the field.
type NDVIObservation struct {
	At    time.Time
	Value float64
	// CloudCover as a fraction. A reading under heavy cloud is not a reading of
	// the crop, and treating it as one is how a claim gets contradicted by a
	// cloud.
	CloudCover float64
	Reference  string
}

// WeatherWindow is what the weather did over the loss period.
type WeatherWindow struct {
	RainfallMM      float64
	MaxTemperatureC float64
	MinTemperatureC float64
	DryDays         int
	Days            int
	// Normal is the long-run rainfall for the same window, for comparison.
	NormalRainfallMM float64
	HasNormal        bool
}

// maxUsableCloudCover is how much cloud a reading can carry and still count.
//
// 0.30. Above it the sensor is mostly looking at cloud top, and the NDVI it
// returns says more about the sky than the crop.
const maxUsableCloudCover = 0.30

// ndviDropThreshold is the fall against the field's own baseline that counts
// as visible crop damage.
//
// 25%. Vegetation index varies with growth stage, so a small dip is normal
// mid-season; a quarter of the signal gone is the kind of change a person
// standing in the field would also see.
const ndviDropThreshold = 0.25

// IndicatedPayout is what the policy formula produces for a reported loss.
//
// Arithmetic, not an approval. It is the shortfall against the insured
// threshold as a share of that threshold, applied to the sum insured on the
// claimed area — which is what the insurer will compute, and therefore what
// the farmer should be able to see before they file.
func IndicatedPayout(threshold, reportedYield, sumInsuredPerHa, areaHa float64) float64 {
	if threshold <= 0 || areaHa <= 0 || sumInsuredPerHa <= 0 {
		return 0
	}
	shortfall := (threshold - reportedYield) / threshold
	if shortfall <= 0 {
		return 0
	}
	if shortfall > 1 {
		shortfall = 1
	}
	return shortfall * sumInsuredPerHa * areaHa
}

// AssessNDVI reads the satellite record over the loss window.
//
// The comparison is against the same field earlier in the same season, not
// against a regional average: a field that is always sparse would otherwise
// look damaged every year, and one on unusually good ground would look healthy
// through a total loss.
//
// Cloudy scenes are discarded before anything is compared, and a window with
// nothing left after that comes back INCONCLUSIVE. That is the important case:
// floods arrive with cloud, so the claims most likely to be genuine are
// exactly the ones the satellite cannot see.
func AssessNDVI(observations []NDVIObservation, lossStart, lossEnd time.Time) Evidence {
	evidence := Evidence{
		Source: EvidenceSatelliteNDVI,
		Unit:   "NDVI",
	}

	usable := make([]NDVIObservation, 0, len(observations))
	cloudy := 0
	for _, obs := range observations {
		if obs.CloudCover > maxUsableCloudCover {
			cloudy++
			continue
		}
		usable = append(usable, obs)
	}
	sort.Slice(usable, func(i, j int) bool { return usable[i].At.Before(usable[j].At) })

	var before, during []NDVIObservation
	for _, obs := range usable {
		switch {
		case obs.At.Before(lossStart):
			before = append(before, obs)
		case !lossEnd.IsZero() && obs.At.After(lossEnd):
			// After the window. Not used: by then the crop may have been
			// replanted or the field cleared, and either would read as a
			// recovery that never happened to the insured crop.
		default:
			during = append(during, obs)
		}
	}

	if len(before) == 0 || len(during) == 0 {
		evidence.Verdict = VerdictInconclusive
		evidence.Summary = inconclusiveNDVISummary(len(before), len(during), cloudy)
		return evidence
	}

	baseline := peakNDVI(before)
	low := minNDVI(during)
	evidence.Baseline = baseline
	evidence.Observed = low
	evidence.ObservedAt = during[len(during)-1].At
	evidence.Reference = during[len(during)-1].Reference

	if baseline <= 0 {
		evidence.Verdict = VerdictInconclusive
		evidence.Summary = "the readings before the loss are not usable as a baseline"
		return evidence
	}

	drop := (baseline - low) / baseline
	switch {
	case drop >= ndviDropThreshold:
		evidence.Verdict = VerdictSupports
		evidence.Summary = fmt.Sprintf(
			"Vegetation index fell %.0f%% during the loss window, from %.2f before it "+
				"to %.2f at the lowest usable reading. A fall of that size is visible "+
				"crop damage.", drop*100, baseline, low)
	case drop <= 0.05:
		evidence.Verdict = VerdictContradicts
		evidence.Summary = fmt.Sprintf(
			"Vegetation index held at %.2f through the loss window against a %.2f "+
				"baseline. The crop canopy does not appear to have been damaged in "+
				"this period.", low, baseline)
	default:
		evidence.Verdict = VerdictInconclusive
		evidence.Summary = fmt.Sprintf(
			"Vegetation index fell %.0f%% during the window, from %.2f to %.2f. That "+
				"is within the range of ordinary seasonal variation and neither "+
				"supports nor rules out the claim.", drop*100, baseline, low)
	}

	if cloudy > 0 {
		evidence.Summary += fmt.Sprintf(
			" %d scene%s over this field were too cloudy to read and were left out.",
			cloudy, plural(cloudy))
	}
	return evidence
}

func inconclusiveNDVISummary(before, during, cloudy int) string {
	var b strings.Builder
	b.WriteString("The satellite record cannot speak to this claim: ")
	switch {
	case before == 0 && during == 0:
		b.WriteString("there are no usable readings of this field either side of the loss")
	case before == 0:
		b.WriteString("there is no usable reading from before the loss to compare against")
	default:
		b.WriteString("there is no usable reading from inside the loss window")
	}
	if cloudy > 0 {
		fmt.Fprintf(&b, ", after %d cloudy scene%s were discarded", cloudy, plural(cloudy))
	}
	b.WriteString(". This is an absence of evidence, not evidence that the loss did not happen — " +
		"floods and cyclones arrive with cloud, so the claims most likely to be " +
		"genuine are the ones the satellite is least able to see.")
	return b.String()
}

// AssessWeather reads the weather over the loss window against the cause.
//
// Each cause has a different signature: a drought claim needs a rainfall
// deficit and a run of dry days, a flood claim needs the opposite. Running one
// test for all of them would confirm a flood claim on the strength of a dry
// spell.
func AssessWeather(cause LossCause, window WeatherWindow) Evidence {
	evidence := Evidence{
		Source:   EvidenceWeather,
		Unit:     "mm",
		Observed: window.RainfallMM,
		Baseline: window.NormalRainfallMM,
	}

	if window.Days == 0 {
		evidence.Verdict = VerdictInconclusive
		evidence.Summary = "no weather record covers the loss window for this field."
		return evidence
	}

	switch cause {
	case CauseDrought:
		if !window.HasNormal {
			evidence.Verdict = VerdictInconclusive
			evidence.Summary = fmt.Sprintf(
				"%.0f mm fell over %d days with %d dry days, but there is no long-run "+
					"normal for this location to compare it against.",
				window.RainfallMM, window.Days, window.DryDays)
			return evidence
		}
		deficit := 0.0
		if window.NormalRainfallMM > 0 {
			deficit = (window.NormalRainfallMM - window.RainfallMM) / window.NormalRainfallMM
		}
		switch {
		case deficit >= 0.40 || window.DryDays >= 21:
			evidence.Verdict = VerdictSupports
			evidence.Summary = fmt.Sprintf(
				"%.0f mm fell against a normal of %.0f mm, a %.0f%% deficit, with %d "+
					"consecutive dry days.", window.RainfallMM, window.NormalRainfallMM,
				deficit*100, window.DryDays)
		case deficit <= 0:
			evidence.Verdict = VerdictContradicts
			evidence.Summary = fmt.Sprintf(
				"%.0f mm fell over the window against a normal of %.0f mm. Rainfall was "+
					"at or above normal.", window.RainfallMM, window.NormalRainfallMM)
		default:
			evidence.Verdict = VerdictInconclusive
			evidence.Summary = fmt.Sprintf(
				"a %.0f%% rainfall deficit — below normal, but not the kind of deficit "+
					"that on its own explains a crop loss.", deficit*100)
		}

	case CauseFlood, CauseUnseasonalRain, CauseCyclone:
		excess := 0.0
		if window.HasNormal && window.NormalRainfallMM > 0 {
			excess = (window.RainfallMM - window.NormalRainfallMM) / window.NormalRainfallMM
		}
		perDay := window.RainfallMM / float64(window.Days)
		switch {
		case perDay >= 50 || excess >= 1.0:
			evidence.Verdict = VerdictSupports
			evidence.Summary = fmt.Sprintf(
				"%.0f mm fell over %d days, averaging %.0f mm a day.",
				window.RainfallMM, window.Days, perDay)
		case perDay < 5 && window.HasNormal && excess < 0:
			evidence.Verdict = VerdictContradicts
			evidence.Summary = fmt.Sprintf(
				"only %.0f mm fell over %d days, below the %.0f mm normal for the "+
					"window.", window.RainfallMM, window.Days, window.NormalRainfallMM)
		default:
			evidence.Verdict = VerdictInconclusive
			evidence.Summary = fmt.Sprintf(
				"%.0f mm over %d days. Heavier than nothing, but not on its own the "+
					"signature of the loss claimed.", window.RainfallMM, window.Days)
		}

	default:
		// Hail, pest, disease and fire leave no signature in a rainfall total.
		// Saying so is the honest answer; reading a dry spell as evidence
		// either way about a pest outbreak would be assessing the wrong thing.
		evidence.Verdict = VerdictInconclusive
		evidence.Summary = fmt.Sprintf(
			"a %s claim is not something a rainfall and temperature record can speak "+
				"to. The weather over the window is attached for context: %.0f mm over "+
				"%d days.", strings.ToLower(strings.ReplaceAll(string(cause), "_", " ")),
			window.RainfallMM, window.Days)
	}

	return evidence
}

// AssessReportedYield compares the reported yield against the field's own record.
func AssessReportedYield(reported, threshold float64, history []YieldSeason) Evidence {
	evidence := Evidence{
		Source:   EvidenceYieldRecord,
		Unit:     "kg/ha",
		Observed: reported,
		Baseline: threshold,
	}

	if threshold <= 0 {
		evidence.Verdict = VerdictInconclusive
		evidence.Summary = "no threshold yield was set on the cover, so the reported " +
			"yield cannot be read as a shortfall."
		return evidence
	}

	switch {
	case reported >= threshold:
		evidence.Verdict = VerdictContradicts
		evidence.Summary = fmt.Sprintf(
			"the reported yield of %.0f kg/ha is at or above the insured threshold of "+
				"%.0f kg/ha, so the policy formula produces no shortfall.",
			reported, threshold)
	case reported <= threshold*0.5:
		evidence.Verdict = VerdictSupports
		evidence.Summary = fmt.Sprintf(
			"the reported yield of %.0f kg/ha is less than half the insured threshold "+
				"of %.0f kg/ha.", reported, threshold)
	default:
		evidence.Verdict = VerdictSupports
		evidence.Summary = fmt.Sprintf(
			"the reported yield of %.0f kg/ha is below the insured threshold of %.0f "+
				"kg/ha.", reported, threshold)
	}

	if mean := meanYield(history); mean > 0 {
		evidence.Summary += fmt.Sprintf(
			" This field has averaged %.0f kg/ha over %d recorded season%s.",
			mean, len(history), plural(len(history)))
	}
	return evidence
}

// SummariseEvidence says what the pack as a whole shows, without deciding.
//
// The wording is deliberate throughout: this service assembles evidence and an
// insurer decides. A summary that said "approved" or "denied" would be read as
// a decision by everybody downstream, and it would be a decision made by a
// service that has never seen the policy wording.
func SummariseEvidence(evidence []Evidence) string {
	supports, contradicts, inconclusive := 0, 0, 0
	for _, item := range evidence {
		switch item.Verdict {
		case VerdictSupports:
			supports++
		case VerdictContradicts:
			contradicts++
		default:
			inconclusive++
		}
	}

	if len(evidence) == 0 {
		return "No evidence has been gathered for this claim yet."
	}

	var b strings.Builder
	fmt.Fprintf(&b, "%d of %d checks support the claim, %d contradict it and %d are "+
		"inconclusive. ", supports, len(evidence), contradicts, inconclusive)

	switch {
	case contradicts > 0 && supports == 0:
		b.WriteString("Nothing gathered supports the loss as described, and at least one " +
			"source runs against it. The insurer should look at this closely before " +
			"settling.")
	case supports > 0 && contradicts == 0:
		b.WriteString("The evidence is consistent with the loss as described.")
	case supports > 0 && contradicts > 0:
		b.WriteString("The sources disagree, which usually means the loss was partial, " +
			"confined to part of the field, or dated differently from the claim. It " +
			"needs a person to look at it.")
	default:
		b.WriteString("Nothing gathered speaks either way. That is not a reason to " +
			"refuse the claim — it is a reason to send an inspector.")
	}

	b.WriteString(" This is an evidence pack, not a decision: the insurer settles the claim.")
	return b.String()
}

func peakNDVI(observations []NDVIObservation) float64 {
	// The peak before the loss rather than the mean: NDVI climbs through the
	// season, so a mean taken over the whole run-up would sit well below the
	// canopy the crop had actually reached when the loss struck, and would
	// understate every drop.
	peak := 0.0
	for _, obs := range observations {
		if obs.Value > peak {
			peak = obs.Value
		}
	}
	return peak
}

func minNDVI(observations []NDVIObservation) float64 {
	if len(observations) == 0 {
		return 0
	}
	low := observations[0].Value
	for _, obs := range observations {
		if obs.Value < low {
			low = obs.Value
		}
	}
	return low
}

// Validate checks a claim can be filed.
func (c *Claim) Validate() error {
	if strings.TrimSpace(c.FieldID) == "" {
		return ErrMissingField
	}
	if c.Cause == "" {
		return fmt.Errorf("finance: a loss cause is required")
	}
	if c.ClaimedAreaHectares <= 0 {
		return ErrInvalidArea
	}
	if c.LossStartedOn.IsZero() {
		return fmt.Errorf("finance: the date the loss started is required")
	}
	return nil
}

// Editable reports whether a claim may still be changed.
func (c *Claim) Editable() bool {
	return c.Status == ClaimDraft || c.Status == ClaimSubmitted
}

// ListClaimsParams filters a claim query.
type ListClaimsParams struct {
	TenantID string
	FieldID  string
	FarmID   string
	Status   ClaimStatus
	Limit    int
	Offset   int
}
