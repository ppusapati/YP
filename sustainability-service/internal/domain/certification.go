package domain

import (
	"encoding/csv"
	"fmt"
	"sort"
	"strconv"
	"strings"
	"time"
)

// CertificationStandard is the scheme a claim is made against.
type CertificationStandard string

const (
	// StandardNPOP is India's National Programme for Organic Production.
	StandardNPOP       CertificationStandard = "NPOP"
	StandardGlobalGAP  CertificationStandard = "GLOBALGAP"
	StandardFairtrade  CertificationStandard = "FAIRTRADE"
	StandardRainforest CertificationStandard = "RAINFOREST"
)

// FindingSeverity is how much a certification finding matters.
type FindingSeverity string

const (
	SeverityBlocker FindingSeverity = "BLOCKER"
	SeverityMajor   FindingSeverity = "MAJOR"
	SeverityMinor   FindingSeverity = "MINOR"
)

// CertificationStatus is where a claim has got to.
type CertificationStatus string

const (
	StatusInConversion       CertificationStatus = "IN_CONVERSION"
	StatusEligible           CertificationStatus = "ELIGIBLE"
	StatusBlocked            CertificationStatus = "BLOCKED"
	StatusInsufficientRecord CertificationStatus = "INSUFFICIENT_RECORDS"
)

// Finding is one thing standing between a field and a certificate.
type Finding struct {
	Severity   FindingSeverity `json:"severity"`
	Code       string          `json:"code"`
	Message    string          `json:"message"`
	EvidenceID string          `json:"evidence_id"`
	OccurredOn time.Time       `json:"occurred_on"`
}

// CertificationCheck is an assessment against one standard.
type CertificationCheck struct {
	FieldID  string                `json:"field_id"`
	Standard CertificationStandard `json:"standard"`
	Status   CertificationStatus   `json:"status"`

	ConversionStartedOn time.Time `json:"conversion_started_on"`
	EligibleFrom        time.Time `json:"eligible_from"`

	Findings    []Finding `json:"findings"`
	RecordYears int       `json:"record_years"`
	Summary     string    `json:"summary"`
}

// conversionYears is how long a field must be managed to the standard before
// its produce can be sold as certified.
//
// NPOP is three years for an annual crop's land — two if the land was fallow
// or already under documented organic management, which this service cannot
// establish from input records alone, so it uses the longer period and says
// so. Understating it would have a farmer sell as organic a year early, which
// is the kind of error that ends a certification rather than delays it.
var conversionYears = map[CertificationStandard]int{
	StandardNPOP:       3,
	StandardGlobalGAP:  0, // not a conversion scheme; it audits current practice
	StandardFairtrade:  0,
	StandardRainforest: 0,
}

// requiredRecordYears is how much input history a standard needs to see.
var requiredRecordYears = map[CertificationStandard]int{
	StandardNPOP:       3,
	StandardGlobalGAP:  2,
	StandardFairtrade:  1,
	StandardRainforest: 1,
}

// CheckCertification assesses a field's records against a standard.
//
// Two rules do most of the work here.
//
// First: a prohibited input anywhere inside the conversion window is a blocker,
// not a warning. The point of a conversion period is that the land has been
// clean throughout it, and a single urea application in year two restarts the
// clock — reporting that as a minor finding would be telling a farmer they can
// sell produce they cannot.
//
// Second: too little history is its own status, not a pass. A standard that
// needs three years of records and finds one has not been satisfied; saying
// "eligible, no issues found" because there was nothing to find is how a
// service produces a document that fails at the first audit.
func CheckCertification(
	standard CertificationStandard,
	fieldID string,
	conversionStartedOn time.Time,
	inputs []InputUse,
	now time.Time,
) CertificationCheck {
	check := CertificationCheck{
		FieldID:             fieldID,
		Standard:            standard,
		ConversionStartedOn: conversionStartedOn,
	}

	years := conversionYears[standard]
	if !conversionStartedOn.IsZero() && years > 0 {
		check.EligibleFrom = conversionStartedOn.AddDate(years, 0, 0)
	}

	// The window the check looks at: from conversion start where there is one,
	// otherwise the standard's required history.
	windowStart := conversionStartedOn
	if windowStart.IsZero() {
		windowStart = now.AddDate(-requiredRecordYears[standard], 0, 0)
	}

	inWindow := make([]InputUse, 0, len(inputs))
	yearsSeen := map[int]bool{}
	for _, in := range inputs {
		when := in.AppliedOn
		if when.IsZero() {
			when = in.CreatedAt
		}
		if when.Before(windowStart) {
			continue
		}
		inWindow = append(inWindow, in)
		yearsSeen[in.Year] = true
	}
	check.RecordYears = len(yearsSeen)

	switch standard {
	case StandardNPOP:
		check.Findings = append(check.Findings, organicFindings(inWindow)...)
	case StandardGlobalGAP:
		check.Findings = append(check.Findings, globalGAPFindings(inWindow)...)
	default:
		// Fairtrade and Rainforest turn mostly on labour, price and habitat
		// records this service does not hold. Saying so is the honest answer;
		// running the organic rules against them and reporting a verdict would
		// be assessing the wrong thing and calling it a result.
		check.Status = StatusInsufficientRecord
		check.Summary = fmt.Sprintf(
			"%s is assessed on labour, pricing and habitat records, which this "+
				"service does not hold. The input record below is evidence towards "+
				"an audit, not an assessment against the standard.", standard)
		return check
	}

	sortFindings(check.Findings)

	required := requiredRecordYears[standard]
	switch {
	case hasBlocker(check.Findings):
		check.Status = StatusBlocked
		check.Summary = fmt.Sprintf(
			"%d prohibited input%s recorded in the window. Under %s the conversion "+
				"period restarts from the last one.",
			countBlockers(check.Findings), plural(countBlockers(check.Findings)), standard)

	case check.RecordYears < required:
		check.Status = StatusInsufficientRecord
		check.Summary = fmt.Sprintf(
			"%s needs %d year%s of input records and this field has %d. "+
				"No prohibited input was found, but there is not enough record to "+
				"say the field is clean.",
			standard, required, plural(required), check.RecordYears)

	case !check.EligibleFrom.IsZero() && now.Before(check.EligibleFrom):
		check.Status = StatusInConversion
		check.Summary = fmt.Sprintf(
			"The records are clean. The field is in conversion until %s, %d year%s "+
				"after conversion began.",
			check.EligibleFrom.Format("2 January 2006"), years, plural(years))

	default:
		check.Status = StatusEligible
		check.Summary = fmt.Sprintf(
			"No prohibited input in %d year%s of records. This is what the platform "+
				"holds; the certifier's own inspection decides.",
			check.RecordYears, plural(check.RecordYears))
	}

	return check
}

