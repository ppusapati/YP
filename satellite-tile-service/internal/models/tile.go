package models

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// TileFormat represents the format of generated tiles.
type TileFormat string

const (
	TileFormatUnspecified TileFormat = ""
	TileFormatPNG        TileFormat = "PNG"
	TileFormatJPEG       TileFormat = "JPEG"
	TileFormatWEBP       TileFormat = "WEBP"
	TileFormatMVT        TileFormat = "MVT"
)

// IsValid checks if the tile format is a valid value.
func (tf TileFormat) IsValid() bool {
	switch tf {
	case TileFormatPNG, TileFormatJPEG, TileFormatWEBP, TileFormatMVT:
		return true
	default:
		return false
	}
}

// ContentType returns the MIME content type for this tile format.
func (tf TileFormat) ContentType() string {
	switch tf {
	case TileFormatPNG:
		return "image/png"
	case TileFormatJPEG:
		return "image/jpeg"
	case TileFormatWEBP:
		return "image/webp"
	case TileFormatMVT:
		return "application/vnd.mapbox-vector-tile"
	default:
		return "application/octet-stream"
	}
}

// TilesetStatus represents the generation status of a tileset.
type TilesetStatus string

const (
	TilesetStatusUnspecified TilesetStatus = ""
	TilesetStatusQueued      TilesetStatus = "QUEUED"
	TilesetStatusGenerating  TilesetStatus = "GENERATING"
	TilesetStatusCompleted   TilesetStatus = "COMPLETED"
	TilesetStatusFailed      TilesetStatus = "FAILED"
)

// IsValid checks if the tileset status is a valid value.
func (ts TilesetStatus) IsValid() bool {
	switch ts {
	case TilesetStatusQueued, TilesetStatusGenerating, TilesetStatusCompleted, TilesetStatusFailed:
		return true
	default:
		return false
	}
}

// TileLayer represents the type of data layer for tiles.
type TileLayer string

const (
	TileLayerUnspecified TileLayer = ""
	TileLayerRGB        TileLayer = "RGB"
	TileLayerNDVI       TileLayer = "NDVI"
	TileLayerNDWI       TileLayer = "NDWI"
	TileLayerEVI        TileLayer = "EVI"
	TileLayerStress     TileLayer = "STRESS"
	TileLayerFalseColor TileLayer = "FALSE_COLOR"
	TileLayerThermal    TileLayer = "THERMAL"
)

// IsValid checks if the tile layer is a valid value.
func (tl TileLayer) IsValid() bool {
	switch tl {
	case TileLayerRGB, TileLayerNDVI, TileLayerNDWI, TileLayerEVI,
		TileLayerStress, TileLayerFalseColor, TileLayerThermal:
		return true
	default:
		return false
	}
}

// Tileset represents a generated set of map tiles in the domain.
type Tileset struct {
	models.BaseModel
	TenantID         string        `json:"tenant_id" db:"tenant_id"`
	FarmID           string        `json:"farm_id" db:"farm_id"`
	ProcessingJobID  string        `json:"processing_job_id" db:"processing_job_id"`
	Layer            TileLayer     `json:"layer" db:"layer"`
	Format           TileFormat    `json:"format" db:"format"`
	Status           TilesetStatus `json:"status" db:"status"`
	MinZoom          int32         `json:"min_zoom" db:"min_zoom"`
	MaxZoom          int32         `json:"max_zoom" db:"max_zoom"`
	S3Prefix         *string       `json:"s3_prefix,omitempty" db:"s3_prefix"`
	TotalTiles       int64         `json:"total_tiles" db:"total_tiles"`
	BboxGeoJSON      *string       `json:"bbox_geojson,omitempty" db:"bbox_geojson"`
	ErrorMessage     *string       `json:"error_message,omitempty" db:"error_message"`
	AcquisitionDate  *time.Time    `json:"acquisition_date,omitempty" db:"acquisition_date"`
	CompletedAt      *time.Time    `json:"completed_at,omitempty" db:"completed_at"`
}

// GetID returns the primary key of the tileset.
func (t *Tileset) GetID() int64 {
	return t.ID
}

// GetUUID returns the ULID identifier of the tileset.
func (t *Tileset) GetUUID() string {
	return t.UUID
}

// ListTilesetsParams holds the filter and pagination parameters for listing tilesets.
type ListTilesetsParams struct {
	TenantID string
	FarmID   *string
	Layer    *TileLayer
	Status   *TilesetStatus
	PageSize int32
	Offset   int32
}
