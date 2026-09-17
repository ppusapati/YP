package tools

import (
	"context"
	"sync"
	"time"

	"connectrpc.com/connect"

	"p9e.in/samavaya/packages/p9log"

	alertv1 "p9e.in/samavaya/agriculture/alert-service/api/v1"
	fieldv1 "p9e.in/samavaya/agriculture/field-service/api/v1"
	diagnosisv1 "p9e.in/samavaya/agriculture/plant-diagnosis-service/api/v1"
	weatherv1 "p9e.in/samavaya/agriculture/weather-service/api/v1"

	"p9e.in/samavaya/agriculture/advisory-service/internal/domain"
	"p9e.in/samavaya/agriculture/advisory-service/internal/ports/outbound"
)

// farmContextTimeout bounds the record lookup as a whole.
//
// This runs on every question that names a field, before the model is called
// at all, so it sits directly in the farmer's wait. Four services that each
// take two seconds would add eight seconds to every answer if they ran in
// sequence; they run together, and the whole set gives up at this deadline
// with whatever it has.
const farmContextTimeout = 4 * time.Second

type farmContext struct {
	c   *Clients
	log *p9log.Helper
}

// NewFarmContextSource fetches the tenant's own records for a question.
//
// Unconditional, rather than left to the model to request. The field's crop,
// its growth stage, its open alerts and its last diagnosis are what make an
// answer about this farm rather than about farming, and a model that has to
// think to ask for them mostly does not — the answer that comes back is
// fluent, general, and indistinguishable from one written without ever
// looking at the farm.
func NewFarmContextSource(c *Clients, log p9log.Logger) outbound.FarmContextSource {
	return &farmContext{
		c:   c,
		log: p9log.NewHelper(p9log.With(log, "component", "AdvisoryFarmContext")),
	}
}

func (f *farmContext) Name() string { return "farm-records" }

