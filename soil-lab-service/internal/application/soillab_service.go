// Package application holds soil-lab-service's use cases.
package application

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/soil-lab-service/internal/domain"
	"p9e.in/samavaya/agriculture/soil-lab-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/soil-lab-service/internal/ports/outbound"
)

// Topics this service publishes on.
const (
	topicReportApplied = "yp.soillab.report.applied"
	topicReportReview  = "yp.soillab.report.needs_review"
)

// MaxUploadBytes caps one report.
//
// 25 MB: generous for a scanned PDF of a multi-page report, small enough that
// a mis-addressed upload cannot fill the blob store.
const MaxUploadBytes = 25 << 20

type soilLabService struct {
	repo  outbound.LabRepository
	soil  outbound.SoilClient
	blobs outbound.BlobStore
	pub   outbound.EventPublisher
	log   *p9log.Helper
	now   func() time.Time
}

// NewSoilLabService creates the soil lab service.
func NewSoilLabService(
	repo outbound.LabRepository,
	soil outbound.SoilClient,
	blobs outbound.BlobStore,
	pub outbound.EventPublisher,
	log p9log.Logger,
) inbound.SoilLabService {
	return &soilLabService{
		repo:  repo,
		soil:  soil,
		blobs: blobs,
		pub:   pub,
		log:   p9log.NewHelper(p9log.With(log, "component", "SoilLabService")),
		now:   time.Now,
	}
}

func (s *soilLabService) RegisterLab(ctx context.Context, lab *domain.Lab) (*domain.Lab, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(lab.Name) == "" {
		return nil, errors.BadRequest("MISSING_NAME", "the lab's name is required")
	}

	lab.ID = ulid.NewString()
	lab.TenantID = tenantID
	lab.CreatedAt = s.now()
	if lab.ColumnAliases == nil {
		lab.ColumnAliases = map[string]string{}
	}
	// Aliases are matched case-insensitively against the raw header, so they
	// are normalised on the way in rather than at every lookup.
	normalised := make(map[string]string, len(lab.ColumnAliases))
	for header, analyte := range lab.ColumnAliases {
		normalised[strings.ToLower(strings.TrimSpace(header))] = analyte
	}
	lab.ColumnAliases = normalised

	return s.repo.CreateLab(ctx, lab)
}

func (s *soilLabService) ListLabs(ctx context.Context, params domain.ListLabsParams) ([]domain.Lab, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	params.TenantID = tenantID
	params.Limit = clampLimit(params.Limit)
	return s.repo.ListLabs(ctx, params)
}

// UploadReport stores a lab file and, for a CSV, parses it.
//
// The file is kept whatever happens to the parse: a lab report is the evidence
// behind a fertiliser decision, and a PDF is not parsed at all — it exists for
// a person to read. Extracting numbers from a lab's PDF layout is OCR
// guesswork, and a mis-read potassium figure drives a prescription.
func (s *soilLabService) UploadReport(
	ctx context.Context,
	labID string,
	format domain.ReportFormat,
	filename string,
	content []byte,
) (inbound.UploadResult, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return inbound.UploadResult{}, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if len(content) == 0 {
		return inbound.UploadResult{}, errors.BadRequest("EMPTY_FILE", "the uploaded file is empty")
	}
	if len(content) > MaxUploadBytes {
		return inbound.UploadResult{}, errors.BadRequest("FILE_TOO_LARGE",
			fmt.Sprintf("the file is %d MB; the limit is %d MB", len(content)>>20, MaxUploadBytes>>20))
	}

	lab, err := s.repo.GetLab(ctx, labID, tenantID)
	if err != nil {
		return inbound.UploadResult{}, err
	}

	hash := domain.HashContent(content)

	// The same results arrive again as "results (1).csv" more often than not.
	// Returning the existing report is the difference between one soil history
	// and three.
	if existing, err := s.repo.FindByContentHash(ctx, hash, tenantID); err == nil && existing != nil {
		return inbound.UploadResult{Report: existing, Duplicate: true}, nil
	}

	report := &domain.LabReport{
		ID:            ulid.NewString(),
		TenantID:      tenantID,
		LabID:         lab.ID,
		LabName:       lab.Name,
		Format:        format,
		Filename:      filename,
		ContentSHA256: hash,
		Status:        domain.StatusReceived,
		UploadedAt:    s.now(),
		UploadedBy:    actor(ctx),
	}

	// Stored before parsing, so a file that fails to parse is still on record
	// — that is exactly the file somebody needs to look at.
	if s.blobs != nil {
		url, err := s.blobs.Put(ctx, blobKey(tenantID, report.ID, filename), content, contentType(format))
		if err != nil {
			s.log.Warnw("msg", "could not store the report file", "report", report.ID, "error", err)
		} else {
			report.StorageURL = url
		}
	}

	switch format {
	case domain.FormatCSV:
		rows, err := domain.ParseCSV(content, lab.ColumnAliases, s.now())
		if err != nil {
			// A file-level failure is a rejection with the reason, not a
			// dropped upload: the person who sent it needs to know why.
			report.Status = domain.StatusRejected
			report.RejectionReason = err.Error()
			created, saveErr := s.repo.CreateReport(ctx, report)
			if saveErr != nil {
				return inbound.UploadResult{}, saveErr
			}
			return inbound.UploadResult{Report: created}, nil
		}
		report.Rows = rows
		report.Summarise()

	case domain.FormatPDF:
		// Stored, not parsed. Left at RECEIVED so it shows up as awaiting a
		// person rather than as something the service has dealt with.
		report.Status = domain.StatusReceived

	default:
		return inbound.UploadResult{}, errors.BadRequest("UNSUPPORTED_FORMAT", domain.ErrUnsupportedFormat.Error())
	}

	created, err := s.repo.CreateReport(ctx, report)
	if err != nil {
		return inbound.UploadResult{}, err
	}

	if created.Status == domain.StatusNeedsReview {
		s.publish(ctx, topicReportReview, created.ID, map[string]any{
			"tenant_id":     tenantID,
			"report_id":     created.ID,
			"lab_id":        created.LabID,
			"row_count":     created.RowCount,
			"blocked_count": created.BlockedCount,
		})
	}

	return inbound.UploadResult{Report: created}, nil
}

