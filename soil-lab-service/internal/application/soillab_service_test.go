package application

import (
	"context"
	"errors"
	"strings"
	"testing"
	"time"

	"go.uber.org/zap"

	p9errors "p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	"p9e.in/samavaya/agriculture/soil-lab-service/internal/domain"
	"p9e.in/samavaya/agriculture/soil-lab-service/internal/ports/outbound"
)

var testNow = time.Date(2026, 3, 14, 9, 0, 0, 0, time.UTC)

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

type fakeRepo struct {
	labs    map[string]*domain.Lab
	reports map[string]*domain.LabReport
	byHash  map[string]*domain.LabReport

	saved *domain.LabReport
}

func newRepo() *fakeRepo {
	return &fakeRepo{
		labs:    map[string]*domain.Lab{},
		reports: map[string]*domain.LabReport{},
		byHash:  map[string]*domain.LabReport{},
	}
}

func (f *fakeRepo) CreateLab(_ context.Context, lab *domain.Lab) (*domain.Lab, error) {
	f.labs[lab.ID] = lab
	return lab, nil
}

func (f *fakeRepo) GetLab(_ context.Context, id, _ string) (*domain.Lab, error) {
	lab, ok := f.labs[id]
	if !ok {
		return nil, p9errors.NotFound("LAB_NOT_FOUND", "not found")
	}
	return lab, nil
}

func (f *fakeRepo) ListLabs(context.Context, domain.ListLabsParams) ([]domain.Lab, int64, error) {
	return nil, 0, nil
}

func (f *fakeRepo) CreateReport(_ context.Context, r *domain.LabReport) (*domain.LabReport, error) {
	f.reports[r.ID] = r
	f.byHash[r.ContentSHA256] = r
	return r, nil
}

func (f *fakeRepo) GetReport(_ context.Context, id, _ string) (*domain.LabReport, error) {
	r, ok := f.reports[id]
	if !ok {
		return nil, p9errors.NotFound("REPORT_NOT_FOUND", "not found")
	}
	return r, nil
}

func (f *fakeRepo) FindByContentHash(_ context.Context, hash, _ string) (*domain.LabReport, error) {
	return f.byHash[hash], nil
}

func (f *fakeRepo) ListReports(context.Context, domain.ListReportsParams) ([]domain.LabReport, int64, error) {
	return nil, 0, nil
}

func (f *fakeRepo) SaveReport(_ context.Context, r *domain.LabReport) error {
	f.saved = r
	return nil
}

type fakeSoil struct {
	received []domain.SoilSample
	// failAfter > 0 makes the client create that many samples and then fail,
	// which is what a soil-service restart mid-batch looks like.
	failAfter int
}

func (f *fakeSoil) CreateSamples(_ context.Context, samples []domain.SoilSample) ([]string, error) {
	var ids []string
	for i, s := range samples {
		if f.failAfter > 0 && i >= f.failAfter {
			return ids, errors.New("soil-service is unavailable")
		}
		f.received = append(f.received, s)
		ids = append(ids, "sample-"+string(rune('a'+i)))
	}
	return ids, nil
}

type fakePublisher struct{ topics []string }

func (f *fakePublisher) Publish(_ context.Context, topic, _ string, _ []byte) error {
	f.topics = append(f.topics, topic)
	return nil
}

// newService builds the service under test.
//
// `soil` is taken as the interface rather than as *fakeSoil deliberately. A
// typed nil pointer assigned to an interface is *not* nil — the interface
// carries the type — so passing (*fakeSoil)(nil) would make the service's
// `s.soil == nil` check false and then call a method on a nil receiver. The
// "no soil client configured" case has to be a true nil interface.
func newService(repo *fakeRepo, soil outbound.SoilClient) (*soilLabService, *fakePublisher) {
	pub := &fakePublisher{}
	svc := NewSoilLabService(repo, soil, nil, pub, p9log.NewLogger(zap.NewNop())).(*soilLabService)
	svc.now = func() time.Time { return testNow }
	return svc, pub
}

func tenantCtx(id string) context.Context {
	return p9context.NewConnectionInfo(context.Background(), &saas.ConnectionInfo{TenantID: id})
}

func isBadRequest(err error, reason string) bool {
	return err != nil && p9errors.IsBadRequest(err) && p9errors.Reason(err) == reason
}

