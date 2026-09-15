// Package domain holds soil-lab-service's entities and the import logic.
package domain

import (
	"crypto/sha256"
	"encoding/csv"
	"encoding/hex"
	"errors"
	"fmt"
	"math"
	"strconv"
	"strings"
	"time"
)

// Errors the domain returns.
var (
	ErrEmptyFile         = errors.New("soillab: the file is empty")
	ErrNoHeader          = errors.New("soillab: the file has no header row")
	ErrNoRows            = errors.New("soillab: the file has a header and no data")
	ErrNoFieldColumn     = errors.New("soillab: no field identifier column; the results cannot be attached to anything")
	ErrUnsupportedFormat = errors.New("soillab: only CSV is parsed; a PDF is stored for a person to read")
	ErrAlreadyApplied    = errors.New("soillab: this report has already been applied")
	ErrRejected          = errors.New("soillab: this report was rejected")
	ErrNothingToApply    = errors.New("soillab: every row is blocked")
)

// ReportFormat is how a lab delivered its results.
type ReportFormat string

const (
	FormatCSV ReportFormat = "CSV"
	FormatPDF ReportFormat = "PDF"
)

// ImportStatus is where one report has got to.
type ImportStatus string

const (
	StatusReceived    ImportStatus = "RECEIVED"
	StatusParsed      ImportStatus = "PARSED"
	StatusNeedsReview ImportStatus = "NEEDS_REVIEW"
	StatusApplied     ImportStatus = "APPLIED"
	StatusRejected    ImportStatus = "REJECTED"
)

// Lab is an accredited soil testing laboratory.
type Lab struct {
	ID            string `json:"id" db:"id"`
	TenantID      string `json:"tenant_id" db:"tenant_id"`
	Name          string `json:"name" db:"name"`
	Accreditation string `json:"accreditation" db:"accreditation"`
	ContactEmail  string `json:"contact_email" db:"contact_email"`

	// ColumnAliases maps this lab's column headings onto canonical analyte
	// names. Every lab names its columns differently — "Avail. P (kg/ha)",
	// "P2O5", "Phosphorus" — and a person renaming headers before each upload
	// is a person who will eventually rename one wrongly.
	ColumnAliases map[string]string `json:"column_aliases" db:"column_aliases"`

	CreatedAt time.Time `json:"created_at" db:"created_at"`
}

// Analyte is a soil measurement this service understands.
type Analyte string

const (
	AnalytePH            Analyte = "ph"
	AnalyteOrganicMatter Analyte = "organic_matter_pct"
	AnalyteNitrogen      Analyte = "nitrogen_ppm"
	AnalytePhosphorus    Analyte = "phosphorus_ppm"
	AnalytePotassium     Analyte = "potassium_ppm"
	AnalyteCalcium       Analyte = "calcium_ppm"
	AnalyteMagnesium     Analyte = "magnesium_ppm"
	AnalyteSulfur        Analyte = "sulfur_ppm"
	AnalyteIron          Analyte = "iron_ppm"
	AnalyteManganese     Analyte = "manganese_ppm"
	AnalyteZinc          Analyte = "zinc_ppm"
	AnalyteCopper        Analyte = "copper_ppm"
	AnalyteBoron         Analyte = "boron_ppm"
	AnalyteMoisture      Analyte = "moisture_pct"
	AnalyteBulkDensity   Analyte = "bulk_density"
	AnalyteCEC           Analyte = "cation_exchange_capacity"
	AnalyteEC            Analyte = "electrical_conductivity"
)

// plausibleRange is the interval an analyte's value must fall in.
//
// These are not precision limits — soils vary enormously — but the bounds
// outside which a number is almost certainly a unit mismatch in the lab's
// export rather than a real reading. Phosphorus at 4,500 ppm is not a rich
// soil; it is kg/ha that nobody converted, and applied to a prescription it
// would tell a farmer to add nothing to a field that needs feeding.
var plausibleRange = map[Analyte][2]float64{
	AnalytePH:            {0, 14},
	AnalyteOrganicMatter: {0, 30},
	AnalyteNitrogen:      {0, 2000},
	AnalytePhosphorus:    {0, 1000},
	AnalytePotassium:     {0, 3000},
	AnalyteCalcium:       {0, 20000},
	AnalyteMagnesium:     {0, 5000},
	AnalyteSulfur:        {0, 2000},
	AnalyteIron:          {0, 1000},
	AnalyteManganese:     {0, 500},
	AnalyteZinc:          {0, 200},
	AnalyteCopper:        {0, 200},
	AnalyteBoron:         {0, 50},
	AnalyteMoisture:      {0, 100},
	AnalyteBulkDensity:   {0.5, 2.5},
	AnalyteCEC:           {0, 100},
	AnalyteEC:            {0, 20},
}

