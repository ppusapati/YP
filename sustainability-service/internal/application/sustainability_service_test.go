package application

import (
	"context"
	"errors"
	"strings"
	"testing"
	"time"

	"go.uber.org/zap"

	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	"p9e.in/samavaya/agriculture/sustainability-service/internal/domain"
	"p9e.in/samavaya/agriculture/sustainability-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/sustainability-service/internal/ports/outbound"
)

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

type fakeRepo struct {
	inputs     []domain.InputUse
	footprints map[string]*domain.Footprint

	allErr    error
	createErr error

	// allCalls records the params AllInputs was asked for, which is how the
	// "reads the whole history, not a page" behaviour is checked.
	allCalls []domain.ListInputUseParams
}

func newRepo() *fakeRepo {
	return &fakeRepo{footprints: map[string]*domain.Footprint{}}
}

func (r *fakeRepo) CreateInput(_ context.Context, in *domain.InputUse) (*domain.InputUse, error) {
	if r.createErr != nil {
		return nil, r.createErr
	}
	clone := *in
	r.inputs = append(r.inputs, clone)
	return &clone, nil
}

func (r *fakeRepo) ListInputs(_ context.Context, params domain.ListInputUseParams) ([]domain.InputUse, int64, error) {
	out := r.filter(params)
	return out, int64(len(out)), nil
}

func (r *fakeRepo) AllInputs(_ context.Context, params domain.ListInputUseParams) ([]domain.InputUse, error) {
	r.allCalls = append(r.allCalls, params)
	if r.allErr != nil {
		return nil, r.allErr
	}
	return r.filter(params), nil
}

func (r *fakeRepo) filter(params domain.ListInputUseParams) []domain.InputUse {
	var out []domain.InputUse
	for _, in := range r.inputs {
		if params.FieldID != "" && in.FieldID != params.FieldID {
			continue
		}
		if params.Year != 0 && in.Year != params.Year {
			continue
		}
		out = append(out, in)
	}
	return out
}

func (r *fakeRepo) SaveFootprint(_ context.Context, f *domain.Footprint) (*domain.Footprint, error) {
	clone := *f
	r.footprints[f.ID] = &clone
	return &clone, nil
}

func (r *fakeRepo) GetFootprint(_ context.Context, id, _ string) (*domain.Footprint, error) {
	f, ok := r.footprints[id]
	if !ok {
		return nil, errors.New("not found")
	}
	clone := *f
	return &clone, nil
}

func (r *fakeRepo) ListFootprints(_ context.Context, _ domain.ListFootprintsParams) ([]domain.Footprint, int64, error) {
	out := make([]domain.Footprint, 0, len(r.footprints))
	for _, f := range r.footprints {
		out = append(out, *f)
	}
	return out, int64(len(out)), nil
}

type fakePublisher struct{ topics []string }

func (p *fakePublisher) Publish(_ context.Context, topic, _ string, _ []byte) error {
	p.topics = append(p.topics, topic)
	return nil
}

func (p *fakePublisher) count(topic string) int {
	n := 0
	for _, t := range p.topics {
		if t == topic {
			n++
		}
	}
	return n
}

var testNow = time.Date(2026, time.September, 15, 9, 0, 0, 0, time.UTC)

// newService takes the ports as interfaces rather than as concrete pointers:
// a typed nil pointer assigned to an interface is not nil, so a helper taking
// *fakePublisher would hand the service a non-nil publisher backed by nothing.
func newService(inputs outbound.InputRepository, footprints outbound.FootprintRepository, pub outbound.EventPublisher) inbound.SustainabilityService {
	svc := NewSustainabilityService(inputs, footprints, pub,
		p9log.NewLogger(zap.NewNop())).(*sustainabilityService)
	svc.now = func() time.Time { return testNow }
	return svc
}

func tenantCtx() context.Context {
	return p9context.NewConnectionInfo(context.Background(),
		&saas.ConnectionInfo{TenantID: "01TENANT0000000000000000AA"})
}

// ─────────────────────────────────────────────────────────────────────────────
// Recording inputs
// ─────────────────────────────────────────────────────────────────────────────

