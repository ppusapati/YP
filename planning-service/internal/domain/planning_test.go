package domain

import (
	"errors"
	"math"
	"strings"
	"testing"
	"time"
)

// ─────────────────────────────────────────────────────────────────────────────
// Crop lookup
// ─────────────────────────────────────────────────────────────────────────────

func TestLookupCrop_IsForgivingAboutSpelling(t *testing.T) {
	for _, name := range []string{"wheat", "Wheat", "  WHEAT  ", "Pigeon pea", "pigeonpea"} {
		if _, ok := LookupCrop(name); !ok {
			t.Errorf("LookupCrop(%q) missed", name)
		}
	}
}

func TestLookupCrop_ReportsAnUnknownCrop(t *testing.T) {
	// A zero profile would give a sowing window on the season's first day, no
	// nitrogen demand and a seed cost of nothing — a confident plan for a crop
	// the service knows nothing about.
	if _, ok := LookupCrop("quinoa"); ok {
		t.Fatal("an unknown crop was resolved")
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Sowing windows
// ─────────────────────────────────────────────────────────────────────────────

func TestComputeSowingWindow_UsesTheCropCalendarWithNoWeather(t *testing.T) {
	window, err := ComputeSowingWindow("wheat", Rabi, 2026, nil)
	if err != nil {
		t.Fatalf("window: %v", err)
	}

	if window.WeatherInformed {
		t.Error("a calendar window claimed to be weather-informed")
	}
	// Rabi opens 15 October; wheat's offset is 20 days.
	if want := time.Date(2026, time.November, 4, 0, 0, 0, 0, time.UTC); !window.Opens.Equal(want) {
		t.Errorf("opens %s, want %s", window.Opens.Format("2 Jan"), want.Format("2 Jan"))
	}
	if !window.Closes.After(window.Opens) {
		t.Error("the window closes before it opens")
	}
	if window.Optimal.Before(window.Opens) || window.Optimal.After(window.Closes) {
		t.Error("the optimal date is outside the window")
	}
}

func TestComputeSowingWindow_FollowsTheMonsoonForKharif(t *testing.T) {
	// A field in Vidarbha and one in Konkan are three weeks apart and the
	// calendar does not know that. Rainfall onset is what actually decides
	// when a kharif crop goes in.
	onset := &MonsoonOnset{DayOfYear: 175, Years: 10} // 24 June
	window, err := ComputeSowingWindow("cotton", Kharif, 2026, onset)
	if err != nil {
		t.Fatalf("window: %v", err)
	}

	if !window.WeatherInformed {
		t.Fatal("a window built from ten years of rainfall was not marked weather-informed")
	}
	if window.Opens.Month() != time.June || window.Opens.Day() != 24 {
		t.Errorf("opens %s, want 24 June", window.Opens.Format("2 Jan"))
	}
	if !strings.Contains(window.Basis, "monsoon onset") {
		t.Errorf("basis = %q", window.Basis)
	}
}

func TestComputeSowingWindow_IgnoresTooLittleRainfallHistory(t *testing.T) {
	// Monsoon onset varies by a fortnight between years, so one or two years
	// says nothing — and a window moved on the strength of a single wet season
	// is worse than the calendar default, because it looks field-specific.
	onset := &MonsoonOnset{DayOfYear: 200, Years: 2}
	window, err := ComputeSowingWindow("cotton", Kharif, 2026, onset)
	if err != nil {
		t.Fatalf("window: %v", err)
	}

	if window.WeatherInformed {
		t.Fatal("two years of rainfall was treated as a local onset")
	}
	if window.Opens.Month() != time.June || window.Opens.Day() != 1 {
		t.Errorf("opens %s; it should fall back to the calendar", window.Opens.Format("2 Jan"))
	}
}

func TestComputeSowingWindow_RabiIgnoresMonsoonOnset(t *testing.T) {
	// Rabi is sown after the kharif harvest on residual moisture. Shifting it
	// by rainfall onset would be borrowing a rule from the wrong season.
	onset := &MonsoonOnset{DayOfYear: 175, Years: 10}
	window, err := ComputeSowingWindow("wheat", Rabi, 2026, onset)
	if err != nil {
		t.Fatalf("window: %v", err)
	}

	if window.WeatherInformed {
		t.Error("a rabi window was shifted by the monsoon")
	}
	if window.Opens.Month() != time.November {
		t.Errorf("opens %s, want November", window.Opens.Format("2 Jan"))
	}
}

func TestComputeSowingWindow_RefusesACropOutOfSeason(t *testing.T) {
	// Wheat is a rabi crop. A kharif wheat plan would have a sowing window in
	// the monsoon and a budget for a crop that will not germinate.
	_, err := ComputeSowingWindow("wheat", Kharif, 2026, nil)
	if !errors.Is(err, ErrSeasonMismatch) {
		t.Fatalf("expected ErrSeasonMismatch, got %v", err)
	}
}

func TestComputeSowingWindow_RefusesAnUnknownCrop(t *testing.T) {
	if _, err := ComputeSowingWindow("quinoa", Kharif, 2026, nil); !errors.Is(err, ErrUnknownCrop) {
		t.Fatalf("expected ErrUnknownCrop, got %v", err)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Rotation
// ─────────────────────────────────────────────────────────────────────────────

func TestCheckRotation_SameFamilyIsPoor(t *testing.T) {
	// Tomato then chilli are two different crops and the same Solanaceae. A
	// check that compared crop names would call that a rotation and let a
	// farmer plant into a wilt they cannot see until the crop is in.
	check := CheckRotation("chilli", "tomato")

	if check.Verdict != RotationPoor {
		t.Fatalf("verdict = %s, want POOR", check.Verdict)
	}
	if !strings.Contains(check.Rationale, "family") {
		t.Errorf("the rationale does not explain why: %q", check.Rationale)
	}
}

func TestCheckRotation_SameCropIsPoor(t *testing.T) {
	check := CheckRotation("rice", "rice")
	if check.Verdict != RotationPoor {
		t.Fatalf("verdict = %s, want POOR", check.Verdict)
	}
}

func TestCheckRotation_AfterALegumeIsGoodAndCarriesTheCredit(t *testing.T) {
	// A legume credit that is ignored means a farmer buys urea they do not
	// need — money, and nitrogen that ends up in the groundwater.
	check := CheckRotation("wheat", "chickpea")

	if check.Verdict != RotationGood {
		t.Fatalf("verdict = %s, want GOOD", check.Verdict)
	}
	if check.NitrogenCreditKgHa != 40 {
		t.Errorf("nitrogen credit = %v, want 40", check.NitrogenCreditKgHa)
	}
	if !strings.Contains(check.Rationale, "40") {
		t.Errorf("the rationale does not name the credit: %q", check.Rationale)
	}
}

func TestCheckRotation_ALegumeFollowingAnythingIsGood(t *testing.T) {
	check := CheckRotation("soybean", "cotton")

	if check.Verdict != RotationGood {
		t.Fatalf("verdict = %s, want GOOD", check.Verdict)
	}
	if !strings.Contains(check.Rationale, "fixes") {
		t.Errorf("rationale = %q", check.Rationale)
	}
}

func TestCheckRotation_DifferentFamiliesAreAcceptable(t *testing.T) {
	check := CheckRotation("wheat", "cotton")

	if check.Verdict != RotationAcceptable {
		t.Fatalf("verdict = %s, want ACCEPTABLE", check.Verdict)
	}
	if check.NitrogenCreditKgHa != 0 {
		t.Errorf("a non-legume left a nitrogen credit of %v", check.NitrogenCreditKgHa)
	}
}

func TestCheckRotation_NoHistoryIsNotApproval(t *testing.T) {
	// A newly broken field gets a neutral verdict that says the history is
	// missing, rather than a "good" that implies it was checked.
	check := CheckRotation("cotton", "")

	if check.Verdict != RotationAcceptable {
		t.Fatalf("verdict = %s", check.Verdict)
	}
	if !strings.Contains(check.Rationale, "No previous crop") {
		t.Errorf("rationale = %q", check.Rationale)
	}
	if check.Verdict == RotationGood {
		t.Error("an unchecked rotation was reported as good")
	}
}

func TestCheckRotation_AnUnknownCropIsUnverifiedNotApproved(t *testing.T) {
	check := CheckRotation("quinoa", "wheat")

	if check.Verdict == RotationGood {
		t.Fatal("an uncheckable rotation was approved")
	}
	if !strings.Contains(check.Rationale, "unverified") {
		t.Errorf("the rationale does not say it is unverified: %q", check.Rationale)
	}
}

func TestCheckRotation_UsesDisplayNames(t *testing.T) {
	check := CheckRotation("pigeonpea", "cotton")
	if check.Crop != "Pigeon pea" {
		t.Errorf("crop = %q, want the display name", check.Crop)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Budget
// ─────────────────────────────────────────────────────────────────────────────

func TestBuildBudget_ScalesWithArea(t *testing.T) {
	one, err := BuildBudget("wheat", 1, 0)
	if err != nil {
		t.Fatalf("budget: %v", err)
	}
	ten, err := BuildBudget("wheat", 10, 0)
	if err != nil {
		t.Fatalf("budget: %v", err)
	}

	if math.Abs(ten.TotalCost-one.TotalCost*10) > 1 {
		t.Errorf("ten hectares cost %v, want ten times %v", ten.TotalCost, one.TotalCost)
	}
	if math.Abs(ten.CostPerHectare-one.CostPerHectare) > 0.01 {
		t.Errorf("cost per hectare changed with area: %v vs %v",
			one.CostPerHectare, ten.CostPerHectare)
	}
}

func TestBuildBudget_SubtractsTheLegumeCredit(t *testing.T) {
	// The difference between a realistic budget and one that buys urea the
	// field does not need.
	withoutCredit, _ := BuildBudget("wheat", 1, 0)
	withCredit, _ := BuildBudget("wheat", 1, 40)

	if withCredit.TotalCost >= withoutCredit.TotalCost {
		t.Fatalf("the credit did not reduce the budget: %v vs %v",
			withCredit.TotalCost, withoutCredit.TotalCost)
	}

	line := findLine(t, withCredit, "Nitrogen (as urea)")
	if line.Quantity != 80 {
		t.Errorf("nitrogen = %v kg, want 120 - 40", line.Quantity)
	}
	if !strings.Contains(line.Note, "covered by the previous legume") {
		t.Errorf("the line does not explain the reduction: %q", line.Note)
	}
}

func TestBuildBudget_ACreditLargerThanTheDemandDoesNotGoNegative(t *testing.T) {
	// A soil cannot owe nitrogen back, and a negative line would subtract
	// money from the total.
	budget, err := BuildBudget("chickpea", 1, 200)
	if err != nil {
		t.Fatalf("budget: %v", err)
	}

	line := findLine(t, budget, "Nitrogen (as urea)")
	if line.Quantity < 0 || line.TotalCost < 0 {
		t.Fatalf("a negative nitrogen line: %+v", line)
	}
	if !strings.Contains(line.Note, "no nitrogen is budgeted") {
		t.Errorf("the line does not say why it is zero: %q", line.Note)
	}
}

func TestBuildBudget_TotalIsTheSumOfItsLines(t *testing.T) {
	budget, err := BuildBudget("cotton", 4, 0)
	if err != nil {
		t.Fatalf("budget: %v", err)
	}

	var sum float64
	for _, line := range budget.Lines {
		sum += line.TotalCost
	}
	if math.Abs(sum-budget.TotalCost) > 0.01 {
		t.Errorf("total %v does not match the lines' %v", budget.TotalCost, sum)
	}
}

func TestBuildBudget_CoversEveryInputKind(t *testing.T) {
	// A budget missing labour or irrigation is one a farmer plans against and
	// then runs out of money halfway through the season.
	budget, err := BuildBudget("rice", 2, 0)
	if err != nil {
		t.Fatalf("budget: %v", err)
	}

	seen := map[InputKind]bool{}
	for _, line := range budget.Lines {
		seen[line.Kind] = true
	}
	for _, kind := range []InputKind{InputSeed, InputFertiliser, InputPesticide,
		InputLabour, InputMachinery, InputIrrigation} {
		if !seen[kind] {
			t.Errorf("the budget has no %s line", kind)
		}
	}
}

func TestBuildBudget_SaysTheFertiliserIsAnEstimate(t *testing.T) {
	// Not soil-test driven — that is prescription-service's job — and a
	// planner that pretended otherwise would produce a budget somebody trusted
	// as a recommendation.
	budget, _ := BuildBudget("wheat", 1, 0)

	line := findLine(t, budget, "Phosphorus (as DAP)")
	if !strings.Contains(line.Note, "planning estimate") {
		t.Errorf("the phosphorus line does not say it is an estimate: %q", line.Note)
	}
}

func TestBuildBudget_RefusesAnUnknownCropOrArea(t *testing.T) {
	if _, err := BuildBudget("quinoa", 1, 0); !errors.Is(err, ErrUnknownCrop) {
		t.Errorf("expected ErrUnknownCrop, got %v", err)
	}
	if _, err := BuildBudget("wheat", 0, 0); !errors.Is(err, ErrInvalidArea) {
		t.Errorf("expected ErrInvalidArea, got %v", err)
	}
	if _, err := BuildBudget("wheat", -3, 0); !errors.Is(err, ErrInvalidArea) {
		t.Errorf("expected ErrInvalidArea, got %v", err)
	}
}

func findLine(t *testing.T, budget InputBudget, item string) InputLine {
	t.Helper()
	for _, line := range budget.Lines {
		if line.Item == item {
			return line
		}
	}
	t.Fatalf("no %q line in the budget", item)
	return InputLine{}
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan
// ─────────────────────────────────────────────────────────────────────────────

func plan() SeasonPlan {
	return SeasonPlan{
		FieldID: "fld-1", Crop: "wheat", Season: Rabi,
		Year: 2026, AreaHectares: 4, Status: PlanDraft,
	}
}

func TestPlan_Validate(t *testing.T) {
	p := plan()
	if err := p.Validate(); err != nil {
		t.Fatalf("a good plan was refused: %v", err)
	}

	cases := map[string]func(*SeasonPlan){
		"no field":   func(p *SeasonPlan) { p.FieldID = " " },
		"no crop":    func(p *SeasonPlan) { p.Crop = "" },
		"no season":  func(p *SeasonPlan) { p.Season = "" },
		"zero area":  func(p *SeasonPlan) { p.AreaHectares = 0 },
		"bad year":   func(p *SeasonPlan) { p.Year = 1990 },
		"far future": func(p *SeasonPlan) { p.Year = 2500 },
	}
	for name, mutate := range cases {
		t.Run(name, func(t *testing.T) {
			p := plan()
			mutate(&p)
			if err := p.Validate(); err == nil {
				t.Error("accepted")
			}
		})
	}
}

func TestPlan_OnlyADraftIsEditable(t *testing.T) {
	// Once a plan is committed the seed is ordered and the labour is booked
	// against it; editing it afterwards would make the record disagree with
	// what was actually bought.
	p := plan()
	if !p.Editable() {
		t.Error("a draft was not editable")
	}

	for _, status := range []PlanStatus{PlanCommitted, PlanCompleted, PlanAbandoned} {
		p.Status = status
		if p.Editable() {
			t.Errorf("a %s plan was editable", status)
		}
	}
}

func TestKnownCrops(t *testing.T) {
	crops := KnownCrops()
	if len(crops) < 10 {
		t.Errorf("the crop calendar has only %d crops", len(crops))
	}
}
