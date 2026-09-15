package domain

import (
	"fmt"
	"strings"
	"time"
)

// InputUse is one recorded application to a field.
type InputUse struct {
	ID       string `json:"id" db:"id"`
	TenantID string `json:"tenant_id" db:"tenant_id"`
	FieldID  string `json:"field_id" db:"field_id"`
	Crop     string `json:"crop" db:"crop"`
	Year     int    `json:"year" db:"year"`

	Category InputCategory `json:"category" db:"category"`
	Product  string        `json:"product" db:"product"`
	Quantity float64       `json:"quantity" db:"quantity"`
	Unit     string        `json:"unit" db:"unit"`

	// NitrogenKg is the nitrogen actually delivered by this application.
	NitrogenKg float64 `json:"nitrogen_kg" db:"nitrogen_kg"`

	AppliedOn time.Time `json:"applied_on" db:"applied_on"`
	AppliedBy string    `json:"applied_by" db:"applied_by"`
	Notes     string    `json:"notes" db:"notes"`

	// OrganicPermitted is whether this input is allowed under organic
	// certification, recorded at the time of use. The standards change, and a
	// certificate has to be defensible against the rules that applied on the
	// day — not against today's list.
	OrganicPermitted bool `json:"organic_permitted" db:"organic_permitted"`

	CreatedAt time.Time `json:"created_at" db:"created_at"`
}

// nitrogenFractions is the nitrogen content of the common Indian fertilisers.
//
// Matched on the product name because that is what a farmer writes down. The
// map is deliberately short: a fertiliser that is not in it gets no derived
// nitrogen and the record says so, rather than being assigned a plausible
// fraction that then drives an N2O figure nobody can trace.
var nitrogenFractions = map[string]float64{
	"urea":                0.46,
	"dap":                 0.18, // di-ammonium phosphate, 18-46-0
	"map":                 0.11,
	"can":                 0.25, // calcium ammonium nitrate
	"ammonium sulphate":   0.21,
	"ammonium sulfate":    0.21,
	"ammonium nitrate":    0.34,
	"ammonium chloride":   0.25,
	"npk 10-26-26":        0.10,
	"npk 12-32-16":        0.12,
	"npk 20-20-0":         0.20,
	"npk 19-19-19":        0.19,
	"npk 15-15-15":        0.15,
	"sulphate of ammonia": 0.21,
	// Organic sources, on a fresh-weight basis.
	"fym":             0.005, // farmyard manure
	"farmyard manure": 0.005,
	"compost":         0.010,
	"vermicompost":    0.015,
	"poultry manure":  0.030,
	"neem cake":       0.050,
	"castor cake":     0.045,
	"green manure":    0.004,
}

// prohibitedUnderOrganic are the categories organic standards do not allow.
//
// Synthetic nitrogen, phosphate and potash are the substantive ones; residue
// burning is here because NPOP treats it as a soil-management violation rather
// than as an input. Diesel and electricity are not prohibited — an organic
// farm still runs a tractor.
var prohibitedUnderOrganic = map[InputCategory]string{
	CategorySyntheticN:  "synthetic nitrogen fertiliser",
	CategoryUrea:        "urea",
	CategoryPhosphate:   "mineral phosphate fertiliser",
	CategoryPotash:      "muriate of potash",
	CategoryResidueBurn: "in-field crop residue burning",
}

// permittedPesticides are the crop-protection products organic standards allow.
//
// A whitelist, not a blacklist. There are thousands of formulations and a
// blacklist would pass every one it had not heard of — which is exactly the
// direction a certification check must not fail in.
var permittedPesticides = []string{
	"neem", "azadirachtin", "bacillus thuringiensis", "bt ",
	"trichoderma", "beauveria", "metarhizium", "pseudomonas",
	"bordeaux", "copper sulphate", "copper sulfate", "lime sulphur",
	"pheromone", "sticky trap", "diatomaceous", "kaolin",
	"panchagavya", "jeevamrut", "beejamrut", "dashaparni",
}

// DeriveNitrogen works out the nitrogen an application delivered.
//
// Returns ok=false when the product is not one it recognises. The caller keeps
// the record and marks the nitrogen unknown rather than assuming a fraction:
// an invented nitrogen figure propagates into the N2O line, which is usually
// the largest number on a non-rice footprint.
func DeriveNitrogen(category InputCategory, product string, quantityKg float64) (float64, bool) {
	switch category {
	case CategorySyntheticN, CategoryUrea, CategoryOrganicN, CategoryPhosphate:
	default:
		// Diesel, lime, seed and the rest deliver no nitrogen worth counting.
		return 0, true
	}

	key := strings.ToLower(strings.TrimSpace(product))
	if fraction, ok := nitrogenFractions[key]; ok {
		return quantityKg * fraction, true
	}

	// A partial match, so "Urea 46% (IFFCO)" and "Neem Cake 50kg bag" both
	// land. Longest key first, so "ammonium nitrate" is not matched by
	// "ammonium sulphate"'s prefix or vice versa.
	best, bestLen := 0.0, 0
	for name, fraction := range nitrogenFractions {
		if strings.Contains(key, name) && len(name) > bestLen {
			best, bestLen = fraction, len(name)
		}
	}
	if bestLen > 0 {
		return quantityKg * best, true
	}

	// Urea is unambiguous even when the product name is not: the category is
	// the declaration.
	if category == CategoryUrea {
		return quantityKg * ureaNFraction, true
	}
	return 0, false
}

// IsOrganicPermitted judges an input against organic standards.
//
// Returns the reason when it is not, so a finding can say what the problem was
// rather than just that there was one.
func IsOrganicPermitted(category InputCategory, product string) (bool, string) {
	if reason, prohibited := prohibitedUnderOrganic[category]; prohibited {
		return false, reason
	}

	if category == CategoryPesticide {
		lower := strings.ToLower(product)
		for _, allowed := range permittedPesticides {
			if strings.Contains(lower, allowed) {
				return true, ""
			}
		}
		// Unrecognised crop protection fails closed. A blacklist would pass
		// every formulation it had not heard of, and a certification check
		// that errs towards "allowed" is worse than useless — it is a document
		// somebody relies on.
		return false, fmt.Sprintf(
			"%q is not on the list of inputs permitted under organic standards. "+
				"If it is permitted, it has to be added to the list with the "+
				"certifier's approval rather than assumed", product)
	}

	return true, ""
}

// Validate checks an input-use record can be stored.
func (i *InputUse) Validate() error {
	if strings.TrimSpace(i.FieldID) == "" {
		return ErrMissingField
	}
	if i.Category == "" {
		return ErrUnknownCategory
	}
	if i.Quantity <= 0 {
		return ErrInvalidQuantity
	}
	if i.Year < 2000 || i.Year > 2100 {
		return ErrInvalidYear
	}
	return nil
}

// DefaultUnit is the unit a category is measured in.
//
// Recorded rather than assumed at read time, because a diesel figure in litres
// and one in kg differ by 20% and nothing downstream could tell them apart.
func DefaultUnit(category InputCategory) string {
	switch category {
	case CategoryDiesel:
		return "L"
	case CategoryElectricity:
		return "kWh"
	case CategoryResidueBurn:
		return "t"
	default:
		return "kg"
	}
}

// ListInputUseParams filters an input-use query.
type ListInputUseParams struct {
	TenantID string
	FieldID  string
	Year     int
	Category InputCategory
	From     time.Time
	To       time.Time
	Limit    int
	Offset   int
}
