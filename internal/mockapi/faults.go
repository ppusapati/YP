package mockapi

import (
	"encoding/json"
	"net/http"
	"sync"
	"time"
)

// Fault injection.
//
// The happy path is the easy half. What actually breaks in production is the
// upstream returning 503 for ninety seconds, or answering so slowly that the
// client's timeout fires, and none of that can be rehearsed against a mock
// that always succeeds. These controls exist so the retry and backoff paths
// can be exercised without waiting for a real provider to have a bad day.
//
// Faults are set over HTTP rather than by flag because the interesting cases
// are transitions — healthy, then failing, then healthy again — and a flag
// would need a restart between each one.

// Fault describes how a route should misbehave.
type Fault struct {
	// Status is the HTTP status to return. Zero means the request succeeds
	// normally, which is how a delay-only fault is expressed.
	Status int `json:"status,omitempty"`

	// Body replaces the response body. Empty means a generic error payload.
	Body string `json:"body,omitempty"`

	// DelayMS is applied before responding, whether or not Status is set.
	// Useful for driving a client into its own timeout.
	DelayMS int `json:"delay_ms,omitempty"`

	// Remaining counts down per matching request; the fault clears when it
	// reaches zero. Zero at the time of setting means "until cleared", which
	// is the distinction between "this upstream is down" and "the next two
	// calls fail and the third works" — the second being the one that proves
	// a retry loop actually retries.
	Remaining int `json:"remaining,omitempty"`

	// Sticky is set when Remaining was zero at configuration time.
	Sticky bool `json:"sticky"`
}

// faultStore holds the configured fault per provider. The key "all" applies to
// any provider without a more specific entry.
type faultStore struct {
	mu     sync.Mutex
	faults map[string]*Fault
}

func newFaultStore() *faultStore {
	return &faultStore{faults: map[string]*Fault{}}
}

// set installs a fault for a provider, or removes it when f is nil.
func (s *faultStore) set(provider string, f *Fault) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if f == nil {
		delete(s.faults, provider)
		return
	}
	f.Sticky = f.Remaining == 0
	s.faults[provider] = f
}

func (s *faultStore) clear() {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.faults = map[string]*Fault{}
}

// snapshot returns a copy for the status endpoint.
func (s *faultStore) snapshot() map[string]Fault {
	s.mu.Lock()
	defer s.mu.Unlock()
	out := make(map[string]Fault, len(s.faults))
	for k, v := range s.faults {
		out[k] = *v
	}
	return out
}

// take consumes one use of the fault applying to a provider, if any. A
// non-sticky fault is decremented and removed once exhausted, so the caller
// gets exactly the number of failures that were configured.
func (s *faultStore) take(provider string) *Fault {
	s.mu.Lock()
	defer s.mu.Unlock()

	f, ok := s.faults[provider]
	if !ok {
		if f, ok = s.faults["all"]; !ok {
			return nil
		}
		provider = "all"
	}

	out := *f
	if !f.Sticky {
		f.Remaining--
		if f.Remaining <= 0 {
			delete(s.faults, provider)
		}
	}
	return &out
}

// apply writes the fault's response if one is active, reporting whether it did.
// A delay with no status is applied and then allowed through, which is how a
// slow-but-working upstream is simulated.
func (s *faultStore) apply(w http.ResponseWriter, provider string) bool {
	f := s.take(provider)
	if f == nil {
		return false
	}
	if f.DelayMS > 0 {
		time.Sleep(time.Duration(f.DelayMS) * time.Millisecond)
	}
	if f.Status == 0 {
		return false
	}
	body := f.Body
	if body == "" {
		body = `{"error":true,"reason":"injected fault from mockserver"}`
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(f.Status)
	_, _ = w.Write([]byte(body))
	return true
}

// handleFaults serves the control endpoint.
//
//	GET    /__mock/faults              current faults
//	POST   /__mock/faults?provider=X   install one
//	DELETE /__mock/faults              clear all
func (s *faultStore) handleFaults(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		writeJSON(w, http.StatusOK, s.snapshot())

	case http.MethodPost, http.MethodPut:
		provider := r.URL.Query().Get("provider")
		if provider == "" {
			provider = "all"
		}
		var f Fault
		if err := json.NewDecoder(r.Body).Decode(&f); err != nil {
			writeJSON(w, http.StatusBadRequest, map[string]string{"error": err.Error()})
			return
		}
		s.set(provider, &f)
		writeJSON(w, http.StatusOK, map[string]any{"provider": provider, "fault": f})

	case http.MethodDelete:
		if provider := r.URL.Query().Get("provider"); provider != "" {
			s.set(provider, nil)
		} else {
			s.clear()
		}
		writeJSON(w, http.StatusOK, map[string]string{"status": "cleared"})

	default:
		w.Header().Set("Allow", "GET, POST, PUT, DELETE")
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}
