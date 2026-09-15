// Package application holds planning-service's use cases.
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

	"p9e.in/samavaya/agriculture/planning-service/internal/domain"
	"p9e.in/samavaya/agriculture/planning-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/planning-service/internal/ports/outbound"
)

// Topics this service publishes on.
const (
	topicPlanCreated   = "yp.planning.plan.created"
	topicPlanCommitted = "yp.planning.plan.committed"
)

type planningService struct {
	repo    outbound.PlanRepository
	weather outbound.WeatherClient
	pub     outbound.EventPublisher
	log     *p9log.Helper
	now     func() time.Time
}

// NewPlanningService creates the planning service.
func NewPlanningService(
	repo outbound.PlanRepository,
	weather outbound.WeatherClient,
	pub outbound.EventPublisher,
	log p9log.Logger,
) inbound.PlanningService {
	return &planningService{
		repo:    repo,
		weather: weather,
		pub:     pub,
		log:     p9log.NewHelper(p9log.With(log, "component", "PlanningService")),
		now:     time.Now,
	}
}

// CreatePlan works out the agronomy and stores the plan.
//
// The three derived pieces are computed here rather than left to the caller,
// because they depend on each other: the rotation check finds the previous
// crop's nitrogen credit, and that credit is what the budget subtracts from
// the fertiliser line. A client that filled them in separately would have to
// know that ordering, and would get it wrong in the direction of buying urea
// the field does not need.
func (s *planningService) CreatePlan(ctx context.Context, p *domain.SeasonPlan) (*domain.SeasonPlan, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if err := p.Validate(); err != nil {
		return nil, errors.BadRequest("INVALID_PLAN", err.Error())
	}

	// Refused by name rather than planned with defaults. Everything below —
	// the window, the rotation family, the nitrogen demand — comes out of the
	// crop calendar, and a plan built for a crop that is not in it would be a
	// confident answer assembled from zeroes.
	profile, ok := domain.LookupCrop(p.Crop)
	if !ok {
		return nil, errors.BadRequest("UNKNOWN_CROP", fmt.Sprintf(
			"%q is not in the crop calendar, so a sowing window and input budget "+
				"cannot be worked out for it. Known crops: %s",
			p.Crop, strings.Join(domain.KnownCrops(), ", ")))
	}
	if !profile.GrownIn(p.Season) {
		return nil, errors.BadRequest("SEASON_MISMATCH", fmt.Sprintf(
			"%s is grown in %v, not %s", profile.Name, profile.Seasons, p.Season))
	}

	p.ID = ulid.NewString()
	p.TenantID = tenantID
	p.Crop = profile.Name
	p.Status = domain.PlanDraft
	p.CreatedBy = actor(ctx)
	p.CreatedAt = s.now()
	p.UpdatedAt = p.CreatedAt
	p.Version = 1

	if err := s.derive(ctx, p); err != nil {
		return nil, err
	}

	created, err := s.repo.CreatePlan(ctx, p)
	if err != nil {
		return nil, err
	}

	s.publish(ctx, topicPlanCreated, created.ID, map[string]any{
		"tenant_id":        tenantID,
		"plan_id":          created.ID,
		"field_id":         created.FieldID,
		"crop":             created.Crop,
		"season":           created.Season,
		"year":             created.Year,
		"area_hectares":    created.AreaHectares,
		"rotation_verdict": created.RotationCheck.Verdict,
	})

	return created, nil
}

// derive fills in the sowing window, rotation check and budget.
//
// Shared by create and update so an edited crop or area does not leave a plan
// carrying the previous crop's window and the previous area's costs — which is
// exactly the kind of stale figure somebody orders seed against.
func (s *planningService) derive(ctx context.Context, p *domain.SeasonPlan) error {
	previous, err := s.previousCrop(ctx, p.TenantID, p.FieldID, p.Year, p.Season)
	if err != nil {
		return err
	}
	p.RotationCheck = domain.CheckRotation(p.Crop, previous)

	window, err := domain.ComputeSowingWindow(p.Crop, p.Season, p.Year, s.monsoonOnset(ctx, p.FieldID))
	if err != nil {
		return errors.BadRequest("NO_SOWING_WINDOW", err.Error())
	}
	p.SowingWindow = window

	budget, err := domain.BuildBudget(p.Crop, p.AreaHectares, p.RotationCheck.NitrogenCreditKgHa)
	if err != nil {
		return errors.BadRequest("NO_BUDGET", err.Error())
	}
	p.Budget = budget

	return nil
}