func TestRecordInputDerivesNitrogenAndTheOrganicVerdict(t *testing.T) {
	repo := newRepo()
	svc := newService(repo, repo, nil)

	in, err := svc.RecordInputUse(tenantCtx(), &domain.InputUse{
		FieldID: "field-1", Category: domain.CategoryUrea,
		Product: "Urea 46%", Quantity: 200, Year: 2026,
	})
	if err != nil {
		t.Fatalf("RecordInputUse: %v", err)
	}

	if in.NitrogenKg != 92 {
		t.Errorf("nitrogen = %.1f kg, want 92 — 200 kg of urea at 46%%", in.NitrogenKg)
	}
	if in.OrganicPermitted {
		t.Error("urea was recorded as permitted under organic standards")
	}
	if in.Unit != "kg" {
		t.Errorf("unit = %q, want kg", in.Unit)
	}
	if in.ID == "" {
		t.Error("the record was stored without an id")
	}
}

// A guessed nitrogen fraction propagates into the N2O line and nothing
// downstream could tell it apart from a measured one.
func TestUnknownProductLeavesNitrogenUnsetAndSaysSo(t *testing.T) {
	repo := newRepo()
	svc := newService(repo, repo, nil)

	in, err := svc.RecordInputUse(tenantCtx(), &domain.InputUse{
		FieldID: "field-1", Category: domain.CategorySyntheticN,
		Product: "SuperGro Plus", Quantity: 100, Year: 2026,
	})
	if err != nil {
		t.Fatalf("RecordInputUse: %v", err)
	}

	if in.NitrogenKg != 0 {
		t.Errorf("nitrogen = %.1f for an unrecognised product; it should be left unknown",
			in.NitrogenKg)
	}
	if !strings.Contains(in.Notes, "understated") {
		t.Errorf("notes = %q; the record does not warn that the footprint will be short",
			in.Notes)
	}
}

// The farmer holding the bag knows its analysis better than a lookup table.
func TestACallerSuppliedNitrogenFigureWins(t *testing.T) {
	repo := newRepo()
	svc := newService(repo, repo, nil)

	in, _ := svc.RecordInputUse(tenantCtx(), &domain.InputUse{
		FieldID: "field-1", Category: domain.CategoryUrea,
		Product: "Urea", Quantity: 200, NitrogenKg: 88, Year: 2026,
	})
	if in.NitrogenKg != 88 {
		t.Errorf("nitrogen = %.1f, want the caller's 88", in.NitrogenKg)
	}
}

// A prohibited input restarts a three-year conversion period. Finding that out
// at the next audit is two and a half years too late.
func TestProhibitedInputIsAnnouncedWhenItIsRecorded(t *testing.T) {
	repo := newRepo()
	pub := &fakePublisher{}
	svc := newService(repo, repo, pub)

	if _, err := svc.RecordInputUse(tenantCtx(), &domain.InputUse{
		FieldID: "field-1", Category: domain.CategoryUrea,
		Product: "Urea", Quantity: 100, Year: 2026,
	}); err != nil {
		t.Fatalf("RecordInputUse: %v", err)
	}

	if pub.count(topicProhibitedInput) != 1 {
		t.Errorf("published %v; a prohibited input should raise an alert as it is "+
			"recorded, not only when somebody runs a check", pub.topics)
	}
}

func TestPermittedInputRaisesNoAlert(t *testing.T) {
	repo := newRepo()
	pub := &fakePublisher{}
	svc := newService(repo, repo, pub)

	if _, err := svc.RecordInputUse(tenantCtx(), &domain.InputUse{
		FieldID: "field-1", Category: domain.CategoryOrganicN,
		Product: "Farmyard manure", Quantity: 3000, Year: 2026,
	}); err != nil {
		t.Fatalf("RecordInputUse: %v", err)
	}

	if pub.count(topicProhibitedInput) != 0 {
		t.Error("manure raised a prohibited-input alert")
	}
}

func TestRecordInputRequiresATenant(t *testing.T) {
	repo := newRepo()
	_, err := newService(repo, repo, nil).RecordInputUse(context.Background(), &domain.InputUse{
		FieldID: "field-1", Category: domain.CategoryUrea, Quantity: 100, Year: 2026,
	})
	if err == nil {
		t.Fatal("a record with no tenant should be refused")
	}
}