func (s *soilLabService) GetReport(ctx context.Context, id string) (*domain.LabReport, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(id) == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}
	return s.repo.GetReport(ctx, id, tenantID)
}

func (s *soilLabService) ListReports(ctx context.Context, params domain.ListReportsParams) ([]domain.LabReport, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	params.TenantID = tenantID
	params.Limit = clampLimit(params.Limit)
	return s.repo.ListReports(ctx, params)
}

// ApplyReport pushes a report's usable rows into soil-service.
func (s *soilLabService) ApplyReport(ctx context.Context, id string, skipBlocked bool) (inbound.ApplyResult, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return inbound.ApplyResult{}, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}

	report, err := s.repo.GetReport(ctx, id, tenantID)
	if err != nil {
		return inbound.ApplyResult{}, err
	}
	if err := report.CanApply(skipBlocked); err != nil {
		return inbound.ApplyResult{}, errors.BadRequest("CANNOT_APPLY", err.Error())
	}
	if s.soil == nil {
		// Refused rather than marked applied. A report recorded as applied
		// with no samples behind it is worse than one that failed loudly:
		// nobody goes looking for results they have been told are there.
		return inbound.ApplyResult{}, errors.InternalServer("SOIL_CLIENT_UNAVAILABLE",
			"soil-service is not configured; the report has not been applied")
	}

	usable := report.UsableRows()
	samples := make([]domain.SoilSample, 0, len(usable))
	for _, row := range usable {
		samples = append(samples, row.ToSoilSample(report.LabName))
	}

	createdIDs, err := s.soil.CreateSamples(ctx, samples)

	// createdIDs is recorded even on a partial failure. Re-applying the whole
	// report afterwards would duplicate the samples that did land, and a
	// duplicated soil history is one nobody can reconcile.
	report.AppliedCount = len(createdIDs)
	if err != nil {
		if len(createdIDs) > 0 {
			report.Status = domain.StatusNeedsReview
			report.RejectionReason = fmt.Sprintf(
				"%d of %d samples were created before the write failed: %v",
				len(createdIDs), len(samples), err)
			if saveErr := s.repo.SaveReport(ctx, report); saveErr != nil {
				s.log.Errorw("msg", "could not record a partial apply", "report", id, "error", saveErr)
			}
		}
		return inbound.ApplyResult{Report: report, CreatedSampleIDs: createdIDs}, err
	}

	at := s.now()
	report.Status = domain.StatusApplied
	report.AppliedAt = &at
	if err := s.repo.SaveReport(ctx, report); err != nil {
		return inbound.ApplyResult{}, err
	}

	s.publish(ctx, topicReportApplied, report.ID, map[string]any{
		"tenant_id":     tenantID,
		"report_id":     report.ID,
		"lab_id":        report.LabID,
		"applied_count": report.AppliedCount,
		"blocked_count": report.BlockedCount,
		"sample_ids":    createdIDs,
	})

	return inbound.ApplyResult{Report: report, CreatedSampleIDs: createdIDs}, nil
}

func (s *soilLabService) RejectReport(ctx context.Context, id, reason string) (*domain.LabReport, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(reason) == "" {
		// A rejection with no reason leaves whoever sent the file with nothing
		// to fix.
		return nil, errors.BadRequest("MISSING_REASON", "a reason is required to reject a report")
	}

	report, err := s.repo.GetReport(ctx, id, tenantID)
	if err != nil {
		return nil, err
	}
	if report.Status == domain.StatusApplied {
		return nil, errors.BadRequest("ALREADY_APPLIED",
			"this report's samples are already in soil-service; rejecting it now would not remove them")
	}

	report.Status = domain.StatusRejected
	report.RejectionReason = reason
	if err := s.repo.SaveReport(ctx, report); err != nil {
		return nil, err
	}
	return report, nil
}

func (s *soilLabService) publish(ctx context.Context, topic, key string, payload map[string]any) {
	if s.pub == nil {
		return
	}
	body, err := json.Marshal(payload)
	if err != nil {
		s.log.Errorw("msg", "could not encode event", "topic", topic, "error", err)
		return
	}
	if err := s.pub.Publish(ctx, topic, key, body); err != nil {
		s.log.Warnw("msg", "could not publish event", "topic", topic, "error", err)
	}
}

func actor(ctx context.Context) string {
	if user := p9context.UserID(ctx); user != "" {
		return user
	}
	return "system"
}

func blobKey(tenantID, reportID, filename string) string {
	return fmt.Sprintf("soil-lab/%s/%s/%s", tenantID, reportID, filename)
}

func contentType(format domain.ReportFormat) string {
	if format == domain.FormatPDF {
		return "application/pdf"
	}
	return "text/csv"
}

func clampLimit(limit int) int {
	switch {
	case limit <= 0:
		return 50
	case limit > 500:
		return 500
	default:
		return limit
	}
}
