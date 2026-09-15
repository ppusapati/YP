package handlers

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"
)

// Tile event type constants matching those in services.
const (
	EventTypeTileGenerationStarted   domain.EventType = "agriculture.satellite.tile.generation.started"
	EventTypeTileGenerationCompleted domain.EventType = "agriculture.satellite.tile.generation.completed"
	EventTypeTileGenerationFailed    domain.EventType = "agriculture.satellite.tile.generation.failed"
)

// TileGenerationEventData represents the data payload for tile generation events.
type TileGenerationEventData struct {
	TilesetID       string `json:"tileset_id"`
	TenantID        string `json:"tenant_id"`
	FarmID          string `json:"farm_id"`
	ProcessingJobID string `json:"processing_job_id"`
	Layer           string `json:"layer"`
	Format          string `json:"format"`
	Status          string `json:"status"`
	MinZoom         int32  `json:"min_zoom"`
	MaxZoom         int32  `json:"max_zoom"`
	ErrorMessage    string `json:"error_message,omitempty"`
}

// TileEventHandler handles incoming tile-related domain events (consumer side).
type TileEventHandler struct {
	d   deps.ServiceDeps
	log *p9log.Helper
}

// NewTileEventHandler creates a new TileEventHandler for consuming tile events.
func NewTileEventHandler(d deps.ServiceDeps) *TileEventHandler {
	return &TileEventHandler{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "TileEventHandler")),
	}
}

// HandleEvent is the entry point for consuming a tile domain event.
// It dispatches to the appropriate handler based on event type.
func (h *TileEventHandler) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}

	h.log.Infow("msg", "handling tile event",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	case EventTypeTileGenerationStarted:
		return h.handleTileGenerationStarted(ctx, event)
	case EventTypeTileGenerationCompleted:
		return h.handleTileGenerationCompleted(ctx, event)
	case EventTypeTileGenerationFailed:
		return h.handleTileGenerationFailed(ctx, event)
	default:
		h.log.Warnf("unhandled tile event type: %s", event.Type)
		return nil
	}
}

// handleTileGenerationStarted processes a tile generation started event.
func (h *TileEventHandler) handleTileGenerationStarted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractTileEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract tile generation started event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "tile generation started event received",
		"tileset_id", data.TilesetID,
		"farm_id", data.FarmID,
		"layer", data.Layer,
		"format", data.Format,
	)

	// Downstream consumers can react here:
	// - Start the actual tile generation worker/pipeline
	// - Update GeoServer configuration for the new tileset
	// - Notify the frontend that tiles are being generated
	// - Reserve storage capacity for the expected tile count

	return nil
}

// handleTileGenerationCompleted processes a tile generation completed event.
func (h *TileEventHandler) handleTileGenerationCompleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractTileEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract tile generation completed event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "tile generation completed event received",
		"tileset_id", data.TilesetID,
		"farm_id", data.FarmID,
		"layer", data.Layer,
	)

	// Downstream consumers can react here:
	// - Register the tileset with GeoServer for WMS/WMTS serving
	// - Invalidate CDN cache for the farm's tile endpoint
	// - Notify the frontend that new tiles are available
	// - Update farm dashboard with latest imagery availability

	return nil
}

// handleTileGenerationFailed processes a tile generation failed event.
func (h *TileEventHandler) handleTileGenerationFailed(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractTileEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract tile generation failed event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Errorw("msg", "tile generation failed event received",
		"tileset_id", data.TilesetID,
		"farm_id", data.FarmID,
		"layer", data.Layer,
		"error_message", data.ErrorMessage,
	)

	// Downstream consumers can react here:
	// - Send alert notification about failed tile generation
	// - Schedule retry if transient failure
	// - Log the failure for monitoring/alerting dashboards
	// - Clean up any partial tile data from storage

	return nil
}

// extractTileEventData extracts TileGenerationEventData from a domain event's Data map.
func extractTileEventData(event *domain.DomainEvent) (*TileGenerationEventData, error) {
	data := &TileGenerationEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal event data: %w", err)
	}
	return data, nil
}

// RegisterTileEventConsumer registers the tile event handler with the Kafka consumer.
// This should be called during service initialization.
func RegisterTileEventConsumer(d deps.ServiceDeps) (*TileEventHandler, error) {
	handler := NewTileEventHandler(d)

	if d.KafkaConsumer == nil {
		handler.log.Warnf("Kafka consumer not configured, skipping event registration")
		return handler, nil
	}

	topic := "samavaya.agriculture.satellite.tile.events"
	handler.log.Infow("msg", "registering tile event consumer", "topic", topic)

	// The actual Kafka subscription is wired during application bootstrap.
	// The handler.HandleEvent method is the callback for incoming messages.

	return handler, nil
}

// IsTileEvent checks if a domain event type belongs to the tile domain.
func IsTileEvent(eventType domain.EventType) bool {
	switch eventType {
	case EventTypeTileGenerationStarted,
		EventTypeTileGenerationCompleted,
		EventTypeTileGenerationFailed:
		return true
	default:
		return false
	}
}