// organicFindings are the NPOP rules this service can actually check.
func organicFindings(inputs []InputUse) []Finding {
	var findings []Finding

	for _, in := range inputs {
		permitted, reason := IsOrganicPermitted(in.Category, in.Product)
		if permitted {
			continue
		}
		when := in.AppliedOn
		if when.IsZero() {
			when = in.CreatedAt
		}
		findings = append(findings, Finding{
			Severity:   SeverityBlocker,
			Code:       "PROHIBITED_INPUT",
			EvidenceID: in.ID,
			OccurredOn: when,
			Message: fmt.Sprintf(
				"%s applied on %s: %s. The conversion period restarts from this date.",
				displayProduct(in), when.Format("2 January 2006"), reason),
		})
	}

	// A record with no nitrogen figure is a major finding rather than a
	// blocker: the input itself may be perfectly permitted, but an auditor
	// cannot reconcile a nutrient budget without it.
	for _, in := range inputs {
		if in.NitrogenKg == 0 && isNitrogenBearing(in.Category) {
			findings = append(findings, Finding{
				Severity:   SeverityMajor,
				Code:       "UNQUANTIFIED_NITROGEN",
				EvidenceID: in.ID,
				OccurredOn: in.AppliedOn,
				Message: fmt.Sprintf(
					"%q is recorded without a nitrogen content, so the nutrient budget "+
						"cannot be reconciled. Add the analysis or the product's declared N.",
					in.Product),
			})
		}
	}

	return findings
}

// globalGAPFindings checks what GlobalGAP asks of an input record.
//
// GlobalGAP does not prohibit synthetic inputs — it asks that every
// application is recorded with what, how much, when and by whom. So the
// findings here are about the record, not about the chemistry.
func globalGAPFindings(inputs []InputUse) []Finding {
	var findings []Finding

	for _, in := range inputs {
		when := in.AppliedOn
		if when.IsZero() {
			findings = append(findings, Finding{
				Severity:   SeverityMajor,
				Code:       "NO_APPLICATION_DATE",
				EvidenceID: in.ID,
				Message: fmt.Sprintf(
					"%q has no application date. GlobalGAP requires the date of every "+
						"application so a pre-harvest interval can be verified.", in.Product),
			})
		}
		if strings.TrimSpace(in.AppliedBy) == "" {
			findings = append(findings, Finding{
				Severity:   SeverityMinor,
				Code:       "NO_OPERATOR",
				EvidenceID: in.ID,
				OccurredOn: when,
				Message: fmt.Sprintf(
					"%q does not record who applied it.", in.Product),
			})
		}
		if in.Category == CategoryPesticide && strings.TrimSpace(in.Product) == "" {
			findings = append(findings, Finding{
				Severity:   SeverityBlocker,
				Code:       "UNIDENTIFIED_PESTICIDE",
				EvidenceID: in.ID,
				OccurredOn: when,
				Message: "a crop protection application is recorded with no product name. " +
					"Without it neither the active substance nor the pre-harvest interval " +
					"can be checked.",
			})
		}
	}

	return findings
}

func isNitrogenBearing(c InputCategory) bool {
	return c == CategorySyntheticN || c == CategoryUrea || c == CategoryOrganicN
}

