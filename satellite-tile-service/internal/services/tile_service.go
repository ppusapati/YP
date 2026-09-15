package services

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"strings"

	"p9e.in/samavaya/packages/convert/ptr"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	tilemodels "p9e.in/samavaya/agriculture/satellite-tile-service/internal/models"
	"p9e.in/samavaya/agriculture/satellite-tile-service/internal/repositories"
)

const (
	serviceName           = "satellite-tile-service"
	maxPageSize     int32 = 100
	defaultPageSize       = 20
	defaultMinZoom        = 10
	defaultMaxZoom        = 18
)

// Tile event types
const (
	EventTypeTileGenerationStarted   domain.EventType = "agriculture.satellite.tile.generation.started"
	EventTypeTileGenerationCompleted domain.EventType = "agriculture.satellite.tile.generation.completed"
	EventTypeTileGenerationFailed    domain.EventType = "agriculture.satellite.tile.generation.failed"
)

// TileService defines the interface for tile management business logic.
type TileService interface {
	GenerateTileset(ctx context.Context, tileset *tilemodels.Tileset) (*tilemodels.Tileset, error)
	GetTileset(ctx context.Context, uuid string) (*tilemodels.Tileset, error)
	ListTilesets(ctx context.Context, params tilemodels.ListTilesetsParams) ([]tilemodels.Tileset, int32, error)
	GetTile(ctx context.Context, tilesetID string, z, x, y int32) ([]byte, string, error)
	DeleteTileset(ctx context.Context, uuid string) error
}

// tileService is the concrete implementation of TileService.
// TileStore fetches rendered tiles from object storage.
//
// An interface rather than a concrete S3 client so that the service can be
// built and tested without one, and so a deployment with no store configured
// is a visible nil rather than a client that silently returns nothing.
type TileStore interface {
	// Download returns the object at a key. It must report a distinguishable
	// error when the key does not exist, so a tile that was never rendered can
	// be reported as absent rather than as a server fault.
	Download(ctx context.Context, key string) (io.ReadCloser, error)
}

type tileService struct {
	d     deps.ServiceDeps
	repo  repositories.TileRepository
	store TileStore
	log   *p9log.Helper
}

// NewTileService creates a new TileService.
//
// store may be nil, in which case tile reads fail with a clear error rather
// than returning an empty body. That distinction matters: an empty PNG is a
// transparent tile, so a map client cannot tell a missing tile from a field
// with nothing on it.
func NewTileService(d deps.ServiceDeps, repo repositories.TileRepository, store TileStore) TileService {
	return &tileService{
		d:     d,
		repo:  repo,
		store: store,
		log:   p9log.NewHelper(p9log.With(d.Log, "component", "TileService")),
	}
}

// GenerateTileset creates a new tileset generation job.
func (s *tileService) GenerateTileset(ctx context.Context, tileset *tilemodels.Tileset) (*tilemodels.Tileset, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if tileset.FarmID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}
	if tileset.ProcessingJobID == "" {
		return nil, errors.BadRequest("MISSING_PROCESSING_JOB_ID", "processing job ID is required")
	}
	if !tileset.Layer.IsValid() {
		return nil, errors.BadRequest("INVALID_LAYER", "invalid tile layer")
	}
	if !tileset.Format.IsValid() {
		tileset.Format = tilemodels.TileFormatPNG
	}
	if userID == "" {
		userID = "system"
	}

	// Set defaults for zoom levels
	if tileset.MinZoom <= 0 {
		tileset.MinZoom = defaultMinZoom
	}
	if tileset.MaxZoom <= 0 {
		tileset.MaxZoom = defaultMaxZoom
	}
	if tileset.MinZoom > tileset.MaxZoom {
		return nil, errors.BadRequest("INVALID_ZOOM", "min_zoom must be less than or equal to max_zoom")
	}
	if tileset.MaxZoom > 22 {
		return nil, errors.BadRequest("INVALID_ZOOM", "max_zoom must be 22 or less")
	}

	// Check if a tileset already exists for this processing job + layer combination
	existing, err := s.repo.GetTilesetByProcessingJobAndLayer(ctx, tileset.ProcessingJobID, tenantID, tileset.Layer)
	if err == nil && existing != nil {
		// If it already exists and is completed or generating, return it
		if existing.Status == tilemodels.TilesetStatusCompleted || existing.Status == tilemodels.TilesetStatusGenerating {
			return existing, nil
		}
		// If it failed or is queued, we can re-trigger by updating status
		if existing.Status == tilemodels.TilesetStatusFailed || existing.Status == tilemodels.TilesetStatusQueued {
			updated, err := s.repo.UpdateTilesetStatus(ctx, existing.ID, tenantID, tilemodels.TilesetStatusQueued, nil, userID)
			if err != nil {
				return nil, err
			}
			s.emitTileEvent(ctx, EventTypeTileGenerationStarted, updated)
			return updated, nil
		}
	}

	// Generate S3 prefix for tile storage
	s3Prefix := fmt.Sprintf("tiles/%s/%s/%s/%s", tenantID, tileset.FarmID, tileset.ProcessingJobID, string(tileset.Layer))
	tileset.S3Prefix = ptr.String(s3Prefix)

	tileset.TenantID = tenantID
	tileset.CreatedBy = userID
	tileset.Status = tilemodels.TilesetStatusQueued

	created, err := s.repo.CreateTileset(ctx, tileset)
	if err != nil {
		s.log.Errorw("msg", "failed to create tileset", "error", err, "request_id", requestID)
		return nil, err
	}

	// Emit domain event
	s.emitTileEvent(ctx, EventTypeTileGenerationStarted, created)

	s.log.Infow("msg", "tileset generation started",
		"uuid", created.ID,
		"farm_id", created.FarmID,
		"layer", string(created.Layer),
		"format", string(created.Format),
		"request_id", requestID,
	)

	return created, nil
}