// canonicalHeaders maps the column names labs commonly use onto analytes.
//
// Matched case-insensitively with punctuation and units stripped, so
// "Avail. P (ppm)" and "avail p" are the same column. A lab whose headers are
// not here registers its own aliases rather than having somebody edit the
// file before each upload.
var canonicalHeaders = map[string]Analyte{
	"ph":                     AnalytePH,
	"phlevel":                AnalytePH,
	"soilph":                 AnalytePH,
	"organicmatter":          AnalyteOrganicMatter,
	"om":                     AnalyteOrganicMatter,
	"oc":                     AnalyteOrganicMatter,
	"organiccarbon":          AnalyteOrganicMatter,
	"nitrogen":               AnalyteNitrogen,
	"n":                      AnalyteNitrogen,
	"availn":                 AnalyteNitrogen,
	"availablenitrogen":      AnalyteNitrogen,
	"phosphorus":             AnalytePhosphorus,
	"p":                      AnalytePhosphorus,
	"availp":                 AnalytePhosphorus,
	"availablephosphorus":    AnalytePhosphorus,
	"potassium":              AnalytePotassium,
	"k":                      AnalytePotassium,
	"availk":                 AnalytePotassium,
	"availablepotassium":     AnalytePotassium,
	"calcium":                AnalyteCalcium,
	"ca":                     AnalyteCalcium,
	"magnesium":              AnalyteMagnesium,
	"mg":                     AnalyteMagnesium,
	"sulfur":                 AnalyteSulfur,
	"sulphur":                AnalyteSulfur,
	"s":                      AnalyteSulfur,
	"iron":                   AnalyteIron,
	"fe":                     AnalyteIron,
	"manganese":              AnalyteManganese,
	"mn":                     AnalyteManganese,
	"zinc":                   AnalyteZinc,
	"zn":                     AnalyteZinc,
	"copper":                 AnalyteCopper,
	"cu":                     AnalyteCopper,
	"boron":                  AnalyteBoron,
	"b":                      AnalyteBoron,
	"moisture":               AnalyteMoisture,
	"bulkdensity":            AnalyteBulkDensity,
	"bd":                     AnalyteBulkDensity,
	"cec":                    AnalyteCEC,
	"cationexchangecapacity": AnalyteCEC,
	"ec":                     AnalyteEC,
	"electricalconductivity": AnalyteEC,
}

// Columns that identify the sample rather than measure it.
var (
	fieldHeaders     = map[string]bool{"fieldid": true, "field": true, "fieldcode": true, "plot": true, "plotid": true}
	sampleRefHeaders = map[string]bool{"sampleid": true, "sampleref": true, "labref": true, "reference": true, "sample": true}
	depthHeaders     = map[string]bool{"depth": true, "depthcm": true, "samplingdepth": true, "samplingdepthcm": true}
	dateHeaders      = map[string]bool{"date": true, "collectedon": true, "collectiondate": true, "sampledon": true, "samplingdate": true}
)

// normaliseHeader strips case, spaces, punctuation and a trailing unit.
//
// "Avail. P (kg/ha)" becomes "availp". The unit is dropped deliberately: it is
// not what identifies the column, and a lab that changes "(ppm)" to "(mg/kg)"
// in a new export format should not break the import.
func normaliseHeader(h string) string {
	h = strings.ToLower(strings.TrimSpace(h))
	if idx := strings.IndexAny(h, "(["); idx > 0 {
		h = h[:idx]
	}
	var b strings.Builder
	for _, r := range h {
		if (r >= 'a' && r <= 'z') || (r >= '0' && r <= '9') {
			b.WriteRune(r)
		}
	}
	return b.String()
}

// LabResult is one analyte reading from a report row.
type LabResult struct {
	Analyte Analyte `json:"analyte"`
	Value   float64 `json:"value"`
	Unit    string  `json:"unit"`

	// Suspect marks a value outside its plausible range — almost always a unit
	// mismatch in the lab's export. Flagged rather than dropped, so a person
	// can see what the lab actually sent and decide.
	Suspect bool   `json:"suspect"`
	Note    string `json:"note"`
}

