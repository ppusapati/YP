package services

import (
	"context"
	"testing"

	"go.uber.org/zap"

	pb "p9e.in/samavaya/agriculture/agronomy-service/api/v1"
	"p9e.in/samavaya/agriculture/agronomy-service/internal/repositories"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
)

// A repository that remembers what it was asked to do.
type fakeInspectionRepo struct {
	existing *pb.Inspection

	updated     *pb.Inspection
	baseVersion int64
	nextVersion int64
	updateErr   error
	getErr      error
}

func (f *fakeInspectionRepo) GetByID(_ context.Context, _ string) (*pb.Inspection, error) {
	if f.getErr != nil {
		return nil, f.getErr
	}
	return f.existing, nil
}

func (f *fakeInspectionRepo) List(_ context.Context, _ repositories.InspectionListParams) ([]*pb.Inspection, string, int32, error) {
	return nil, "", 0, nil
}

func (f *fakeInspectionRepo) Create(_ context.Context, in *pb.Inspection) (*pb.Inspection, error) {
	return in, nil
}

func (f *fakeInspectionRepo) UpdateStatus(_ context.Context, _ string, _ string) (*pb.Inspection, error) {
	return f.existing, nil
}

func (f *fakeInspectionRepo) Update(_ context.Context, in *pb.Inspection, baseVersion int64) (*pb.Inspection, int64, error) {
	f.updated = in
	f.baseVersion = baseVersion
	if f.updateErr != nil {
		return nil, 0, f.updateErr
	}
	return in, f.nextVersion, nil
}

func newTestService(repo repositories.InspectionRepository) InspectionService {
	d := deps.ServiceDeps{Log: p9log.NewLogger(zap.NewNop())}
	return NewInspectionService(d, repo, nil)
}

func draft() *pb.Inspection {
	return &pb.Inspection{
		Id:     "insp-1",
		Status: pb.InspectionStatus_INSPECTION_STATUS_DRAFT,
	}
}

func TestUpdateInspection_EditsADraft(t *testing.T) {
	repo := &fakeInspectionRepo{existing: draft(), nextVersion: 2}
	svc := newTestService(repo)

	got, version, err := svc.UpdateInspection(context.Background(), &pb.UpdateInspectionRequest{
		Id:          "insp-1",
		Findings:    "Leaf curl on the north headland.",
		HealthScore: 62.5,
		BaseVersion: 1,
	})
	if err != nil {
		t.Fatalf("update: %v", err)
	}

	if got.Findings != "Leaf curl on the north headland." {
		t.Errorf("findings were not written: %q", got.Findings)
	}
	if version != 2 {
		t.Errorf("version = %d, want 2", version)
	}
	if repo.baseVersion != 1 {
		t.Errorf("the base version was not passed to the repository: %d", repo.baseVersion)
	}
}

func TestUpdateInspection_RefusesASubmittedInspection(t *testing.T) {
	// A submitted inspection is a record of what an agronomist found on a
	// date. Editing it afterwards rewrites the history a prescription or an
	// insurance claim was built on; a wrong one is corrected by filing another.
	submitted := draft()
	submitted.Status = pb.InspectionStatus_INSPECTION_STATUS_SUBMITTED
	repo := &fakeInspectionRepo{existing: submitted}
	svc := newTestService(repo)

	_, _, err := svc.UpdateInspection(context.Background(), &pb.UpdateInspectionRequest{
		Id:       "insp-1",
		Findings: "rewriting history",
	})
	if err == nil {
		t.Fatal("a submitted inspection was edited")
	}
	if errors.Reason(err) != "INVALID_STATUS" {
		t.Errorf("reason = %q, want INVALID_STATUS", errors.Reason(err))
	}
	if repo.updated != nil {
		t.Error("the repository was asked to write anyway")
	}
}

func TestUpdateInspection_RefusesAReviewedInspection(t *testing.T) {
	reviewed := draft()
	reviewed.Status = pb.InspectionStatus_INSPECTION_STATUS_REVIEWED
	svc := newTestService(&fakeInspectionRepo{existing: reviewed})

	if _, _, err := svc.UpdateInspection(context.Background(), &pb.UpdateInspectionRequest{
		Id: "insp-1",
	}); err == nil {
		t.Fatal("a reviewed inspection was edited")
	}
}