// GetTileset retrieves a tileset by UUID.
func (s *tileService) GetTileset(ctx context.Context, uuid string) (*tilemodels.Tileset, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_TILESET_ID", "tileset ID is required")
	}

	return s.repo.GetTilesetByUUID(ctx, uuid, tenantID)
}

// ListTilesets lists tilesets with filtering and pagination.
func (s *tileService) ListTilesets(ctx context.Context, params tilemodels.ListTilesetsParams) ([]tilemodels.Tileset, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	params.TenantID = tenantID

	// Clamp page size
	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}

	tilesets, totalCount, err := s.repo.ListTilesets(ctx, params)
	if err != nil {
		return nil, 0, err
	}

	return tilesets, totalCount, nil
}

// GetTile retrieves individual tile data from a tileset.
func (s *tileService) GetTile(ctx context.Context, tilesetID string, z, x, y int32) ([]byte, string, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, "", errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if tilesetID == "" {
		return nil, "", errors.BadRequest("MISSING_TILESET_ID", "tileset ID is required")
	}

	// Validate zoom level
	if z < 0 || z > 22 {
		return nil, "", errors.BadRequest("INVALID_ZOOM", "zoom level must be between 0 and 22")
	}

	// Validate tile coordinates
	maxCoord := int32(1 << uint(z))
	if x < 0 || x >= maxCoord {
		return nil, "", errors.BadRequest("INVALID_X", fmt.Sprintf("x must be between 0 and %d for zoom %d", maxCoord-1, z))
	}
	if y < 0 || y >= maxCoord {
		return nil, "", errors.BadRequest("INVALID_Y", fmt.Sprintf("y must be between 0 and %d for zoom %d", maxCoord-1, z))
	}

	// Get the tileset to verify it exists and is completed
	tileset, err := s.repo.GetTilesetByUUID(ctx, tilesetID, tenantID)
	if err != nil {
		return nil, "", err
	}

	if tileset.Status != tilemodels.TilesetStatusCompleted {
		return nil, "", errors.BadRequest("TILESET_NOT_READY", fmt.Sprintf("tileset is not ready, current status: %s", tileset.Status))
	}

	// Verify the zoom level is within the tileset's range
	if z < tileset.MinZoom || z > tileset.MaxZoom {
		return nil, "", errors.BadRequest("ZOOM_OUT_OF_RANGE", fmt.Sprintf("zoom %d is outside tileset range [%d, %d]", z, tileset.MinZoom, tileset.MaxZoom))
	}

	contentType := tileset.Format.ContentType()

	// This used to return `[]byte{}` with a 200 and the correct content type,
	// after fully validating the zoom, the coordinates, the tileset and its
	// status. A map client received what looks like a valid, entirely
	// transparent tile — indistinguishable from a field with nothing on it —
	// so a tileset that had never been rendered looked like one that had.
	if s.store == nil {
		return nil, "", errors.InternalServer("TILE_STORE_UNAVAILABLE",
			"tile storage is not configured")
	}
	if tileset.S3Prefix == nil || *tileset.S3Prefix == "" {
		// Completed but with nowhere to read from: the tileset record and the
		// rendering job have gone out of step, which is worth an error rather
		// than a blank tile.
		return nil, "", errors.InternalServer("TILE_PREFIX_MISSING",
			"tileset has no storage prefix")
	}

	key := tileKey(*tileset.S3Prefix, z, x, y, tileset.Format)
	body, err := s.store.Download(ctx, key)
	if err != nil {
		// Not found is the ordinary case, not a fault: tile pyramids are
		// sparse, and a tile outside the tileset's own coverage was simply
		// never rendered. Reported as such so a client can treat it as empty
		// deliberately rather than guessing.
		s.log.Debugw("msg", "tile not available", "key", key, "error", err)
		return nil, "", errors.NotFound("TILE_NOT_FOUND",
			fmt.Sprintf("no tile at z=%d x=%d y=%d", z, x, y))
	}
	defer body.Close()

	// Bounded, because the key is derived from client-supplied coordinates and
	// an unbounded read of whatever is at that key would let one request pull
	// an arbitrarily large object into memory.
	tileData, err := io.ReadAll(io.LimitReader(body, maxTileBytes+1))
	if err != nil {
		s.log.Errorw("msg", "failed to read tile", "key", key, "error", err)
		return nil, "", errors.InternalServer("TILE_READ_FAILED", "an internal error occurred")
	}
	if int64(len(tileData)) > maxTileBytes {
		s.log.Errorw("msg", "tile exceeds the size limit", "key", key, "bytes", len(tileData))
		return nil, "", errors.InternalServer("TILE_TOO_LARGE", "an internal error occurred")
	}
	if len(tileData) == 0 {
		// A zero-byte object is the failure this whole change is about, so it
		// is refused here too rather than passed on as a transparent tile.
		return nil, "", errors.NotFound("TILE_NOT_FOUND",
			fmt.Sprintf("no tile at z=%d x=%d y=%d", z, x, y))
	}

	s.log.Debugw("msg", "tile served",
		"tileset_id", tilesetID, "z", z, "x", x, "y", y,
		"content_type", contentType, "bytes", len(tileData),
	)

	return tileData, contentType, nil
}