// ReportRow is one sample's worth of results.
type ReportRow struct {
	LineNumber  int         `json:"line_number"`
	SampleRef   string      `json:"sample_ref"`
	FieldID     string      `json:"field_id"`
	DepthCM     float64     `json:"depth_cm"`
	CollectedOn time.Time   `json:"collected_on"`
	Results     []LabResult `json:"results"`

	// Blocker says why this row cannot become a soil sample.
	Blocker string `json:"blocker"`
}

// Usable reports whether the row can be applied.
func (r ReportRow) Usable() bool { return r.Blocker == "" }

// LabReport is one uploaded file and what came of it.
type LabReport struct {
	ID       string `json:"id" db:"id"`
	TenantID string `json:"tenant_id" db:"tenant_id"`
	LabID    string `json:"lab_id" db:"lab_id"`
	LabName  string `json:"lab_name" db:"lab_name"`

	Format        ReportFormat `json:"format" db:"format"`
	Filename      string       `json:"filename" db:"filename"`
	StorageURL    string       `json:"storage_url" db:"storage_url"`
	ContentSHA256 string       `json:"content_sha256" db:"content_sha256"`

	Status ImportStatus `json:"status" db:"status"`

	RowCount     int `json:"row_count" db:"row_count"`
	AppliedCount int `json:"applied_count" db:"applied_count"`
	BlockedCount int `json:"blocked_count" db:"blocked_count"`

	Rows []ReportRow `json:"rows" db:"rows"`

	UploadedAt      time.Time  `json:"uploaded_at" db:"uploaded_at"`
	AppliedAt       *time.Time `json:"applied_at" db:"applied_at"`
	UploadedBy      string     `json:"uploaded_by" db:"uploaded_by"`
	RejectionReason string     `json:"rejection_reason" db:"rejection_reason"`
}

// HashContent is the content hash used to recognise a re-upload.
//
// Keyed on the bytes rather than the filename, because the same results get
// re-sent as "results.csv", "results (1).csv" and "results-final.csv", and
// creating three sets of soil samples from one set of readings would triple
// every field's history.
func HashContent(content []byte) string {
	sum := sha256.Sum256(content)
	return hex.EncodeToString(sum[:])
}

// ParseCSV turns a lab's CSV into rows, using the lab's column aliases.
//
// Nothing is silently dropped. A row that cannot be attached to a field, or
// whose date will not parse, comes back with a blocker saying so — because a
// soil report is the input to a fertiliser prescription, and an import that
// quietly loses half its rows produces a prescription for half a field.
func ParseCSV(content []byte, aliases map[string]string, now time.Time) ([]ReportRow, error) {
	if len(content) == 0 {
		return nil, ErrEmptyFile
	}

	reader := csv.NewReader(strings.NewReader(string(content)))
	// Labs pad rows unevenly; a short row is a missing measurement, not a
	// malformed file.
	reader.FieldsPerRecord = -1
	reader.TrimLeadingSpace = true

	records, err := reader.ReadAll()
	if err != nil {
		return nil, fmt.Errorf("soillab: could not read the CSV: %w", err)
	}
	if len(records) == 0 {
		return nil, ErrNoHeader
	}
	if len(records) == 1 {
		return nil, ErrNoRows
	}

	header := records[0]
	mapping, hasField := mapColumns(header, aliases)
	if !hasField {
		return nil, ErrNoFieldColumn
	}

	rows := make([]ReportRow, 0, len(records)-1)
	for i, record := range records[1:] {
		rows = append(rows, parseRow(i+2, record, mapping, now))
	}
	return rows, nil
}

// columnRole is what one CSV column carries.
type columnRole struct {
	analyte   Analyte
	isField   bool
	isSample  bool
	isDepth   bool
	isDate    bool
	unit      string
	rawHeader string
}

