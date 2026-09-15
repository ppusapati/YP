package realtime

import (
	"errors"
	"math"
	"time"
)

// Topic names for the real-time field map.
//
// Both are joined to a tenant with TenantTopic before use; a bare name here is
// half a topic, and the transports refuse the half.
const (
	// TopicPrefixFieldMap carries live positions and overlay notices for one
	// field. Format: fieldmap.<field_id>
	TopicPrefixFieldMap = "fieldmap."

	// TopicPrefixInspection carries presence and edits for one collaborative
	// inspection. Format: inspection.<inspection_id>
	TopicPrefixInspection = "inspection."
)

// FieldMapTopic is the unqualified topic for one field's live map.
func FieldMapTopic(fieldID string) string { return TopicPrefixFieldMap + fieldID }

// InspectionTopic is the unqualified topic for one inspection's session.
func InspectionTopic(inspectionID string) string {
	return TopicPrefixInspection + inspectionID
}

// Errors from validating real-time payloads.
var (
	ErrEmptyMember      = errors.New("realtime: member id is required")
	ErrInvalidPosition  = errors.New("realtime: position is not on Earth")
	ErrPositionTooOld   = errors.New("realtime: position is older than the map keeps")
	ErrInvalidOverlay   = errors.New("realtime: overlay bounds are not a rectangle on Earth")
	ErrUnknownMachine   = errors.New("realtime: machine id is required")
	ErrEditConflict     = errors.New("realtime: edit is based on an older version")
	ErrEditUnknownField = errors.New("realtime: unknown inspection field")
)

// MachineKind distinguishes what is moving across a field.
type MachineKind string

const (
	MachineTractor   MachineKind = "tractor"
	MachineHarvester MachineKind = "harvester"
	MachineSprayer   MachineKind = "sprayer"
	MachineDrone     MachineKind = "drone"
	// MachineScout is a person walking the field with the mobile app.
	MachineScout MachineKind = "scout"
)