func (f *farmContext) Fetch(ctx context.Context, q outbound.FarmContextQuery) ([]domain.Citation, error) {
	if q.FieldID == "" {
		// Without a field there is nothing to anchor on. Not an error: a
		// general question ("what does zinc deficiency look like?") is a
		// perfectly good question, and it is answered from the reference
		// corpus alone.
		return nil, nil
	}

	ctx, cancel := context.WithTimeout(ctx, farmContextTimeout)
	defer cancel()

	var (
		mu  sync.Mutex
		out []domain.Citation
		wg  sync.WaitGroup
	)

	add := func(c domain.Citation) {
		mu.Lock()
		defer mu.Unlock()
		c.TenantID = q.TenantID
		out = append(out, c)
	}

	// Each lookup logs its own failure and contributes nothing.
	//
	// One service being down degrades the answer by one source; it does not
	// fail the question. What it must not do is pass silently: an assistant
	// answering without the field's open alerts, because alert-service was
	// unreachable, gives advice that contradicts a warning the farmer can see
	// on their own dashboard, and nothing in the exchange would say why.
	run := func(name string, fn func() (domain.Citation, bool, error)) {
		wg.Add(1)
		go func() {
			defer wg.Done()
			citation, ok, err := fn()
			if err != nil {
				f.log.Warnw("msg", "farm context lookup failed",
					"source", name, "field_id", q.FieldID, "error", err)
				return
			}
			if ok {
				add(citation)
			}
		}()
	}

	if f.c.Field != nil {
		run("field", func() (domain.Citation, bool, error) {
			resp, err := f.c.Field.GetField(ctx, connect.NewRequest(&fieldv1.GetFieldRequest{Id: q.FieldID}))
			if err != nil {
				return domain.Citation{}, false, err
			}
			field := resp.Msg.GetField()
			if field == nil {
				return domain.Citation{}, false, nil
			}
			body, err := encodeResult(fieldSummary(field))
			if err != nil {
				return domain.Citation{}, false, err
			}
			return domain.Citation{
				Kind:     domain.CitationField,
				Title:    "This field's record: " + field.GetName(),
				Snippet:  body,
				SourceID: field.GetId(),
				URI:      appURI("farm-management", "fields", field.GetId()),
				Locale:   domain.LocaleEN,
			}, true, nil
		})
	}

	if f.c.Weather != nil {
		run("weather", func() (domain.Citation, bool, error) {
			resp, err := f.c.Weather.GetCurrentWeather(ctx,
				connect.NewRequest(&weatherv1.GetCurrentWeatherRequest{FieldId: q.FieldID}))
			if err != nil {
				return domain.Citation{}, false, err
			}
			obs := resp.Msg.GetObservation()
			if obs == nil {
				return domain.Citation{}, false, nil
			}
			body, err := encodeResult(weatherSummary(obs))
			if err != nil {
				return domain.Citation{}, false, err
			}
			return domain.Citation{
				Kind:     domain.CitationWeather,
				Title:    "Latest weather at this field",
				Snippet:  body,
				SourceID: q.FieldID,
				URI:      appURI("smart-agriculture", "weather"),
				Locale:   domain.LocaleEN,
			}, true, nil
		})
	}

	if f.c.Alert != nil {
		run("alerts", func() (domain.Citation, bool, error) {
			resp, err := f.c.Alert.ListAlerts(ctx, connect.NewRequest(&alertv1.ListAlertsRequest{
				FieldId:  q.FieldID,
				FarmId:   q.FarmID,
				PageSize: 10,
			}))
			if err != nil {
				return domain.Citation{}, false, err
			}
			alerts := resp.Msg.GetAlerts()
			if len(alerts) == 0 {
				return domain.Citation{}, false, nil
			}
			body, err := encodeResult(alertSummaries(alerts))
			if err != nil {
				return domain.Citation{}, false, err
			}
			return domain.Citation{
				Kind:     domain.CitationAlert,
				Title:    "Open alerts on this field",
				Snippet:  body,
				SourceID: q.FieldID,
				URI:      appURI("alerts"),
				Locale:   domain.LocaleEN,
			}, true, nil
		})
	}

	if f.c.Diagnosis != nil {
		run("diagnoses", func() (domain.Citation, bool, error) {
			resp, err := f.c.Diagnosis.ListDiagnoses(ctx, connect.NewRequest(&diagnosisv1.ListDiagnosesRequest{
				FieldId:  q.FieldID,
				FarmId:   q.FarmID,
				PageSize: 3,
				SortBy:   "created_at",
				SortDesc: true,
			}))
			if err != nil {
				return domain.Citation{}, false, err
			}
			diagnoses := resp.Msg.GetDiagnoses()
			if len(diagnoses) == 0 {
				return domain.Citation{}, false, nil
			}
			body, err := encodeResult(diagnosisSummaries(diagnoses))
			if err != nil {
				return domain.Citation{}, false, err
			}
			return domain.Citation{
				Kind:     domain.CitationDiagnosis,
				Title:    "Recent diagnoses on this field",
				Snippet:  body,
				SourceID: q.FieldID,
				URI:      appURI("crop-intelligence", "diagnosis"),
				Locale:   domain.LocaleEN,
			}, true, nil
		})
	}

	wg.Wait()

	// Deterministic order, so two identical questions produce the same
	// citation numbering. Without it the markers move between runs and a
	// reviewer comparing two exchanges is comparing different [2]s.
	sortCitationsByKind(out)
	return out, nil
}

// kindOrder puts the farm's own records in the order a person would read them:
// what the field is, what the weather is doing, what is already wrong, and what
// was last diagnosed.
var kindOrder = map[domain.CitationKind]int{
	domain.CitationField:     0,
	domain.CitationWeather:   1,
	domain.CitationAlert:     2,
	domain.CitationDiagnosis: 3,
}

func sortCitationsByKind(citations []domain.Citation) {
	for i := 1; i < len(citations); i++ {
		for j := i; j > 0 && kindOrder[citations[j].Kind] < kindOrder[citations[j-1].Kind]; j-- {
			citations[j], citations[j-1] = citations[j-1], citations[j]
		}
	}
}
