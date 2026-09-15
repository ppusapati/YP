package domain

import (
	"sort"
	"time"
)

// DailyRain is one day's rainfall total at a field.
type DailyRain struct {
	Date time.Time
	MM   float64
}

// The onset criterion, after the IMD's operational definition.
//
// A single wet day in May is a pre-monsoon thunderstorm, not the monsoon, and
// sowing on it is the classic way to lose a crop: the seed germinates, the
// rain stops for a fortnight, and the field has to be sown again. What marks
// the actual onset is rain that *keeps going*, so the test is a spell, not a
// day.
const (
	// onsetSpellDays is how many consecutive days the spell is measured over.
	onsetSpellDays = 5
	// onsetSpellMM is the rainfall the spell must total.
	onsetSpellMM = 25.0
	// onsetWetDays is how many of those days must actually be wet, which is
	// what separates a monsoon spell from one cloudburst inside a dry week.
	onsetWetDays = 3
	// onsetWetDayMM is the threshold for calling a day wet at all. Below this
	// is dew and drizzle that never reaches the root zone.
	onsetWetDayMM = 2.5

	// onsetEarliestDay and onsetLatestDay bound the search: the monsoon reaches
	// the Indian mainland at Kerala around 1 June (day 152) and the whole
	// country by mid-July (day ~196). A "monsoon onset" outside that is a
	// pre-monsoon storm or a data error, and shifting a sowing window onto it
	// would be worse than the calendar default.
	onsetEarliestDay = 121 // 1 May, early enough for Kerala in an early year
	onsetLatestDay   = 213 // 1 August
)

// DetectMonsoonOnset works out when the rains typically arrive at a field.
//
// Each year is scanned separately for the first qualifying spell and the
// per-year onset days are averaged. Averaging the *days* rather than pooling
// the rainfall is deliberate: a single very wet year would otherwise drag the
// answer towards its own onset, and what a planner needs is the typical date,
// not the wettest one.
//
// Returns nil when no year has a detectable onset. The caller reads that as
// "use the crop calendar", which is the honest answer — a made-up onset date
// would be presented as field-specific knowledge the service does not have.
func DetectMonsoonOnset(daily []DailyRain) *MonsoonOnset {
	byYear := map[int][]DailyRain{}
	for _, d := range daily {
		if d.Date.IsZero() {
			continue
		}
		byYear[d.Date.Year()] = append(byYear[d.Date.Year()], d)
	}

	var days []int
	for _, series := range byYear {
		if day, ok := onsetDay(series); ok {
			days = append(days, day)
		}
	}
	if len(days) == 0 {
		return nil
	}

	total := 0
	for _, d := range days {
		total += d
	}
	return &MonsoonOnset{
		// Rounded rather than truncated: with three years at days 160, 161 and
		// 161 the answer is 161, and truncation would say 160.
		DayOfYear: int(float64(total)/float64(len(days)) + 0.5),
		Years:     len(days),
	}
}

// onsetDay finds the first qualifying spell in one year's rainfall.
func onsetDay(series []DailyRain) (int, bool) {
	sort.Slice(series, func(i, j int) bool { return series[i].Date.Before(series[j].Date) })

	// Indexed by day of year so a gap in the record is a zero rather than a
	// day that quietly shifts the window. A missing day is not a dry day, but
	// treating it as dry only ever delays the detected onset — which fails
	// towards the calendar default rather than towards sowing too early.
	rain := make([]float64, 367)
	for _, d := range series {
		day := d.Date.YearDay()
		if day >= 0 && day < len(rain) && d.MM > 0 {
			rain[day] += d.MM
		}
	}

	for start := onsetEarliestDay; start <= onsetLatestDay; start++ {
		end := start + onsetSpellDays
		if end >= len(rain) {
			break
		}
		sum, wet := 0.0, 0
		for day := start; day < end; day++ {
			sum += rain[day]
			if rain[day] >= onsetWetDayMM {
				wet++
			}
		}
		if sum >= onsetSpellMM && wet >= onsetWetDays {
			// The onset is the first wet day *inside* the qualifying window,
			// not the window's first day. The window is a five-day ruler slid
			// along the year; where it happens to be standing when the test
			// passes is an artefact of the search, and reporting it would date
			// the monsoon up to four days before any rain fell.
			for day := start; day < end; day++ {
				if rain[day] >= onsetWetDayMM {
					return day, true
				}
			}
			return start, true
		}
	}
	return 0, false
}
