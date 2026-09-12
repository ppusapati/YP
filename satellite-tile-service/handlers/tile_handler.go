package handlers

import (
	"context"
	"fmt"
	"strconv"

	"connectrpc.com/connect"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/satellite-tile-service/api/v1"
	"p9e.in/samavaya/agriculture/satellite-tile-service/api/v1/v1connect"
	"p9e.in/samavaya/agriculture/satellite-tile-service/internal/mappers"
	tilemodels "p9e.in/samavaya/agriculture/satellite-tile-service/internal/models"
	"p9e.in/samavaya/agriculture/satellite-tile-service/services"
)

// TileHandler implements the ConnectRPC SatelliteTileServiceHandler interface.
type TileHandler struct {
	v1connect.UnimplementedSatelliteTileServiceHandler

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
func (h *TileHandler) GenerateTileset(ctx context.Context, req *connect.Request[pb.GenerateTilesetRequest]) (*connect.Response[pb.GenerateTilesetResponse], error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GenerateTileset request",
		"processing_job_id", req.Msg.GetProcessingJobId(),
		"farm_id", req.Msg.GetFarmId(),
		"layer", req.Msg.GetLayer().String(),
		"format", req.Msg.GetFormat().String(),
		"request_id", requestID,
	)

	if req.Msg.GetProcessingJobId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "processing_job_id is required")
	}
	if req.Msg.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.Msg.GetLayer() == pb.TileLayer_TILE_LAYER_UNSPECIFIED {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "layer is required")
	}

	tileset := &tilemodels.Tileset{
		FarmID:          req.Msg.GetFarmId(),
		ProcessingJobID: req.Msg.GetProcessingJobId(),
		Layer:           mappers.ProtoTileLayerToDomain(req.Msg.GetLayer()),
		Format:          mappers.ProtoTileFormatToDomain(req.Msg.GetFormat()),
		MinZoom:         req.Msg.GetMinZoom(),
		MaxZoom:         req.Msg.GetMaxZoom(),
	}

	created, err := h.service.GenerateTileset(ctx, tileset)
	if err != nil {
		h.log.Errorw("msg", "GenerateTileset failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.GenerateTilesetResponse{
		Tileset: mappers.TilesetToProto(created),
	}), nil
}

// GetTileset handles get tileset requests.
func (h *TileHandler) GetTileset(ctx context.Context, req *connect.Request[pb.GetTilesetRequest]) (*connect.Response[pb.GetTilesetResponse], error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetTileset request", "id", req.Msg.GetId(), "request_id", requestID)

	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tileset ID is required")
	}

	tileset, err := h.service.GetTileset(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.GetTilesetResponse{
		Tileset: mappers.TilesetToProto(tileset),
	}), nil
}

// ListTilesets handles list tilesets requests with filtering and pagination.
func (h *TileHandler) ListTilesets(ctx context.Context, req *connect.Request[pb.ListTilesetsRequest]) (*connect.Response[pb.ListTilesetsResponse], error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListTilesets request", "request_id", requestID)

	params := tilemodels.ListTilesetsParams{
		PageSize: req.Msg.GetPageSize(),
	}

	// Parse page token as offset
	if req.Msg.GetPageToken() != "" {
		offset, err := strconv.ParseInt(req.Msg.GetPageToken(), 10, 32)
		if err == nil {
			params.Offset = int32(offset)
		}
	}

	// Apply filters
	if req.Msg.GetFarmId() != "" {
		farmID := req.Msg.GetFarmId()
		params.FarmID = &farmID
	}
	if req.Msg.GetLayer() != pb.TileLayer_TILE_LAYER_UNSPECIFIED {
		layer := mappers.ProtoTileLayerToDomain(req.Msg.GetLayer())
		params.Layer = &layer
	}
	if req.Msg.GetStatus() != pb.TilesetStatus_TILESET_STATUS_UNSPECIFIED {
		status := mappers.ProtoTilesetStatusToDomain(req.Msg.GetStatus())
		params.Status = &status
	}

	tilesets, totalCount, err := h.service.ListTilesets(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListTilesetsResponse{
		Tilesets:   mappers.TilesetsToProto(tilesets),
		TotalCount: totalCount,
	}

	// Compute next page token
	nextOffset := params.Offset + params.PageSize
	if nextOffset < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return connect.NewResponse(resp), nil
}

// GetTile handles individual tile retrieval requests.
func (h *TileHandler) GetTile(ctx context.Context, req *connect.Request[pb.GetTileRequest]) (*connect.Response[pb.GetTileResponse], error) {
	requestID := p9context.RequestID(ctx)

	h.log.Debugw("msg", "GetTile request",
		"tileset_id", req.Msg.GetTilesetId(),
		"z", req.Msg.GetZ(),
		"x", req.Msg.GetX(),
		"y", req.Msg.GetY(),
		"request_id", requestID,
	)

	if req.Msg.GetTilesetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tileset_id is required")
	}

	tileData, contentType, err := h.service.GetTile(ctx, req.Msg.GetTilesetId(), req.Msg.GetZ(), req.Msg.GetX(), req.Msg.GetY())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.GetTileResponse{
		TileData:    tileData,
		ContentType: contentType,
	}), nil
}

// DeleteTileset handles tileset deletion requests.
func (h *TileHandler) DeleteTileset(ctx context.Context, req *connect.Request[pb.DeleteTilesetRequest]) (*connect.Response[pb.DeleteTilesetResponse], error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "DeleteTileset request", "id", req.Msg.GetId(), "request_id", requestID)

	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tileset ID is required")
	}

	err := h.service.DeleteTileset(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.DeleteTilesetResponse{
		Success: true,
	}), nil
}
