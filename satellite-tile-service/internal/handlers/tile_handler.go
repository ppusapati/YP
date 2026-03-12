package handlers

import (
	"context"
	"fmt"
	"strconv"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/satellite-tile-service/api/v1"
	"p9e.in/samavaya/agriculture/satellite-tile-service/internal/mappers"
	tilemodels "p9e.in/samavaya/agriculture/satellite-tile-service/internal/models"
	"p9e.in/samavaya/agriculture/satellite-tile-service/internal/services"
)

// TileHandler implements the ConnectRPC SatelliteTileService handler.
type TileHandler struct {
	d       deps.ServiceDeps
	service services.TileService
	log     *p9log.Helper
}

// NewTileHandler creates a new TileHandler.
func NewTileHandler(d deps.ServiceDeps, service services.TileService) *TileHandler {
	return &TileHandler{
		d:       d,
		service: service,
		log:     p9log.NewHelper(p9log.With(d.Log, "component", "TileHandler")),
	}
}

// GenerateTileset handles tileset generation requests.
func (h *TileHandler) GenerateTileset(ctx context.Context, req *pb.GenerateTilesetRequest) (*pb.GenerateTilesetResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GenerateTileset request",
		"processing_job_id", req.GetProcessingJobId(),
		"farm_id", req.GetFarmId(),
		"layer", req.GetLayer().String(),
		"format", req.GetFormat().String(),
		"request_id", requestID,
	)

	if req.GetProcessingJobId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "processing_job_id is required")
	}
	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.GetLayer() == pb.TileLayer_TILE_LAYER_UNSPECIFIED {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "layer is required")
	}

	tileset := &tilemodels.Tileset{
		FarmID:          req.GetFarmId(),
		ProcessingJobID: req.GetProcessingJobId(),
		Layer:           mappers.ProtoTileLayerToDomain(req.GetLayer()),
		Format:          mappers.ProtoTileFormatToDomain(req.GetFormat()),
		MinZoom:         req.GetMinZoom(),
		MaxZoom:         req.GetMaxZoom(),
	}

	created, err := h.service.GenerateTileset(ctx, tileset)
	if err != nil {
		h.log.Errorw("msg", "GenerateTileset failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.GenerateTilesetResponse{
		Tileset: mappers.TilesetToProto(created),
	}, nil
}

// GetTileset handles get tileset requests.
func (h *TileHandler) GetTileset(ctx context.Context, req *pb.GetTilesetRequest) (*pb.GetTilesetResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetTileset request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tileset ID is required")
	}

	tileset, err := h.service.GetTileset(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetTilesetResponse{
		Tileset: mappers.TilesetToProto(tileset),
	}, nil
}

// ListTilesets handles list tilesets requests with filtering and pagination.
func (h *TileHandler) ListTilesets(ctx context.Context, req *pb.ListTilesetsRequest) (*pb.ListTilesetsResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListTilesets request", "request_id", requestID)

	params := tilemodels.ListTilesetsParams{
		PageSize: req.GetPageSize(),
	}

	// Parse page token as offset
	if req.GetPageToken() != "" {
		offset, err := strconv.ParseInt(req.GetPageToken(), 10, 32)
		if err == nil {
			params.Offset = int32(offset)
		}
	}

	// Apply filters
	if req.GetFarmId() != "" {
		farmID := req.GetFarmId()
		params.FarmID = &farmID
	}
	if req.GetLayer() != pb.TileLayer_TILE_LAYER_UNSPECIFIED {
		layer := mappers.ProtoTileLayerToDomain(req.GetLayer())
		params.Layer = &layer
	}
	if req.GetStatus() != pb.TilesetStatus_TILESET_STATUS_UNSPECIFIED {
		status := mappers.ProtoTilesetStatusToDomain(req.GetStatus())
		params.Status = &status
	}

	tilesets, totalCount, err := h.service.ListTilesets(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListTilesetsResponse{
		Tilesets:    mappers.TilesetsToProto(tilesets),
		TotalCount:  totalCount,
	}

	// Compute next page token
	nextOffset := params.Offset + params.PageSize
	if nextOffset < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// GetTile handles individual tile retrieval requests.
func (h *TileHandler) GetTile(ctx context.Context, req *pb.GetTileRequest) (*pb.GetTileResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Debugw("msg", "GetTile request",
		"tileset_id", req.GetTilesetId(),
		"z", req.GetZ(),
		"x", req.GetX(),
		"y", req.GetY(),
		"request_id", requestID,
	)

	if req.GetTilesetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tileset_id is required")
	}

	tileData, contentType, err := h.service.GetTile(ctx, req.GetTilesetId(), req.GetZ(), req.GetX(), req.GetY())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetTileResponse{
		TileData:    tileData,
		ContentType: contentType,
	}, nil
}

// DeleteTileset handles tileset deletion requests.
func (h *TileHandler) DeleteTileset(ctx context.Context, req *pb.DeleteTilesetRequest) (*pb.DeleteTilesetResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "DeleteTileset request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tileset ID is required")
	}

	err := h.service.DeleteTileset(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.DeleteTilesetResponse{
		Success: true,
	}, nil
}