// mapColumns works out what each column is.
func mapColumns(header []string, aliases map[string]string) (map[int]columnRole, bool) {
	mapping := make(map[int]columnRole, len(header))
	hasField := false

	for i, raw := range header {
		norm := normaliseHeader(raw)
		role := columnRole{rawHeader: raw, unit: extractUnit(raw)}

		// The lab's own alias wins. It was configured by somebody who has seen
		// this lab's export; the built-in table is a guess that works for most.
		if canonical, ok := aliases[strings.ToLower(strings.TrimSpace(raw))]; ok {
			role.analyte = Analyte(canonical)
			mapping[i] = role
			continue
		}

		switch {
		case fieldHeaders[norm]:
			role.isField = true
			hasField = true
		case sampleRefHeaders[norm]:
			role.isSample = true
		case depthHeaders[norm]:
			role.isDepth = true
		case dateHeaders[norm]:
			role.isDate = true
		default:
			if analyte, ok := canonicalHeaders[norm]; ok {
				role.analyte = analyte
			} else {
				// Unrecognised columns are ignored rather than guessed at. A
				// lab CSV carries plenty that is not a measurement — technician
				// initials, batch numbers — and inventing an analyte for them
				// would put noise into a prescription.
				continue
			}
		}
		mapping[i] = role
	}
	return mapping, hasField
}

// extractUnit pulls "(ppm)" out of a header, for reporting alongside a value.
func extractUnit(header string) string {
	open := strings.IndexAny(header, "([")
	if open < 0 {
		return ""
	}
	closing := strings.IndexAny(header[open:], ")]")
	if closing < 0 {
		return ""
	}
	return strings.TrimSpace(header[open+1 : open+closing])
}

// dateLayouts are the formats labs date their reports in.
//
// Day-first before month-first: Indian labs write 03/04/2026 meaning 3 April,
// and reading it as 4 March puts a sample in the wrong season, which changes
// what a prescription recommends.
var dateLayouts = []string{
	"2006-01-02",
	"02/01/2006",
	"02-01-2006",
	"2006/01/02",
	time.RFC3339,
}

func parseRow(lineNumber int, record []string, mapping map[int]columnRole, now time.Time) ReportRow {
	row := ReportRow{LineNumber: lineNumber}
	var blockers []string

	for i, raw := range record {
		role, ok := mapping[i]
		if !ok {
			continue
		}
		value := strings.TrimSpace(raw)

		switch {
		case role.isField:
			row.FieldID = value
		case role.isSample:
			row.SampleRef = value
		case role.isDepth:
			if value != "" {
				if depth, err := strconv.ParseFloat(value, 64); err == nil {
					row.DepthCM = depth
				}
			}
		case role.isDate:
			if value == "" {
				continue
			}
			parsed, err := parseDate(value)
			if err != nil {
				blockers = append(blockers, fmt.Sprintf("collection date %q is not a date this service reads", value))
				continue
			}
			if parsed.After(now.Add(24 * time.Hour)) {
				blockers = append(blockers, fmt.Sprintf("collection date %s is in the future", parsed.Format("2006-01-02")))
				continue
			}
			row.CollectedOn = parsed
		case role.analyte != "":
			if value == "" {
				// A blank cell is a measurement the lab did not run, which is
				// normal. Storing it as zero would say the soil contains none
				// of that nutrient.
				continue
			}
			number, err := strconv.ParseFloat(strings.ReplaceAll(value, ",", ""), 64)
			if err != nil {
				// Labs write "<0.5" and "ND" for below-detection results.
				// Recorded with a note rather than dropped or guessed at.
				row.Results = append(row.Results, LabResult{
					Analyte: role.analyte,
					Unit:    role.unit,
					Suspect: true,
					Note:    fmt.Sprintf("the lab reported %q, which is not a number", value),
				})
				continue
			}
			row.Results = append(row.Results, checkPlausible(role.analyte, number, role.unit))
		}
	}

	if row.FieldID == "" {
		blockers = append(blockers, "no field identifier; these results cannot be attached to anything")
	}
	if len(row.Results) == 0 {
		blockers = append(blockers, "no readings in this row")
	}

	row.Blocker = strings.Join(blockers, "; ")
	return row
}

func parseDate(value string) (time.Time, error) {
	for _, layout := range dateLayouts {
		if parsed, err := time.Parse(layout, value); err == nil {
			return parsed, nil
		}
	}
	return time.Time{}, fmt.Errorf("unrecognised date %q", value)
}