func TestRecordInputDefaultsTheYearToNow(t *testing.T) {
	repo := newRepo()
	in, err := newService(repo, repo, nil).RecordInputUse(tenantCtx(), &domain.InputUse{
		FieldID: "field-1", Category: domain.CategoryDiesel, Quantity: 40,
	})
	if err != nil {
		t.Fatalf("RecordInputUse: %v", err)
	}
	if in.Year != 2026 {
		t.Errorf("year = %d, want 2026", in.Year)
	}
	if in.Unit != "L" {
		t.Errorf("unit = %q, want L — diesel in kg and in litres differ by 20%%", in.Unit)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Footprints
// ─────────────────────────────────────────────────────────────────────────────

func TestComputeFootprintReadsTheWholeYearNotAPage(t *testing.T) {
	repo := newRepo()
	svc := newService(repo, repo, nil)
	ctx := tenantCtx()

	for _, in := range []domain.InputUse{
		{FieldID: "field-1", Category: domain.CategoryUrea, Product: "Urea", Quantity: 200, Year: 2026},
		{FieldID: "field-1", Category: domain.CategoryDiesel, Quantity: 60, Year: 2026},
	} {
		input := in
		if _, err := svc.RecordInputUse(ctx, &input); err != nil {
			t.Fatalf("RecordInputUse: %v", err)
		}
	}

	fp, err := svc.ComputeFootprint(ctx, domain.FootprintParams{
		FieldID: "field-1", Crop: "Wheat", Year: 2026,
		AreaHectares: 2, WaterRegime: domain.RegimeUpland,
	})
	if err != nil {
		t.Fatalf("ComputeFootprint: %v", err)
	}

	if len(repo.allCalls) == 0 {
		t.Fatal("the footprint was computed without reading the input history")
	}
	last := repo.allCalls[len(repo.allCalls)-1]
	if last.Limit != 0 || last.Offset != 0 {
		t.Errorf("the history read was paged (limit %d, offset %d); a footprint from "+
			"the first page of applications would look like an answer", last.Limit, last.Offset)
	}
	if fp.TotalKgCO2e <= 0 {
		t.Error("the footprint came out at zero with two applications recorded")
	}
	if fp.ID == "" {
		t.Error("the footprint was not stored")
	}
}

// The incompleteness has to survive the trip out, or a consumer presents the
// total as a finished number.
func TestComputeFootprintPublishesItsCompleteness(t *testing.T) {
	repo := newRepo()
	pub := &fakePublisher{}
	svc := newService(repo, repo, pub)

	fp, err := svc.ComputeFootprint(tenantCtx(), domain.FootprintParams{
		FieldID: "field-1", Crop: "Wheat", Year: 2026,
		AreaHectares: 2, WaterRegime: domain.RegimeUpland,
	})
	if err != nil {
		t.Fatalf("ComputeFootprint: %v", err)
	}

	if fp.Complete {
		t.Error("a footprint with no inputs at all reports itself as complete")
	}
	if len(fp.MissingSources) == 0 {
		t.Error("nothing was flagged as missing")
	}
	if pub.count(topicFootprintComputed) != 1 {
		t.Errorf("published %v, want one %s", pub.topics, topicFootprintComputed)
	}
}

func TestComputeFootprintRefusesAZeroArea(t *testing.T) {
	repo := newRepo()
	_, err := newService(repo, repo, nil).ComputeFootprint(tenantCtx(), domain.FootprintParams{
		FieldID: "field-1", Year: 2026,
	})
	if err == nil {
		t.Fatal("a zero area should be refused rather than dividing the intensity by zero")
	}
}

func TestComputeFootprintRequiresAField(t *testing.T) {
	repo := newRepo()
	_, err := newService(repo, repo, nil).ComputeFootprint(tenantCtx(), domain.FootprintParams{
		AreaHectares: 2, Year: 2026,
	})
	if err == nil {
		t.Fatal("a footprint with no field should be refused")
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Certification
// ─────────────────────────────────────────────────────────────────────────────

func recordYears(t *testing.T, svc inbound.SustainabilityService, ctx context.Context, years ...int) {
	t.Helper()
	for _, year := range years {
		if _, err := svc.RecordInputUse(ctx, &domain.InputUse{
			FieldID: "field-1", Category: domain.CategoryOrganicN,
			Product: "Farmyard manure", Quantity: 4000, Year: year,
			AppliedOn: time.Date(year, time.June, 1, 0, 0, 0, 0, time.UTC),
		}); err != nil {
			t.Fatalf("RecordInputUse: %v", err)
		}
	}
}

func TestCheckCertificationReadsTheFieldsWholeHistory(t *testing.T) {
	repo := newRepo()
	svc := newService(repo, repo, nil)
	ctx := tenantCtx()
	recordYears(t, svc, ctx, 2024, 2025, 2026)

	check, err := svc.CheckCertification(ctx, "field-1", domain.StandardNPOP,
		time.Date(2023, time.April, 1, 0, 0, 0, 0, time.UTC))
	if err != nil {
		t.Fatalf("CheckCertification: %v", err)
	}

	if check.Status != domain.StatusEligible {
		t.Fatalf("status = %s, want ELIGIBLE. Summary: %s", check.Status, check.Summary)
	}

	// The history read must not be narrowed to one year — a urea application in
	// 2024 blocks a claim made in 2026.
	last := repo.allCalls[len(repo.allCalls)-1]
	if last.Year != 0 {
		t.Errorf("the certification read was narrowed to year %d; a prohibited input "+
			"in an earlier year would be invisible to it", last.Year)
	}
}

// The rules differ enough between schemes that defaulting to one would assess
// a field against a standard nobody asked about.
func TestCheckCertificationRefusesAnUnspecifiedStandard(t *testing.T) {
	repo := newRepo()
	_, err := newService(repo, repo, nil).CheckCertification(tenantCtx(), "field-1", "", time.Time{})
	if err == nil {
		t.Fatal("a check with no standard should be refused rather than defaulted")
	}
}

// The file looks like a certificate whatever it says inside.
func TestExportRefusesAPackThatWouldNotPass(t *testing.T) {
	repo := newRepo()
	svc := newService(repo, repo, nil)
	ctx := tenantCtx()
	recordYears(t, svc, ctx, 2024, 2025, 2026)

	if _, err := svc.RecordInputUse(ctx, &domain.InputUse{
		FieldID: "field-1", Category: domain.CategoryUrea, Product: "Urea",
		Quantity: 100, Year: 2025,
		AppliedOn: time.Date(2025, time.August, 3, 0, 0, 0, 0, time.UTC),
	}); err != nil {
		t.Fatalf("RecordInputUse: %v", err)
	}

	conversion := time.Date(2023, time.April, 1, 0, 0, 0, 0, time.UTC)

	_, err := svc.ExportCertificationPack(ctx, "field-1", domain.StandardNPOP, conversion, false)
	if err == nil {
		t.Fatal("a blocked field's pack was exported without being asked for explicitly")
	}
	if !strings.Contains(err.Error(), "allow_incomplete") {
		t.Errorf("the refusal does not say how to get the pack anyway: %v", err)
	}

	// And with the flag it comes out, carrying the blocker.
	pack, err := svc.ExportCertificationPack(ctx, "field-1", domain.StandardNPOP, conversion, true)
	if err != nil {
		t.Fatalf("an explicitly requested pack was still refused: %v", err)
	}
	if pack.Check.Status != domain.StatusBlocked {
		t.Errorf("the exported pack's check says %s", pack.Check.Status)
	}
	if !strings.Contains(string(pack.Content), "PROHIBITED_INPUT") {
		t.Error("the pack does not carry the blocker that stopped it")
	}
	if pack.Filename == "" || pack.ContentType != "text/csv" {
		t.Errorf("filename %q, content type %q", pack.Filename, pack.ContentType)
	}
}

func TestExportOfAnEligibleFieldNeedsNoFlag(t *testing.T) {
	repo := newRepo()
	svc := newService(repo, repo, nil)
	ctx := tenantCtx()
	recordYears(t, svc, ctx, 2024, 2025, 2026)

	pack, err := svc.ExportCertificationPack(ctx, "field-1", domain.StandardNPOP,
		time.Date(2023, time.April, 1, 0, 0, 0, 0, time.UTC), false)
	if err != nil {
		t.Fatalf("ExportCertificationPack: %v", err)
	}
	if len(pack.Content) == 0 {
		t.Error("the pack is empty")
	}
	if !strings.Contains(string(pack.Content), "Farmyard manure") {
		t.Error("the pack does not contain the input records")
	}
}

// A read failure must not come back as an empty history, because an empty
// history reads as a clean field.
func TestCheckCertificationSurfacesAReadFailure(t *testing.T) {
	repo := newRepo()
	repo.allErr = errors.New("database unavailable")

	_, err := newService(repo, repo, nil).CheckCertification(tenantCtx(), "field-1",
		domain.StandardNPOP, time.Time{})
	if err == nil {
		t.Fatal("a failed history read produced a certification verdict; an empty " +
			"history is indistinguishable from a clean one")
	}
}