func TestUpdateInspection_RequiresAnID(t *testing.T) {
	svc := newTestService(&fakeInspectionRepo{existing: draft()})

	_, _, err := svc.UpdateInspection(context.Background(), &pb.UpdateInspectionRequest{Id: "  "})
	if err == nil {
		t.Fatal("an update with no id was accepted")
	}
	if errors.Reason(err) != "INVALID_ID" {
		t.Errorf("reason = %q, want INVALID_ID", errors.Reason(err))
	}
}

func TestUpdateInspection_PassesAZeroBaseThrough(t *testing.T) {
	// Zero means "I did not check", which is accepted: a single agronomist
	// correcting a typo should not have to participate in the versioning.
	repo := &fakeInspectionRepo{existing: draft(), nextVersion: 2}
	svc := newTestService(repo)

	if _, _, err := svc.UpdateInspection(context.Background(), &pb.UpdateInspectionRequest{
		Id:          "insp-1",
		BaseVersion: 0,
	}); err != nil {
		t.Fatalf("update: %v", err)
	}
	if repo.baseVersion != 0 {
		t.Errorf("base version = %d, want 0", repo.baseVersion)
	}
}

func TestUpdateInspection_SurfacesAVersionConflict(t *testing.T) {
	// The caller has to be able to tell "somebody edited this" from "this
	// failed", because only the first is worth showing them a diff for.
	repo := &fakeInspectionRepo{
		existing:  draft(),
		updateErr: repositories.ErrInspectionVersionConflict,
	}
	svc := newTestService(repo)

	_, _, err := svc.UpdateInspection(context.Background(), &pb.UpdateInspectionRequest{
		Id:          "insp-1",
		BaseVersion: 1,
	})
	if err == nil {
		t.Fatal("a conflicting update was reported as success")
	}
	if errors.Reason(err) != "INSPECTION_VERSION_CONFLICT" {
		t.Errorf("reason = %q, want INSPECTION_VERSION_CONFLICT", errors.Reason(err))
	}
}

func TestUpdateInspection_DoesNotWriteWhenTheInspectionIsMissing(t *testing.T) {
	repo := &fakeInspectionRepo{
		getErr: errors.NotFound("INSPECTION_NOT_FOUND", "gone"),
	}
	svc := newTestService(repo)

	if _, _, err := svc.UpdateInspection(context.Background(), &pb.UpdateInspectionRequest{
		Id: "insp-1",
	}); err == nil {
		t.Fatal("an update to a missing inspection succeeded")
	}
	if repo.updated != nil {
		t.Error("the repository was asked to write a missing inspection")
	}
}

func TestUpdateInspection_CarriesEveryEditableField(t *testing.T) {
	// A field the service forgets to copy is silently reverted on every save,
	// which looks to the editor like their change did not stick.
	repo := &fakeInspectionRepo{existing: draft(), nextVersion: 2}
	svc := newTestService(repo)

	_, _, err := svc.UpdateInspection(context.Background(), &pb.UpdateInspectionRequest{
		Id:              "insp-1",
		Findings:        "findings",
		Notes:           "notes",
		HealthScore:     41.5,
		Photos:          []string{"https://example.test/a.jpg"},
		Recommendations: []string{"Scout again in a week."},
		Issues: []*pb.InspectionIssue{
			{Description: "Aphids", Severity: pb.IssueSeverity_ISSUE_SEVERITY_MEDIUM},
		},
		BaseVersion: 1,
	})
	if err != nil {
		t.Fatalf("update: %v", err)
	}

	got := repo.updated
	if got.Findings != "findings" || got.Notes != "notes" {
		t.Errorf("text fields lost: %+v", got)
	}
	if got.HealthScore != 41.5 {
		t.Errorf("health score = %v, want 41.5", got.HealthScore)
	}
	if len(got.Photos) != 1 || len(got.Recommendations) != 1 || len(got.Issues) != 1 {
		t.Errorf("list fields lost: %+v", got)
	}
}