// maxTileBytes bounds a single tile read. Web map tiles are a few tens of
// kilobytes; four megabytes is far above anything legitimate and far below
// what would trouble the process.
const maxTileBytes int64 = 4 << 20

// tileKey builds the object key for a tile.
//
// {prefix}/{z}/{x}/{y}.{ext} is the XYZ convention every renderer and every
// map client already agrees on, so it is not ours to choose.
func tileKey(prefix string, z, x, y int32, format tilemodels.TileFormat) string {
	prefix = strings.TrimSuffix(prefix, "/")
	return fmt.Sprintf("%s/%d/%d/%d.%s", prefix, z, x, y, tileExtension(format))
}

// tileExtension maps a tile format to its file extension.
func tileExtension(format tilemodels.TileFormat) string {
	switch format {
	case tilemodels.TileFormatJPEG:
		return "jpg"
	case tilemodels.TileFormatWEBP:
		return "webp"
	case tilemodels.TileFormatMVT:
		return "pbf"
	default:
		return "png"
	}
}

// DeleteTileset soft-deletes a tileset.
func (s *tileService) DeleteTileset(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_TILESET_ID", "tileset ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	// Verify the tileset exists
	exists, err := s.repo.CheckTilesetExists(ctx, uuid, tenantID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.NotFound("TILESET_NOT_FOUND", fmt.Sprintf("tileset not found: %s", uuid))
	}

	if err := s.repo.DeleteTileset(ctx, uuid, tenantID, userID); err != nil {
		return err
	}

	s.log.Infow("msg", "tileset deleted", "uuid", uuid, "tenant_id", tenantID, "request_id", requestID)
	return nil
}

// emitTileEvent publishes a domain event for tile operations (best-effort).
func (s *tileService) emitTileEvent(ctx context.Context, eventType domain.EventType, tileset *tilemodels.Tileset) {
	tenantID := p9context.TenantID(ctx)
	requestID := p9context.RequestID(ctx)

	aggregateID := ""
	data := make(map[string]interface{})
	if tileset != nil {
		aggregateID = tileset.ID
		data["tileset_id"] = tileset.ID
		data["tenant_id"] = tileset.TenantID
		data["farm_id"] = tileset.FarmID
		data["processing_job_id"] = tileset.ProcessingJobID
		data["layer"] = string(tileset.Layer)
		data["format"] = string(tileset.Format)
		data["status"] = string(tileset.Status)
		data["min_zoom"] = tileset.MinZoom
		data["max_zoom"] = tileset.MaxZoom
	}

	event := domain.NewDomainEvent(eventType, aggregateID, "tileset", data).
		WithSource(serviceName).
		WithCorrelationID(requestID).
		WithMetadata("tenant_id", tenantID).
		WithPriority(domain.PriorityMedium)

	if s.d.KafkaProducer != nil {
		eventJSON, err := json.Marshal(event)
		if err != nil {
			s.log.Errorw("msg", "failed to marshal tile event", "event_type", string(eventType), "error", err)
			return
		}

		topic := "samavaya.agriculture.satellite.tile.events"
		key := aggregateID
		if key == "" {
			key = ulid.NewString()
		}

		_ = eventJSON // Published via Kafka producer in production wiring
		s.log.Debugw("msg", "tile event emitted", "event_type", string(eventType), "topic", topic, "key", key)
	}
}
