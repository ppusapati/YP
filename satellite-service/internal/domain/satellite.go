package domain

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

type SatelliteProvider string

const (
	SatelliteProviderSentinel2 SatelliteProvider = "SENTINEL2"
	SatelliteProviderLandsat8  SatelliteProvider = "LANDSAT8"
	SatelliteProviderPlanet    SatelliteProvider = "PLANET"
	SatelliteProviderCustom    SatelliteProvider = "CUSTOM"
)

func (s SatelliteProvider) IsValid() bool {
	switch s {
	case SatelliteProviderSentinel2, SatelliteProviderLandsat8,
		SatelliteProviderPlanet, SatelliteProviderCustom:
		return true
	}
	return false
}

type SpectralBand string

const (
	SpectralBandRed     SpectralBand = "RED"
	SpectralBandGreen   SpectralBand = "GREEN"
	SpectralBandBlue    SpectralBand = "BLUE"
	SpectralBandNIR     SpectralBand = "NIR"
	SpectralBandSWIR    SpectralBand = "SWIR"
	SpectralBandRedEdge SpectralBand = "REDEDGE"
)

type ProcessingStatus string

const (
	ProcessingStatusPending    ProcessingStatus = "PENDING"
	ProcessingStatusProcessing ProcessingStatus = "PROCESSING"
	ProcessingStatusCompleted  ProcessingStatus = "COMPLETED"
	ProcessingStatusFailed     ProcessingStatus = "FAILED"
)

func (p ProcessingStatus) IsValid() bool {
	switch p {
	case ProcessingStatusPending, ProcessingStatusProcessing,
		ProcessingStatusCompleted, ProcessingStatusFailed:
		return true
	}
	return false
}

func (p ProcessingStatus) IsTerminal() bool {
	return p == ProcessingStatusCompleted || p == ProcessingStatusFailed
}

type StressType string

const (
	StressTypeWater    StressType = "WATER"
	StressTypeNutrient StressType = "NUTRIENT"
	StressTypeDisease  StressType = "DISEASE"
	StressTypePest     StressType = "PEST"
)

func (s StressType) IsValid() bool {
	switch s {
	case StressTypeWater, StressTypeNutrient, StressTypeDisease, StressTypePest:
		return true
	}
	return false
}

type IndexType string

const (
	IndexTypeNDVI IndexType = "NDVI"
	IndexTypeNDWI IndexType = "NDWI"
	IndexTypeEVI  IndexType = "EVI"
)

func (i IndexType) IsValid() bool {
	switch i {
	case IndexTypeNDVI, IndexTypeNDWI, IndexTypeEVI:
		return true
	}
	return false
}

type TrendDirection string

const (
	TrendDirectionIncreasing TrendDirection = "increasing"
	TrendDirectionDecreasing TrendDirection = "decreasing"
	TrendDirectionStable     TrendDirection = "stable"
)

// ---------------------------------------------------------------------------
// Domain Models
// ---------------------------------------------------------------------------

// BoundingBox represents a geospatial bounding box (WGS84).
type BoundingBox struct {
	MinLat float64 `json:"min_lat" db:"min_lat"`
	MinLon float64 `json:"min_lon" db:"min_lon"`
	MaxLat float64 `json:"max_lat" db:"max_lat"`
	MaxLon float64 `json:"max_lon" db:"max_lon"`
}

// IsValid checks whether the bounding box coordinates are sensible.
func (b BoundingBox) IsValid() bool {
	return b.MinLat >= -90 && b.MinLat <= 90 &&
		b.MaxLat >= -90 && b.MaxLat <= 90 &&
		b.MinLon >= -180 && b.MinLon <= 180 &&
		b.MaxLon >= -180 && b.MaxLon <= 180 &&
		b.MinLat < b.MaxLat && b.MinLon < b.MaxLon
}

// SatelliteImage represents an acquired satellite image.
type SatelliteImage struct {
	models.BaseModel
	TenantID          string            `json:"tenant_id" db:"tenant_id"`
	FieldID           string            `json:"field_id" db:"field_id"`
	FarmID            string            `json:"farm_id" db:"farm_id"`
	SatelliteProvider SatelliteProvider `json:"satellite_provider" db:"satellite_provider"`
	AcquisitionDate   time.Time         `json:"acquisition_date" db:"acquisition_date"`
	CloudCoverPct     float64           `json:"cloud_cover_pct" db:"cloud_cover_pct"`
	ResolutionMeters  float64           `json:"resolution_meters" db:"resolution_meters"`
	Bands             []string          `json:"bands" db:"bands"`
	Bbox              *BoundingBox      `json:"bbox,omitempty"`
	ImageURL          string            `json:"image_url" db:"image_url"`
	ProcessingStatus  ProcessingStatus  `json:"processing_status" db:"processing_status"`
	Version           int32             `json:"version" db:"version"`
}

