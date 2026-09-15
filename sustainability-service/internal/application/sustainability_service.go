// Package application holds sustainability-service's use cases.
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

	"p9e.in/samavaya/agriculture/sustainability-service/internal/domain"
	"p9e.in/samavaya/agriculture/sustainability-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/sustainability-service/internal/ports/outbound"
)

// Topics this service publishes on.
const (
	topicFootprintComputed = "yp.sustainability.footprint.computed"
	topicProhibitedInput   = "yp.sustainability.certification.prohibited_input"
)

type sustainabilityService struct {
	inputs     outbound.InputRepository
	footprints outbound.FootprintRepository
	pub        outbound.EventPublisher
	log        *p9log.Helper
	now        func() time.Time
}

// NewSustainabilityService creates the sustainability service.
func NewSustainabilityService(
	inputs outbound.InputRepository,
	footprints outbound.FootprintRepository,
	pub outbound.EventPublisher,
	log p9log.Logger,
) inbound.SustainabilityService {
	return &sustainabilityService{
		inputs:     inputs,
		footprints: footprints,
		pub:        pub,
		log:        p9log.NewHelper(p9log.With(log, "component", "SustainabilityService")),
		now:        time.Now,
	}
}

// RecordInputUse stores one application to a field.
//
// The nitrogen content and the organic verdict are worked out here and stored
// with the record rather than derived on read. Both depend on lists that
// change — fertiliser formulations and the certifier's permitted inputs — and
// a certificate has to be defensible against the rules that applied on the day,
// not against today's.
func (s *sustainabilityService) RecordInputUse(ctx context.Context, in *domain.InputUse) (*domain.InputUse, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if in.Year == 0 {
		in.Year = s.now().Year()
	}
	if err := in.Validate(); err != nil {
		return nil, errors.BadRequest("INVALID_INPUT", err.Error())
	}

	in.ID = ulid.NewString()
	in.TenantID = tenantID
	in.CreatedAt = s.now()
	if in.AppliedBy == "" {
		in.AppliedBy = actor(ctx)
	}
	if in.Unit == "" {
		in.Unit = domain.DefaultUnit(in.Category)
	}

	// A caller-supplied figure wins: the farmer holding the bag knows its
	// analysis better than a lookup table does.
	if in.NitrogenKg == 0 {
		nitrogen, known := domain.DeriveNitrogen(in.Category, in.Product, in.Quantity)
		if known {
			in.NitrogenKg = nitrogen
		} else {
			// Left at zero and said out loud. A guessed nitrogen fraction would
			// propagate into the N2O line, which is usually the largest number
			// on a non-rice footprint, and nothing downstream could tell it
			// apart from a measured one.
			s.log.Infow("msg", "nitrogen content is unknown for this product",
				"product", in.Product, "category", in.Category)
			in.Notes = appendNote(in.Notes, fmt.Sprintf(
				"nitrogen content is not known for %q; the N2O figures in any "+
					"footprint that includes this application will be understated",
				in.Product))
		}
	}

	permitted, reason := domain.IsOrganicPermitted(in.Category, in.Product)
	in.OrganicPermitted = permitted

	created, err := s.inputs.CreateInput(ctx, in)
	if err != nil {
		return nil, err
	}

	// Announced as it happens, not only when somebody runs a certification
	// check. A prohibited input restarts a three-year conversion period, and
	// finding that out at the next audit is two and a half years too late.
	if !permitted {
		s.publish(ctx, topicProhibitedInput, created.ID, map[string]any{
			"tenant_id":  tenantID,
			"input_id":   created.ID,
			"field_id":   created.FieldID,
			"product":    created.Product,
			"category":   created.Category,
			"applied_on": created.AppliedOn,
			"reason":     reason,
		})
	}

	return created, nil
}

func (s *sustainabilityService) ListInputUse(ctx context.Context, params domain.ListInputUseParams) ([]domain.InputUse, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	params.TenantID = tenantID
	params.Limit = clampLimit(params.Limit)
	return s.inputs.ListInputs(ctx, params)
}

