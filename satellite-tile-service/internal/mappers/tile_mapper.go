package mappers

import (
	"google.golang.org/protobuf/types/known/timestamppb"

	pb "p9e.in/samavaya/agriculture/satellite-tile-service/api/v1"
	tilemodels "p9e.in/samavaya/agriculture/satellite-tile-service/internal/models"
	"p9e.in/samavaya/packages/convert/ptr"
)

// ---- Proto enum <-> Domain enum conversions ----

// ProtoTileFormatToDomain converts a proto TileFormat to the domain TileFormat.
func ProtoTileFormatToDomain(tf pb.TileFormat) tilemodels.TileFormat {
	switch tf {
	case pb.TileFormat_TILE_FORMAT_PNG:
		return tilemodels.TileFormatPNG
	case pb.TileFormat_TILE_FORMAT_JPEG:
		return tilemodels.TileFormatJPEG
	case pb.TileFormat_TILE_FORMAT_WEBP:
		return tilemodels.TileFormatWEBP
	case pb.TileFormat_TILE_FORMAT_MVT:
		return tilemodels.TileFormatMVT
	default:
		return tilemodels.TileFormatUnspecified
	}
}

// DomainTileFormatToProto converts a domain TileFormat to the proto TileFormat.
func DomainTileFormatToProto(tf tilemodels.TileFormat) pb.TileFormat {
	switch tf {
	case tilemodels.TileFormatPNG:
		return pb.TileFormat_TILE_FORMAT_PNG
	case tilemodels.TileFormatJPEG:
		return pb.TileFormat_TILE_FORMAT_JPEG
	case tilemodels.TileFormatWEBP:
		return pb.TileFormat_TILE_FORMAT_WEBP
	case tilemodels.TileFormatMVT:
		return pb.TileFormat_TILE_FORMAT_MVT
	default:
		return pb.TileFormat_TILE_FORMAT_UNSPECIFIED
	}
}

// ProtoTilesetStatusToDomain converts a proto TilesetStatus to the domain TilesetStatus.
func ProtoTilesetStatusToDomain(ts pb.TilesetStatus) tilemodels.TilesetStatus {
	switch ts {
	case pb.TilesetStatus_TILESET_STATUS_QUEUED:
		return tilemodels.TilesetStatusQueued
	case pb.TilesetStatus_TILESET_STATUS_GENERATING:
		return tilemodels.TilesetStatusGenerating
	case pb.TilesetStatus_TILESET_STATUS_COMPLETED:
		return tilemodels.TilesetStatusCompleted
	case pb.TilesetStatus_TILESET_STATUS_FAILED:
		return tilemodels.TilesetStatusFailed
	default:
		return tilemodels.TilesetStatusUnspecified
	}
}

// DomainTilesetStatusToProto converts a domain TilesetStatus to the proto TilesetStatus.
func DomainTilesetStatusToProto(ts tilemodels.TilesetStatus) pb.TilesetStatus {
	switch ts {
	case tilemodels.TilesetStatusQueued:
		return pb.TilesetStatus_TILESET_STATUS_QUEUED
	case tilemodels.TilesetStatusGenerating:
		return pb.TilesetStatus_TILESET_STATUS_GENERATING
	case tilemodels.TilesetStatusCompleted:
		return pb.TilesetStatus_TILESET_STATUS_COMPLETED
	case tilemodels.TilesetStatusFailed:
		return pb.TilesetStatus_TILESET_STATUS_FAILED
	default:
		return pb.TilesetStatus_TILESET_STATUS_UNSPECIFIED
	}
}

// ProtoTileLayerToDomain converts a proto TileLayer to the domain TileLayer.
func ProtoTileLayerToDomain(tl pb.TileLayer) tilemodels.TileLayer {
	switch tl {
	case pb.TileLayer_TILE_LAYER_RGB:
		return tilemodels.TileLayerRGB
	case pb.TileLayer_TILE_LAYER_NDVI:
		return tilemodels.TileLayerNDVI
	case pb.TileLayer_TILE_LAYER_NDWI:
		return tilemodels.TileLayerNDWI
	case pb.TileLayer_TILE_LAYER_EVI:
		return tilemodels.TileLayerEVI
	case pb.TileLayer_TILE_LAYER_STRESS:
		return tilemodels.TileLayerStress
	case pb.TileLayer_TILE_LAYER_FALSE_COLOR:
		return tilemodels.TileLayerFalseColor
	case pb.TileLayer_TILE_LAYER_THERMAL:
		return tilemodels.TileLayerThermal
	default:
		return tilemodels.TileLayerUnspecified
	}
}

// DomainTileLayerToProto converts a domain TileLayer to the proto TileLayer.
func DomainTileLayerToProto(tl tilemodels.TileLayer) pb.TileLayer {
	switch tl {
	case tilemodels.TileLayerRGB:
		return pb.TileLayer_TILE_LAYER_RGB
	case tilemodels.TileLayerNDVI:
		return pb.TileLayer_TILE_LAYER_NDVI
	case tilemodels.TileLayerNDWI:
		return pb.TileLayer_TILE_LAYER_NDWI
	case tilemodels.TileLayerEVI:
		return pb.TileLayer_TILE_LAYER_EVI
	case tilemodels.TileLayerStress:
		return pb.TileLayer_TILE_LAYER_STRESS
	case tilemodels.TileLayerFalseColor:
		return pb.TileLayer_TILE_LAYER_FALSE_COLOR
	case tilemodels.TileLayerThermal:
		return pb.TileLayer_TILE_LAYER_THERMAL
	default:
		return pb.TileLayer_TILE_LAYER_UNSPECIFIED
	}
}

// ---- Domain -> Proto conversions ----

// TilesetToProto converts a domain Tileset to its proto representation.
func TilesetToProto(t *tilemodels.Tileset) *pb.Tileset {
	if t == nil {
		return nil
	}

	tileset := &pb.Tileset{
		Id:              t.UUID,
		TenantId:        t.TenantID,
		FarmId:          t.FarmID,
		ProcessingJobId: t.ProcessingJobID,
		Layer:           DomainTileLayerToProto(t.Layer),
		Format:          DomainTileFormatToProto(t.Format),
		Status:          DomainTilesetStatusToProto(t.Status),
		MinZoom:         t.MinZoom,
		MaxZoom:         t.MaxZoom,
		S3Prefix:        ptr.Deref(t.S3Prefix),
		TotalTiles:      t.TotalTiles,
		BboxGeojson:     ptr.Deref(t.BboxGeoJSON),
		ErrorMessage:    ptr.Deref(t.ErrorMessage),
		CreatedAt:       timestamppb.New(t.CreatedAt),
	}

	if t.AcquisitionDate != nil {
		tileset.AcquisitionDate = timestamppb.New(*t.AcquisitionDate)
	}

	if t.CompletedAt != nil {
		tileset.CompletedAt = timestamppb.New(*t.CompletedAt)
	}

	return tileset
}

// TilesetsToProto converts a slice of domain Tilesets to their proto representations.
func TilesetsToProto(tilesets []tilemodels.Tileset) []*pb.Tileset {
	if tilesets == nil {
		return nil
	}
	result := make([]*pb.Tileset, len(tilesets))
	for i := range tilesets {
		result[i] = TilesetToProto(&tilesets[i])
	}
	return result
}