// MachinePosition is one live position report.
//
// Sent from a machine's telematics unit or from the mobile app, bridged from
// Kafka, and broadcast to everyone watching that field's map.
type MachinePosition struct {
	MachineID string      `json:"machine_id"`
	TenantID  string      `json:"tenant_id"`
	FieldID   string      `json:"field_id"`
	Kind      MachineKind `json:"kind"`
	Label     string      `json:"label,omitempty"`

	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`

	// HeadingDegrees is clockwise from north; negative means unknown, which is
	// what a stationary GPS reports and is different from pointing north.
	HeadingDegrees float64 `json:"heading_degrees"`

	// SpeedMetersPerSecond, for drawing a machine as working or idle.
	SpeedMetersPerSecond float64 `json:"speed_mps"`

	// AccuracyMeters is the fix's horizontal accuracy. Carried through to the
	// client rather than dropped, because a 40 m fix drawn as a precise dot on
	// a field boundary is a lie the map tells convincingly.
	AccuracyMeters float64 `json:"accuracy_m"`

	// RecordedAt is when the position was taken, not when it arrived. A
	// telematics unit buffers while out of signal exactly as the phone does,
	// so the two differ by minutes and the map must order by this.
	RecordedAt time.Time `json:"recorded_at"`
}

// MaxPositionAge is how far back a position may be and still be worth drawing.
//
// A live map showing where a tractor was two hours ago is not a live map; it
// is a map that is wrong in a way nobody can see. Older positions belong in
// the track history, which is a different question with a different screen.
const MaxPositionAge = 15 * time.Minute

// Validate reports whether a position can be drawn.
//
// `now` is passed rather than read, so the staleness rule is testable and so a
// replayed Kafka backlog is judged against the time it is being replayed at.
func (p MachinePosition) Validate(now time.Time) error {
	if p.MachineID == "" {
		return ErrUnknownMachine
	}
	if p.TenantID == "" {
		return ErrNoTenant
	}
	// Exactly (0,0) is Null Island: the default a telematics unit reports
	// before it has a fix. Drawing it puts every unfixed machine in the Gulf
	// of Guinea, which looks like a bug in the map rather than in the device.
	if p.Latitude == 0 && p.Longitude == 0 {
		return ErrInvalidPosition
	}
	if math.Abs(p.Latitude) > 90 || math.Abs(p.Longitude) > 180 {
		return ErrInvalidPosition
	}
	if math.IsNaN(p.Latitude) || math.IsNaN(p.Longitude) {
		return ErrInvalidPosition
	}
	if p.RecordedAt.IsZero() || now.Sub(p.RecordedAt) > MaxPositionAge {
		return ErrPositionTooOld
	}
	return nil
}

// Topic is the tenant-qualified topic this position belongs on.
func (p MachinePosition) Topic() string {
	return TenantTopic(p.TenantID, FieldMapTopic(p.FieldID))
}

// AsMember renders the machine as a presence member, so the map's "who is in
// this field" list and its moving dots come from one source rather than two
// that can disagree.
func (p MachinePosition) AsMember() Member {
	return Member{
		ID:       p.MachineID,
		TenantID: p.TenantID,
		Name:     p.Label,
		Role:     string(p.Kind),
		LastSeen: p.RecordedAt,
	}
}

// OverlayKind is what an imagery overlay shows.
type OverlayKind string

const (
	OverlayNDVI         OverlayKind = "ndvi"
	OverlayTrueColor    OverlayKind = "true_color"
	OverlayThermal      OverlayKind = "thermal"
	OverlayPrescription OverlayKind = "prescription"
)

// ImageryOverlay announces that a new layer is available to draw over a field.
//
// It carries where to fetch the tiles and what they cover, not the imagery
// itself: a drone orthomosaic is hundreds of megabytes and has no business on
// a WebSocket. The client fetches through the tile service as usual; this only
// tells it there is something new and that it need not poll.
type ImageryOverlay struct {
	OverlayID string      `json:"overlay_id"`
	TenantID  string      `json:"tenant_id"`
	FieldID   string      `json:"field_id"`
	Kind      OverlayKind `json:"kind"`

	// TileURLTemplate is an `{z}/{x}/{y}` template served by satellite-tile.
	TileURLTemplate string `json:"tile_url_template"`

	// Bounds is the area covered, as [west, south, east, north] in degrees.
	// A client uses it to decide whether the overlay is worth fetching at the
	// camera's current position.
	Bounds [4]float64 `json:"bounds"`

	// CapturedAt is when the imagery was taken. Shown, because a farmer
	// deciding whether to spray needs to know if they are looking at this
	// morning's drone flight or last month's satellite pass.
	CapturedAt time.Time `json:"captured_at"`

	// CloudFraction, for satellite sources; 0 for drone imagery.
	CloudFraction float64 `json:"cloud_fraction"`
}

// Validate reports whether an overlay can be drawn.
func (o ImageryOverlay) Validate() error {
	if o.TenantID == "" {
		return ErrNoTenant
	}
	if o.OverlayID == "" || o.FieldID == "" || o.TileURLTemplate == "" {
		return ErrInvalidOverlay
	}
	west, south, east, north := o.Bounds[0], o.Bounds[1], o.Bounds[2], o.Bounds[3]
	if west >= east || south >= north {
		return ErrInvalidOverlay
	}
	if math.Abs(south) > 90 || math.Abs(north) > 90 ||
		math.Abs(west) > 180 || math.Abs(east) > 180 {
		return ErrInvalidOverlay
	}
	return nil
}

// Topic is the tenant-qualified topic this overlay belongs on.
func (o ImageryOverlay) Topic() string {
	return TenantTopic(o.TenantID, FieldMapTopic(o.FieldID))
}

// Field map event names, carried as the WebSocket message's data envelope so
// one topic can carry positions, overlays and presence without a client having
// to guess from the payload's shape.
const (
	EventMachineMoved   = "machine_moved"
	EventOverlayReady   = "overlay_ready"
	EventPresenceUpdate = "presence"
)

// Envelope wraps a payload with the event name it is.
type Envelope struct {
	Event   string      `json:"event"`
	Payload interface{} `json:"payload"`
}

// NewEnvelope tags a payload with its event name.
func NewEnvelope(event string, payload interface{}) Envelope {
	return Envelope{Event: event, Payload: payload}
}