func lab(repo *fakeRepo, aliases map[string]string) *domain.Lab {
	l := &domain.Lab{
		ID: "lab-1", TenantID: "tenant-1",
		Name: "Deccan Soil Labs", ColumnAliases: aliases,
	}
	repo.labs[l.ID] = l
	return l
}

const goodCSV = "Field ID,pH,N,P,K\nfld-1,6.8,220,18,190\nfld-2,7.1,240,22,210\n"

// ─────────────────────────────────────────────────────────────────────────────
// Tenancy
// ─────────────────────────────────────────────────────────────────────────────

func TestEveryOperationRequiresATenant(t *testing.T) {
	// Without a tenant, RLS returns zero rows *successfully*, so an operation
	// that does not check reports an empty result rather than a missing
	// credential.
	svc, _ := newService(newRepo(), &fakeSoil{})
	ctx := context.Background()

	if _, err := svc.UploadReport(ctx, "lab-1", domain.FormatCSV, "a.csv", []byte(goodCSV)); !isBadRequest(err, "MISSING_TENANT") {
		t.Errorf("UploadReport: %v", err)
	}
	if _, err := svc.GetReport(ctx, "r-1"); !isBadRequest(err, "MISSING_TENANT") {
		t.Errorf("GetReport: %v", err)
	}
	if _, err := svc.ApplyReport(ctx, "r-1", false); !isBadRequest(err, "MISSING_TENANT") {
		t.Errorf("ApplyReport: %v", err)
	}
	if _, err := svc.RegisterLab(ctx, &domain.Lab{Name: "x"}); !isBadRequest(err, "MISSING_TENANT") {
		t.Errorf("RegisterLab: %v", err)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Upload
// ─────────────────────────────────────────────────────────────────────────────

func TestUploadReport_ParsesACSV(t *testing.T) {
	repo := newRepo()
	lab(repo, nil)
	svc, _ := newService(repo, &fakeSoil{})

	result, err := svc.UploadReport(tenantCtx("tenant-1"), "lab-1", domain.FormatCSV, "results.csv", []byte(goodCSV))
	if err != nil {
		t.Fatalf("upload: %v", err)
	}

	if result.Report.RowCount != 2 {
		t.Errorf("row count = %d, want 2", result.Report.RowCount)
	}
	if result.Report.Status != domain.StatusParsed {
		t.Errorf("status = %s, want PARSED", result.Report.Status)
	}
	if result.Report.LabName != "Deccan Soil Labs" {
		t.Errorf("lab name = %q", result.Report.LabName)
	}
}

func TestUploadReport_TheSameFileTwiceReturnsTheFirstReport(t *testing.T) {
	// The same results get re-sent as "results (1).csv" more often than not.
	// Three sets of soil samples from one set of readings would triple a
	// field's history.
	repo := newRepo()
	lab(repo, nil)
	svc, _ := newService(repo, &fakeSoil{})
	ctx := tenantCtx("tenant-1")

	first, err := svc.UploadReport(ctx, "lab-1", domain.FormatCSV, "results.csv", []byte(goodCSV))
	if err != nil {
		t.Fatalf("first upload: %v", err)
	}

	second, err := svc.UploadReport(ctx, "lab-1", domain.FormatCSV, "results (1).csv", []byte(goodCSV))
	if err != nil {
		t.Fatalf("second upload: %v", err)
	}

	if !second.Duplicate {
		t.Fatal("a re-upload of the same bytes was not recognised")
	}
	if second.Report.ID != first.Report.ID {
		t.Errorf("a second report was created: %s vs %s", second.Report.ID, first.Report.ID)
	}
	if len(repo.reports) != 1 {
		t.Errorf("reports = %d, want 1", len(repo.reports))
	}
}

func TestUploadReport_APDFIsStoredNotParsed(t *testing.T) {
	// Extracting numbers from a lab's PDF layout is OCR guesswork, and a
	// mis-read potassium figure drives a fertiliser prescription.
	repo := newRepo()
	lab(repo, nil)
	svc, _ := newService(repo, &fakeSoil{})

	result, err := svc.UploadReport(tenantCtx("tenant-1"), "lab-1",
		domain.FormatPDF, "report.pdf", []byte("%PDF-1.7 ..."))
	if err != nil {
		t.Fatalf("upload: %v", err)
	}

	if result.Report.Status != domain.StatusReceived {
		t.Errorf("status = %s; a PDF awaits a person rather than being dealt with", result.Report.Status)
	}
	if len(result.Report.Rows) != 0 {
		t.Error("a PDF was parsed")
	}
}

func TestUploadReport_AnUnparseableCSVIsRejectedWithItsReason(t *testing.T) {
	// A dropped upload leaves the person who sent it with nothing to fix.
	repo := newRepo()
	lab(repo, nil)
	svc, _ := newService(repo, &fakeSoil{})

	result, err := svc.UploadReport(tenantCtx("tenant-1"), "lab-1",
		domain.FormatCSV, "bad.csv", []byte("pH,N\n6.8,220\n"))
	if err != nil {
		t.Fatalf("upload: %v", err)
	}

	if result.Report.Status != domain.StatusRejected {
		t.Fatalf("status = %s, want REJECTED", result.Report.Status)
	}
	if !strings.Contains(result.Report.RejectionReason, "field identifier") {
		t.Errorf("reason = %q", result.Report.RejectionReason)
	}
	// Still recorded: this is exactly the file somebody needs to look at.
	if len(repo.reports) != 1 {
		t.Error("the rejected upload was not recorded")
	}
}

func TestUploadReport_BlockedRowsRaiseAReview(t *testing.T) {
	repo := newRepo()
	lab(repo, nil)
	svc, pub := newService(repo, &fakeSoil{})

	result, err := svc.UploadReport(tenantCtx("tenant-1"), "lab-1", domain.FormatCSV, "a.csv",
		[]byte("Field ID,pH\nfld-1,6.8\n,7.1\n"))
	if err != nil {
		t.Fatalf("upload: %v", err)
	}

	if result.Report.Status != domain.StatusNeedsReview {
		t.Fatalf("status = %s, want NEEDS_REVIEW", result.Report.Status)
	}
	if len(pub.topics) != 1 || pub.topics[0] != topicReportReview {
		t.Errorf("published = %v; a review nobody is told about is one nobody does", pub.topics)
	}
}

func TestUploadReport_UsesTheLabsColumnAliases(t *testing.T) {
	repo := newRepo()
	lab(repo, map[string]string{"p2o5": string(domain.AnalytePhosphorus)})
	svc, _ := newService(repo, &fakeSoil{})

	result, err := svc.UploadReport(tenantCtx("tenant-1"), "lab-1", domain.FormatCSV, "a.csv",
		[]byte("Field ID,P2O5\nfld-1,42\n"))
	if err != nil {
		t.Fatalf("upload: %v", err)
	}

	row := result.Report.Rows[0]
	if len(row.Results) != 1 || row.Results[0].Analyte != domain.AnalytePhosphorus {
		t.Errorf("the lab's alias was not applied: %+v", row.Results)
	}
}

func TestUploadReport_RefusesAnEmptyOrOversizeFile(t *testing.T) {
	repo := newRepo()
	lab(repo, nil)
	svc, _ := newService(repo, &fakeSoil{})
	ctx := tenantCtx("tenant-1")

	if _, err := svc.UploadReport(ctx, "lab-1", domain.FormatCSV, "a.csv", nil); !isBadRequest(err, "EMPTY_FILE") {
		t.Errorf("expected EMPTY_FILE, got %v", err)
	}

	huge := make([]byte, MaxUploadBytes+1)
	if _, err := svc.UploadReport(ctx, "lab-1", domain.FormatCSV, "a.csv", huge); !isBadRequest(err, "FILE_TOO_LARGE") {
		t.Errorf("expected FILE_TOO_LARGE, got %v", err)
	}
}

func TestUploadReport_RefusesAnUnknownFormat(t *testing.T) {
	repo := newRepo()
	lab(repo, nil)
	svc, _ := newService(repo, &fakeSoil{})

	if _, err := svc.UploadReport(tenantCtx("tenant-1"), "lab-1", "", "a.xlsx", []byte("x")); !isBadRequest(err, "UNSUPPORTED_FORMAT") {
		t.Fatalf("expected UNSUPPORTED_FORMAT, got %v", err)
	}
}

func TestRegisterLab_NormalisesAliasKeys(t *testing.T) {
	// Aliases are matched case-insensitively against the raw header, so they
	// are normalised once here rather than at every lookup.
	repo := newRepo()
	svc, _ := newService(repo, &fakeSoil{})

	created, err := svc.RegisterLab(tenantCtx("tenant-1"), &domain.Lab{
		Name:          "Deccan",
		ColumnAliases: map[string]string{"  P2O5  ": string(domain.AnalytePhosphorus)},
	})
	if err != nil {
		t.Fatalf("register: %v", err)
	}

	if _, ok := created.ColumnAliases["p2o5"]; !ok {
		t.Errorf("aliases = %v", created.ColumnAliases)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Apply
// ─────────────────────────────────────────────────────────────────────────────

func uploaded(t *testing.T, repo *fakeRepo, svc *soilLabService, csv string) *domain.LabReport {
	t.Helper()
	result, err := svc.UploadReport(tenantCtx("tenant-1"), "lab-1", domain.FormatCSV, "a.csv", []byte(csv))
	if err != nil {
		t.Fatalf("upload: %v", err)
	}
	return result.Report
}

func TestApplyReport_CreatesSamples(t *testing.T) {
	repo := newRepo()
	lab(repo, nil)
	soil := &fakeSoil{}
	svc, pub := newService(repo, soil)

	report := uploaded(t, repo, svc, goodCSV)

	result, err := svc.ApplyReport(tenantCtx("tenant-1"), report.ID, false)
	if err != nil {
		t.Fatalf("apply: %v", err)
	}

	if len(result.CreatedSampleIDs) != 2 {
		t.Errorf("created = %v, want 2", result.CreatedSampleIDs)
	}
	if result.Report.Status != domain.StatusApplied {
		t.Errorf("status = %s", result.Report.Status)
	}
	if len(soil.received) != 2 {
		t.Errorf("soil-service received %d samples", len(soil.received))
	}
	if len(pub.topics) == 0 || pub.topics[len(pub.topics)-1] != topicReportApplied {
		t.Errorf("published = %v", pub.topics)
	}
}

func TestApplyReport_RefusesAPartialImportUnlessAsked(t *testing.T) {
	// A partial import nobody chose leaves a field with results from half its
	// samples and no sign the rest are missing.
	repo := newRepo()
	lab(repo, nil)
	svc, _ := newService(repo, &fakeSoil{})

	report := uploaded(t, repo, svc, "Field ID,pH\nfld-1,6.8\n,7.1\n")

	_, err := svc.ApplyReport(tenantCtx("tenant-1"), report.ID, false)
	if !isBadRequest(err, "CANNOT_APPLY") {
		t.Fatalf("expected CANNOT_APPLY, got %v", err)
	}

	result, err := svc.ApplyReport(tenantCtx("tenant-1"), report.ID, true)
	if err != nil {
		t.Fatalf("skip_blocked apply: %v", err)
	}
	if len(result.CreatedSampleIDs) != 1 {
		t.Errorf("created = %v, want the one usable row", result.CreatedSampleIDs)
	}
}

func TestApplyReport_RefusesWhenSoilServiceIsNotConfigured(t *testing.T) {
	// A report recorded as applied with no samples behind it is worse than one
	// that failed loudly: nobody goes looking for results they have been told
	// are there.
	repo := newRepo()
	lab(repo, nil)
	// A true nil interface, not a typed nil pointer: see newService.
	svc, _ := newService(repo, nil)

	report := uploaded(t, repo, svc, goodCSV)

	_, err := svc.ApplyReport(tenantCtx("tenant-1"), report.ID, false)
	if err == nil {
		t.Fatal("a report was applied with no soil client")
	}
	if p9errors.Reason(err) != "SOIL_CLIENT_UNAVAILABLE" {
		t.Errorf("reason = %q", p9errors.Reason(err))
	}
	if report.Status == domain.StatusApplied {
		t.Error("the report was marked applied anyway")
	}
}

func TestApplyReport_RecordsAPartialFailure(t *testing.T) {
	// Re-applying the whole report afterwards would duplicate the samples that
	// did land, and a duplicated soil history is one nobody can reconcile.
	repo := newRepo()
	lab(repo, nil)
	soil := &fakeSoil{failAfter: 1}
	svc, _ := newService(repo, soil)

	report := uploaded(t, repo, svc, goodCSV)

	result, err := svc.ApplyReport(tenantCtx("tenant-1"), report.ID, false)
	if err == nil {
		t.Fatal("a partial write was reported as success")
	}

	if len(result.CreatedSampleIDs) != 1 {
		t.Errorf("created = %v; the ids that landed must come back", result.CreatedSampleIDs)
	}
	if repo.saved == nil {
		t.Fatal("the partial apply was not recorded")
	}
	if repo.saved.AppliedCount != 1 {
		t.Errorf("applied count = %d, want 1", repo.saved.AppliedCount)
	}
	if repo.saved.Status != domain.StatusNeedsReview {
		t.Errorf("status = %s; a half-applied report needs a person", repo.saved.Status)
	}
	if !strings.Contains(repo.saved.RejectionReason, "1 of 2") {
		t.Errorf("the record does not say how far it got: %q", repo.saved.RejectionReason)
	}
}

func TestApplyReport_RefusesToApplyTwice(t *testing.T) {
	repo := newRepo()
	lab(repo, nil)
	svc, _ := newService(repo, &fakeSoil{})

	report := uploaded(t, repo, svc, goodCSV)
	if _, err := svc.ApplyReport(tenantCtx("tenant-1"), report.ID, false); err != nil {
		t.Fatalf("first apply: %v", err)
	}

	if _, err := svc.ApplyReport(tenantCtx("tenant-1"), report.ID, false); !isBadRequest(err, "CANNOT_APPLY") {
		t.Fatalf("expected CANNOT_APPLY, got %v", err)
	}
}

func TestApplyReport_SuspectReadingsDoNotReachSoilService(t *testing.T) {
	// A prescription cannot tell a suspect number from a good one.
	repo := newRepo()
	lab(repo, nil)
	soil := &fakeSoil{}
	svc, _ := newService(repo, soil)

	report := uploaded(t, repo, svc, "Field ID,pH,P\nfld-1,6.8,4500\n")

	if _, err := svc.ApplyReport(tenantCtx("tenant-1"), report.ID, true); err != nil {
		t.Fatalf("apply: %v", err)
	}

	if len(soil.received) != 1 {
		t.Fatalf("soil-service received %d samples", len(soil.received))
	}
	if _, ok := soil.received[0].Values[domain.AnalytePhosphorus]; ok {
		t.Error("an implausible phosphorus reading reached soil-service")
	}
	if soil.received[0].Values[domain.AnalytePH] != 6.8 {
		t.Error("the good reading was lost")
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Reject
// ─────────────────────────────────────────────────────────────────────────────

func TestRejectReport_RequiresAReason(t *testing.T) {
	// A rejection with no reason leaves whoever sent the file with nothing to
	// fix.
	repo := newRepo()
	lab(repo, nil)
	svc, _ := newService(repo, &fakeSoil{})

	report := uploaded(t, repo, svc, goodCSV)

	if _, err := svc.RejectReport(tenantCtx("tenant-1"), report.ID, "  "); !isBadRequest(err, "MISSING_REASON") {
		t.Fatalf("expected MISSING_REASON, got %v", err)
	}
}

func TestRejectReport_RefusesAnAppliedReport(t *testing.T) {
	// Rejecting it now would not remove the samples it created.
	repo := newRepo()
	lab(repo, nil)
	svc, _ := newService(repo, &fakeSoil{})

	report := uploaded(t, repo, svc, goodCSV)
	if _, err := svc.ApplyReport(tenantCtx("tenant-1"), report.ID, false); err != nil {
		t.Fatalf("apply: %v", err)
	}

	_, err := svc.RejectReport(tenantCtx("tenant-1"), report.ID, "wrong field ids")
	if !isBadRequest(err, "ALREADY_APPLIED") {
		t.Fatalf("expected ALREADY_APPLIED, got %v", err)
	}
}

func TestRejectReport_Records(t *testing.T) {
	repo := newRepo()
	lab(repo, nil)
	svc, _ := newService(repo, &fakeSoil{})

	report := uploaded(t, repo, svc, goodCSV)

	rejected, err := svc.RejectReport(tenantCtx("tenant-1"), report.ID, "sent to the wrong farm")
	if err != nil {
		t.Fatalf("reject: %v", err)
	}
	if rejected.Status != domain.StatusRejected {
		t.Errorf("status = %s", rejected.Status)
	}
	if rejected.RejectionReason != "sent to the wrong farm" {
		t.Errorf("reason = %q", rejected.RejectionReason)
	}
}