// previousCrop looks up what the field last grew.
//
// A lookup failure is logged and treated as "no history" rather than failing
// the plan. The rotation check already says "unverified" for a missing
// previous crop, and refusing to plan at all because a history query timed out
// would block the season over a detail the farmer can check themselves.
func (s *planningService) previousCrop(ctx context.Context, tenantID, fieldID string, year int, season domain.Season) (string, error) {
	crop, err := s.repo.PreviousCrop(ctx, tenantID, fieldID, year, season)
	if err != nil {
		s.log.Warnw("msg", "could not read the field's cropping history",
			"field", fieldID, "error", err)
		return "", nil
	}
	return crop, nil
}

// monsoonOnset asks weather-service when the rains arrive at this field.
//
// Returns nil on any failure, which the domain reads as "use the crop
// calendar" and says so in the window's basis. A planner that refused to
// produce a window because weather-service was down would be less useful than
// the printed calendar it replaced.
func (s *planningService) monsoonOnset(ctx context.Context, fieldID string) *domain.MonsoonOnset {
	if s.weather == nil {
		return nil
	}
	onset, err := s.weather.MonsoonOnset(ctx, fieldID)
	if err != nil {
		s.log.Infow("msg", "no rainfall history for this field; using the crop calendar",
			"field", fieldID, "error", err)
		return nil
	}
	return onset
}

func (s *planningService) GetPlan(ctx context.Context, id string) (*domain.SeasonPlan, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(id) == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}
	return s.repo.GetPlan(ctx, id, tenantID)
}

func (s *planningService) ListPlans(ctx context.Context, params domain.ListPlansParams) ([]domain.SeasonPlan, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	params.TenantID = tenantID
	params.Limit = clampLimit(params.Limit)
	return s.repo.ListPlans(ctx, params)
}

// UpdatePlan changes a draft plan and recomputes what depends on the change.
func (s *planningService) UpdatePlan(ctx context.Context, p *domain.SeasonPlan, baseVersion int64) (*domain.SeasonPlan, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(p.ID) == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	existing, err := s.repo.GetPlan(ctx, p.ID, tenantID)
	if err != nil {
		return nil, err
	}
	if !existing.Editable() {
		// Once a plan is committed the seed is ordered and the labour booked
		// against it. Editing it afterwards would make the record disagree with
		// what was actually bought; a new plan supersedes it instead.
		return nil, errors.BadRequest("NOT_DRAFT", fmt.Sprintf(
			"this plan is %s, and %s", strings.ToLower(string(existing.Status)),
			domain.ErrNotDraft.Error()))
	}

	// Which field, which season and which year are the plan's identity — they
	// are what the one-plan-per-field-per-season constraint is on. Changing
	// them would silently move the plan onto other ground; that is a new plan,
	// so they come from the stored row rather than from the request.
	p.FieldID = existing.FieldID
	p.FarmID = existing.FarmID
	p.Season = existing.Season
	p.Year = existing.Year

	if err := p.Validate(); err != nil {
		return nil, errors.BadRequest("INVALID_PLAN", err.Error())
	}
	profile, ok := domain.LookupCrop(p.Crop)
	if !ok {
		return nil, errors.BadRequest("UNKNOWN_CROP", fmt.Sprintf(
			"%q is not in the crop calendar", p.Crop))
	}
	if !profile.GrownIn(p.Season) {
		return nil, errors.BadRequest("SEASON_MISMATCH", fmt.Sprintf(
			"%s is grown in %v, not %s", profile.Name, profile.Seasons, p.Season))
	}

	// Identity and provenance stay with the stored plan; only the planning
	// fields are the caller's to change.
	p.TenantID = tenantID
	p.Crop = profile.Name
	p.Status = existing.Status
	p.CreatedBy = existing.CreatedBy
	p.CreatedAt = existing.CreatedAt
	p.UpdatedAt = s.now()

	if err := s.derive(ctx, p); err != nil {
		return nil, err
	}

	updated, err := s.repo.UpdatePlan(ctx, p, baseVersion)
	if err != nil {
		return nil, err
	}
	return updated, nil
}