func displayProduct(in InputUse) string {
	if strings.TrimSpace(in.Product) != "" {
		return in.Product
	}
	return strings.ToLower(strings.ReplaceAll(string(in.Category), "_", " "))
}

func hasBlocker(findings []Finding) bool {
	for _, f := range findings {
		if f.Severity == SeverityBlocker {
			return true
		}
	}
	return false
}

func countBlockers(findings []Finding) int {
	n := 0
	for _, f := range findings {
		if f.Severity == SeverityBlocker {
			n++
		}
	}
	return n
}

// sortFindings puts blockers first and orders each severity by date.
//
// The order a person reads them in is the order they have to act on them, and
// a blocker buried under twenty minor record-keeping notes gets missed.
func sortFindings(findings []Finding) {
	rank := map[FindingSeverity]int{SeverityBlocker: 0, SeverityMajor: 1, SeverityMinor: 2}
	sort.SliceStable(findings, func(i, j int) bool {
		if rank[findings[i].Severity] != rank[findings[j].Severity] {
			return rank[findings[i].Severity] < rank[findings[j].Severity]
		}
		return findings[i].OccurredOn.Before(findings[j].OccurredOn)
	})
}

func plural(n int) string {
	if n == 1 {
		return ""
	}
	return "s"
}

// ─────────────────────────────────────────────────────────────────────────────
// Export
// ─────────────────────────────────────────────────────────────────────────────

// ExportPack renders the input record and the check as a CSV an auditor reads.
//
// The check's verdict and every finding go into the file above the records.
// An export that contained only the clean rows would be a document that says
// what its author wanted it to say, and the whole value of this pack is that
// it is the same evidence whether or not the answer is convenient.
func ExportPack(check CertificationCheck, inputs []InputUse) ([]byte, error) {
	var buf strings.Builder
	w := csv.NewWriter(&buf)

	write := func(row ...string) error { return w.Write(row) }

	if err := write("YieldPoint certification evidence pack"); err != nil {
		return nil, err
	}
	rows := [][]string{
		{"Field", check.FieldID},
		{"Standard", string(check.Standard)},
		{"Status", string(check.Status)},
		{"Summary", check.Summary},
		{"Years of records", strconv.Itoa(check.RecordYears)},
	}
	if !check.ConversionStartedOn.IsZero() {
		rows = append(rows, []string{"Conversion started", check.ConversionStartedOn.Format("2006-01-02")})
	}
	if !check.EligibleFrom.IsZero() {
		rows = append(rows, []string{"Eligible from", check.EligibleFrom.Format("2006-01-02")})
	}
	for _, row := range rows {
		if err := write(row...); err != nil {
			return nil, err
		}
	}

	if err := write(""); err != nil {
		return nil, err
	}
	if err := write("Findings"); err != nil {
		return nil, err
	}
	if err := write("severity", "code", "date", "evidence_id", "message"); err != nil {
		return nil, err
	}
	if len(check.Findings) == 0 {
		if err := write("", "", "", "", "no findings"); err != nil {
			return nil, err
		}
	}
	for _, f := range check.Findings {
		date := ""
		if !f.OccurredOn.IsZero() {
			date = f.OccurredOn.Format("2006-01-02")
		}
		if err := write(string(f.Severity), f.Code, date, f.EvidenceID, f.Message); err != nil {
			return nil, err
		}
	}

	if err := write(""); err != nil {
		return nil, err
	}
	if err := write("Input applications"); err != nil {
		return nil, err
	}
	if err := write("date", "year", "crop", "category", "product", "quantity",
		"unit", "nitrogen_kg", "applied_by", "organic_permitted", "record_id"); err != nil {
		return nil, err
	}

	ordered := make([]InputUse, len(inputs))
	copy(ordered, inputs)
	sort.SliceStable(ordered, func(i, j int) bool {
		return ordered[i].AppliedOn.Before(ordered[j].AppliedOn)
	})

	for _, in := range ordered {
		date := ""
		if !in.AppliedOn.IsZero() {
			date = in.AppliedOn.Format("2006-01-02")
		}
		nitrogen := ""
		if in.NitrogenKg > 0 {
			nitrogen = strconv.FormatFloat(in.NitrogenKg, 'f', 2, 64)
		}
		if err := write(
			date,
			strconv.Itoa(in.Year),
			in.Crop,
			string(in.Category),
			in.Product,
			strconv.FormatFloat(in.Quantity, 'f', 2, 64),
			in.Unit,
			nitrogen,
			in.AppliedBy,
			strconv.FormatBool(in.OrganicPermitted),
			in.ID,
		); err != nil {
			return nil, err
		}
	}

	w.Flush()
	if err := w.Error(); err != nil {
		return nil, err
	}
	return []byte(buf.String()), nil
}

// ExportFilename names the pack.
func ExportFilename(check CertificationCheck, now time.Time) string {
	return fmt.Sprintf("%s-%s-%s.csv",
		strings.ToLower(string(check.Standard)),
		check.FieldID,
		now.Format("2006-01-02"))
}