// ComputeFootprint accounts for a field-year and stores the result.
func (s *sustainabilityService) ComputeFootprint(ctx context.Context, params domain.FootprintParams) (*domain.Footprint, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(params.FieldID) == "" {
		return nil, errors.BadRequest("MISSING_FIELD", domain.ErrMissingField.Error())
	}
	if params.AreaHectares <= 0 {
		return nil, errors.BadRequest("INVALID_AREA", domain.ErrInvalidArea.Error())
	}
	if params.Year == 0 {
		params.Year = s.now().Year()
	}

	// Every application for the year, not a page of them. A footprint computed
	// from the first fifty rows and a certification check that missed the urea
	// in row fifty-one would both look like answers.
	inputs, err := s.inputs.AllInputs(ctx, domain.ListInputUseParams{
		TenantID: tenantID,
		FieldID:  params.FieldID,
		Year:     params.Year,
	})
	if err != nil {
		return nil, err
	}

	footprint, err := domain.ComputeFootprint(params, inputs)
	if err != nil {
		return nil, errors.BadRequest("CANNOT_COMPUTE", err.Error())
	}
	footprint.ID = ulid.NewString()
	footprint.TenantID = tenantID
	footprint.ComputedAt = s.now()

	saved, err := s.footprints.SaveFootprint(ctx, &footprint)
	if err != nil {
		return nil, err
	}

	s.publish(ctx, topicFootprintComputed, saved.ID, map[string]any{
		"tenant_id":      tenantID,
		"footprint_id":   saved.ID,
		"field_id":       saved.FieldID,
		"year":           saved.Year,
		"crop":           saved.Crop,
		"total_kg_co2e":  saved.TotalKgCO2e,
		"kg_co2e_per_ha": saved.KgCO2ePerHa,
		// Carried into the event so a downstream consumer cannot present the
		// total as a finished number without knowing what is behind it.
		"complete":        saved.Complete,
		"missing_sources": saved.MissingSources,
	})

	return saved, nil
}

func (s *sustainabilityService) GetFootprint(ctx context.Context, id string) (*domain.Footprint, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(id) == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}
	return s.footprints.GetFootprint(ctx, id, tenantID)
}

func (s *sustainabilityService) ListFootprints(ctx context.Context, params domain.ListFootprintsParams) ([]domain.Footprint, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	params.TenantID = tenantID
	params.Limit = clampLimit(params.Limit)
	return s.footprints.ListFootprints(ctx, params)
}

// CheckCertification assesses a field against a standard.
func (s *sustainabilityService) CheckCertification(
	ctx context.Context,
	fieldID string,
	standard domain.CertificationStandard,
	conversionStartedOn time.Time,
) (domain.CertificationCheck, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return domain.CertificationCheck{}, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(fieldID) == "" {
		return domain.CertificationCheck{}, errors.BadRequest("MISSING_FIELD", domain.ErrMissingField.Error())
	}
	if standard == "" {
		return domain.CertificationCheck{}, errors.BadRequest("MISSING_STANDARD",
			"a certification standard is required; the rules differ enough between "+
				"them that there is no sensible default")
	}

	inputs, err := s.inputs.AllInputs(ctx, domain.ListInputUseParams{
		TenantID: tenantID,
		FieldID:  fieldID,
	})
	if err != nil {
		return domain.CertificationCheck{}, err
	}

	return domain.CheckCertification(standard, fieldID, conversionStartedOn, inputs, s.now()), nil
}

// ExportCertificationPack renders the evidence an auditor reads.
//
// A pack that would not pass is refused unless the caller explicitly asks for
// it. The file looks like a certificate whatever it says inside, and one
// handed over without that being a deliberate choice ends up attached to an
// email that claims more than the records support.
func (s *sustainabilityService) ExportCertificationPack(
	ctx context.Context,
	fieldID string,
	standard domain.CertificationStandard,
	conversionStartedOn time.Time,
	allowIncomplete bool,
) (inbound.ExportPack, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return inbound.ExportPack{}, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}

	check, err := s.CheckCertification(ctx, fieldID, standard, conversionStartedOn)
	if err != nil {
		return inbound.ExportPack{}, err
	}

	if check.Status != domain.StatusEligible && !allowIncomplete {
		return inbound.ExportPack{Check: check}, errors.BadRequest("NOT_ELIGIBLE", fmt.Sprintf(
			"this field is %s against %s, so the pack has not been generated. %s "+
				"Set allow_incomplete to export it anyway as a working document.",
			strings.ToLower(strings.ReplaceAll(string(check.Status), "_", " ")),
			standard, check.Summary))
	}

	inputs, err := s.inputs.AllInputs(ctx, domain.ListInputUseParams{
		TenantID: tenantID,
		FieldID:  fieldID,
	})
	if err != nil {
		return inbound.ExportPack{}, err
	}

	content, err := domain.ExportPack(check, inputs)
	if err != nil {
		s.log.Errorw("msg", "could not render the certification pack",
			"field", fieldID, "standard", standard, "error", err)
		return inbound.ExportPack{}, errors.InternalServer("EXPORT_FAILED", "an internal error occurred")
	}

	return inbound.ExportPack{
		Filename:    domain.ExportFilename(check, s.now()),
		Content:     content,
		ContentType: "text/csv",
		Check:       check,
	}, nil
}

func (s *sustainabilityService) publish(ctx context.Context, topic, key string, payload map[string]any) {
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

func appendNote(existing, note string) string {
	if strings.TrimSpace(existing) == "" {
		return note
	}
	return existing + "; " + note
}

func actor(ctx context.Context) string {
	if user := p9context.UserID(ctx); user != "" {
		return user
	}
	return "system"
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