// CommitPlan moves a draft to committed.
func (s *planningService) CommitPlan(ctx context.Context, id string) (*domain.SeasonPlan, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}

	existing, err := s.repo.GetPlan(ctx, id, tenantID)
	if err != nil {
		return nil, err
	}
	if existing.Status == domain.PlanCommitted {
		// Already where the caller wants it. Returning it rather than erroring
		// makes a retried commit harmless.
		return existing, nil
	}
	if !existing.Editable() {
		return nil, errors.BadRequest("NOT_DRAFT", fmt.Sprintf(
			"this plan is %s and cannot be committed", strings.ToLower(string(existing.Status))))
	}

	// A poor rotation is a warning, not a refusal. The farmer may have a reason
	// — a contract, a seed they already hold — and a planner that blocked the
	// season over an advisory would be worked around rather than heeded. It is
	// carried into the event so whoever is watching knows what was committed.
	if existing.RotationCheck.Verdict == domain.RotationPoor {
		s.log.Warnw("msg", "a plan with a poor rotation was committed",
			"plan", id, "field", existing.FieldID,
			"crop", existing.Crop, "previous", existing.RotationCheck.PreviousCrop)
	}

	committed, err := s.repo.SetStatus(ctx, id, tenantID, domain.PlanCommitted)
	if err != nil {
		return nil, err
	}

	s.publish(ctx, topicPlanCommitted, committed.ID, map[string]any{
		"tenant_id":        tenantID,
		"plan_id":          committed.ID,
		"field_id":         committed.FieldID,
		"crop":             committed.Crop,
		"season":           committed.Season,
		"year":             committed.Year,
		"area_hectares":    committed.AreaHectares,
		"sowing_opens":     committed.SowingWindow.Opens,
		"sowing_closes":    committed.SowingWindow.Closes,
		"rotation_verdict": committed.RotationCheck.Verdict,
		"budget_total":     committed.Budget.TotalCost,
	})

	return committed, nil
}

// CheckRotation answers the rotation question on its own, before a plan exists.
//
// This is the question a farmer asks first — "can I put cotton here again?" —
// and making them create a draft plan to find out would mean the answer arrives
// after the decision.
func (s *planningService) CheckRotation(ctx context.Context, fieldID, crop string) (domain.RotationCheck, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return domain.RotationCheck{}, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(fieldID) == "" {
		return domain.RotationCheck{}, errors.BadRequest("MISSING_FIELD", domain.ErrMissingField.Error())
	}
	if strings.TrimSpace(crop) == "" {
		return domain.RotationCheck{}, errors.BadRequest("MISSING_CROP", domain.ErrMissingCrop.Error())
	}

	now := s.now()
	previous, err := s.previousCrop(ctx, tenantID, fieldID, now.Year(), currentSeason(now))
	if err != nil {
		return domain.RotationCheck{}, err
	}
	return domain.CheckRotation(crop, previous), nil
}

// GetSowingWindow answers the timing question on its own.
func (s *planningService) GetSowingWindow(ctx context.Context, fieldID, crop string, season domain.Season, year int) (domain.SowingWindow, error) {
	if p9context.TenantID(ctx) == "" {
		return domain.SowingWindow{}, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(crop) == "" {
		return domain.SowingWindow{}, errors.BadRequest("MISSING_CROP", domain.ErrMissingCrop.Error())
	}
	if year == 0 {
		year = s.now().Year()
	}
	if season == "" {
		season = currentSeason(s.now())
	}

	// fieldID is optional here: asking "when is wheat sown in rabi" is a fair
	// question without a field, it just cannot be informed by local rainfall.
	var onset *domain.MonsoonOnset
	if strings.TrimSpace(fieldID) != "" {
		onset = s.monsoonOnset(ctx, fieldID)
	}

	window, err := domain.ComputeSowingWindow(crop, season, year, onset)
	if err != nil {
		return domain.SowingWindow{}, errors.BadRequest("NO_SOWING_WINDOW", err.Error())
	}
	return window, nil
}

// currentSeason is the cropping season a date falls in.
//
// The boundaries match seasonStart in the domain: kharif from June, rabi from
// mid-October, zaid from mid-March. Used only to default an unspecified
// season, never to override one the caller gave.
func currentSeason(t time.Time) domain.Season {
	year := t.Year()
	day := t.Truncate(24 * time.Hour)

	kharif := time.Date(year, time.June, 1, 0, 0, 0, 0, t.Location())
	rabi := time.Date(year, time.October, 15, 0, 0, 0, 0, t.Location())
	zaid := time.Date(year, time.March, 15, 0, 0, 0, 0, t.Location())

	switch {
	case day.Before(zaid):
		// January to mid-March is still the rabi crop, sown the previous October.
		return domain.Rabi
	case day.Before(kharif):
		return domain.Zaid
	case day.Before(rabi):
		return domain.Kharif
	default:
		return domain.Rabi
	}
}

func (s *planningService) publish(ctx context.Context, topic, key string, payload map[string]any) {
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