// VegetationIndex holds computed spectral index values for an image.
type VegetationIndex struct {
	models.BaseModel
	TenantID   string    `json:"tenant_id" db:"tenant_id"`
	ImageID    string    `json:"image_id" db:"image_id"`
	FieldID    string    `json:"field_id" db:"field_id"`
	IndexType  IndexType `json:"index_type" db:"index_type"`
	MinValue   float64   `json:"min_value" db:"min_value"`
	MaxValue   float64   `json:"max_value" db:"max_value"`
	MeanValue  float64   `json:"mean_value" db:"mean_value"`
	StdDev     float64   `json:"std_dev" db:"std_dev"`
	RasterURL  string    `json:"raster_url" db:"raster_url"`
	ComputedAt time.Time `json:"computed_at" db:"computed_at"`
	Version    int32     `json:"version" db:"version"`
}

// CropStressAlert records a detected crop stress event.
type CropStressAlert struct {
	models.BaseModel
	TenantID        string       `json:"tenant_id" db:"tenant_id"`
	FieldID         string       `json:"field_id" db:"field_id"`
	ImageID         string       `json:"image_id" db:"image_id"`
	StressDetected  bool         `json:"stress_detected" db:"stress_detected"`
	StressType      StressType   `json:"stress_type" db:"stress_type"`
	StressSeverity  float64      `json:"stress_severity" db:"stress_severity"`
	AffectedAreaPct float64      `json:"affected_area_pct" db:"affected_area_pct"`
	Description     string       `json:"description" db:"description"`
	Recommendation  string       `json:"recommendation" db:"recommendation"`
	AffectedBbox    *BoundingBox `json:"affected_bbox,omitempty"`
	DetectedAt      time.Time    `json:"detected_at" db:"detected_at"`
	Version         int32        `json:"version" db:"version"`
}

// TemporalDataPoint is a single observation in a time series.
type TemporalDataPoint struct {
	Date      time.Time `json:"date"`
	MeanValue float64   `json:"mean_value"`
	MinValue  float64   `json:"min_value"`
	MaxValue  float64   `json:"max_value"`
}

// TemporalAnalysis captures trend analysis over a date range.
type TemporalAnalysis struct {
	models.BaseModel
	TenantID       string              `json:"tenant_id" db:"tenant_id"`
	FieldID        string              `json:"field_id" db:"field_id"`
	IndexType      IndexType           `json:"index_type" db:"index_type"`
	StartDate      time.Time           `json:"start_date" db:"start_date"`
	EndDate        time.Time           `json:"end_date" db:"end_date"`
	DataPoints     []TemporalDataPoint `json:"data_points"`
	TrendSlope     float64             `json:"trend_slope" db:"trend_slope"`
	TrendDirection TrendDirection      `json:"trend_direction" db:"trend_direction"`
	ChangePct      float64             `json:"change_pct" db:"change_pct"`
	Version        int32               `json:"version" db:"version"`
}

// SatelliteTask tracks an asynchronous processing task.
type SatelliteTask struct {
	models.BaseModel
	TenantID     string           `json:"tenant_id" db:"tenant_id"`
	FieldID      string           `json:"field_id" db:"field_id"`
	TaskType     string           `json:"task_type" db:"task_type"`
	Status       ProcessingStatus `json:"status" db:"status"`
	InputImageID string           `json:"input_image_id" db:"input_image_id"`
	ResultID     string           `json:"result_id" db:"result_id"`
	ErrorMessage string           `json:"error_message" db:"error_message"`
	RetryCount   int32            `json:"retry_count" db:"retry_count"`
	Version      int32            `json:"version" db:"version"`
}

// ---------------------------------------------------------------------------
// Band-value helper used during index computation
// ---------------------------------------------------------------------------

// BandValues holds reflectance values per pixel for spectral computations.
type BandValues struct {
	Red     float64
	Green   float64
	Blue    float64
	NIR     float64
	SWIR    float64
	RedEdge float64
}

// ComputeNDVI returns the Normalized Difference Vegetation Index.
// NDVI = (NIR - Red) / (NIR + Red)
func (b BandValues) ComputeNDVI() float64 {
	denom := b.NIR + b.Red
	if denom == 0 {
		return 0
	}
	return (b.NIR - b.Red) / denom
}

// ComputeNDWI returns the Normalized Difference Water Index.
// NDWI = (Green - NIR) / (Green + NIR)
func (b BandValues) ComputeNDWI() float64 {
	denom := b.Green + b.NIR
	if denom == 0 {
		return 0
	}
	return (b.Green - b.NIR) / denom
}

// ComputeEVI returns the Enhanced Vegetation Index.
// EVI = G * (NIR - Red) / (NIR + C1*Red - C2*Blue + L)
// Standard coefficients: G=2.5, C1=6, C2=7.5, L=1
func (b BandValues) ComputeEVI() float64 {
	const (
		G  = 2.5
		C1 = 6.0
		C2 = 7.5
		L  = 1.0
	)
	denom := b.NIR + C1*b.Red - C2*b.Blue + L
	if denom == 0 {
		return 0
	}
	evi := G * (b.NIR - b.Red) / denom
	// Clamp EVI to valid range [-1, 1]
	if evi > 1 {
		return 1
	}
	if evi < -1 {
		return -1
	}
	return evi
}