// checkPlausible flags a value outside the range its analyte can take.
func checkPlausible(analyte Analyte, value float64, unit string) LabResult {
	result := LabResult{Analyte: analyte, Value: value, Unit: unit}

	if math.IsNaN(value) || math.IsInf(value, 0) {
		result.Suspect = true
		result.Note = "the lab reported a value that is not a number"
		return result
	}

	bounds, known := plausibleRange[analyte]
	if !known {
		return result
	}
	if value < bounds[0] || value > bounds[1] {
		result.Suspect = true
		result.Note = fmt.Sprintf(
			"%.2f is outside the %.1f–%.1f range this analyte takes; "+
				"this is usually a unit mismatch in the lab's export",
			value, bounds[0], bounds[1],
		)
	}
	return result
}

// Summarise counts a report's rows and sets the status the file has reached.
//
// NEEDS_REVIEW rather than PARSED when anything is blocked or suspect, because
// these numbers become a fertiliser prescription: a silently partial import
// produces a prescription for part of a field, and a suspect potassium reading
// produces one for the wrong soil.
func (r *LabReport) Summarise() {
	r.RowCount = len(r.Rows)
	r.BlockedCount = 0

	needsReview := false
	for _, row := range r.Rows {
		if !row.Usable() {
			r.BlockedCount++
			needsReview = true
			continue
		}
		for _, result := range row.Results {
			if result.Suspect {
				needsReview = true
				break
			}
		}
	}

	if needsReview {
		r.Status = StatusNeedsReview
		return
	}
	r.Status = StatusParsed
}

// UsableRows returns the rows that can become soil samples.
func (r *LabReport) UsableRows() []ReportRow {
	out := make([]ReportRow, 0, len(r.Rows))
	for _, row := range r.Rows {
		if row.Usable() {
			out = append(out, row)
		}
	}
	return out
}

// CanApply reports whether a report may be pushed into soil-service.
//
// skipBlocked has to be asked for. A partial import that nobody chose leaves a
// field with results from half its samples and no sign that the rest are
// missing.
func (r *LabReport) CanApply(skipBlocked bool) error {
	switch r.Status {
	case StatusApplied:
		return ErrAlreadyApplied
	case StatusRejected:
		return ErrRejected
	}

	usable := len(r.UsableRows())
	if usable == 0 {
		return ErrNothingToApply
	}
	if r.BlockedCount > 0 && !skipBlocked {
		return fmt.Errorf(
			"soillab: %d of %d rows are blocked; fix them or apply with skip_blocked to import the other %d",
			r.BlockedCount, r.RowCount, usable,
		)
	}
	return nil
}

// SoilSample is what one usable row becomes in soil-service.
//
// A flat struct rather than the soil-service proto, so this package does not
// depend on another service's generated code.
type SoilSample struct {
	FieldID     string              `json:"field_id"`
	DepthCM     float64             `json:"sample_depth_cm"`
	CollectedOn time.Time           `json:"collection_date"`
	CollectedBy string              `json:"collected_by"`
	Notes       string              `json:"notes"`
	Values      map[Analyte]float64 `json:"values"`
}

// ToSoilSample turns a usable row into the sample soil-service stores.
//
// Suspect readings are left out rather than carried through. The report keeps
// them so a person can see what the lab sent, but a value flagged as a
// probable unit mismatch must not reach a prescription — and a prescription
// cannot tell a suspect number from a good one.
func (r ReportRow) ToSoilSample(labName string) SoilSample {
	sample := SoilSample{
		FieldID:     r.FieldID,
		DepthCM:     r.DepthCM,
		CollectedOn: r.CollectedOn,
		CollectedBy: labName,
		Values:      make(map[Analyte]float64, len(r.Results)),
	}
	if r.SampleRef != "" {
		sample.Notes = fmt.Sprintf("Lab reference %s", r.SampleRef)
	}

	var omitted []string
	for _, result := range r.Results {
		if result.Suspect {
			omitted = append(omitted, string(result.Analyte))
			continue
		}
		sample.Values[result.Analyte] = result.Value
	}

	if len(omitted) > 0 {
		// Said on the sample itself, so somebody reading the soil record later
		// knows the lab reported these and why they are not here.
		sample.Notes = strings.TrimSpace(sample.Notes + fmt.Sprintf(
			" — %s omitted as implausible; see the lab report", strings.Join(omitted, ", "),
		))
	}
	return sample
}

// ListReportsParams filters a report query.
type ListReportsParams struct {
	TenantID string
	LabID    string
	Status   ImportStatus
	Limit    int
	Offset   int
}

// ListLabsParams filters a lab query.
type ListLabsParams struct {
	TenantID string
	Limit    int
	Offset   int
}
