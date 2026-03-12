package models

import (
	"encoding/json"
	"time"
)

// SupplyChainEventType represents the type of supply chain event.
type SupplyChainEventType string

const (
	SupplyChainEventTypePlanted   SupplyChainEventType = "PLANTED"
	SupplyChainEventTypeFertilized SupplyChainEventType = "FERTILIZED"
	SupplyChainEventTypeIrrigated SupplyChainEventType = "IRRIGATED"
	SupplyChainEventTypeSprayed   SupplyChainEventType = "SPRAYED"
	SupplyChainEventTypeHarvested SupplyChainEventType = "HARVESTED"
	SupplyChainEventTypeProcessed SupplyChainEventType = "PROCESSED"
	SupplyChainEventTypePackaged  SupplyChainEventType = "PACKAGED"
	SupplyChainEventTypeShipped   SupplyChainEventType = "SHIPPED"
	SupplyChainEventTypeReceived  SupplyChainEventType = "RECEIVED"
	SupplyChainEventTypeSold      SupplyChainEventType = "SOLD"
)

// ValidSupplyChainEventTypes is the set of valid supply chain event types.
var ValidSupplyChainEventTypes = map[SupplyChainEventType]bool{
	SupplyChainEventTypePlanted:    true,
	SupplyChainEventTypeFertilized: true,
	SupplyChainEventTypeIrrigated:  true,
	SupplyChainEventTypeSprayed:    true,
	SupplyChainEventTypeHarvested:  true,
	SupplyChainEventTypeProcessed:  true,
	SupplyChainEventTypePackaged:   true,
	SupplyChainEventTypeShipped:    true,
	SupplyChainEventTypeReceived:   true,
	SupplyChainEventTypeSold:       true,
}

// CertificationType represents the type of certification.
type CertificationType string

const (
	CertificationTypeOrganic            CertificationType = "ORGANIC"
	CertificationTypeGAP                CertificationType = "GAP"
	CertificationTypeFairtrade          CertificationType = "FAIRTRADE"
	CertificationTypeRainforestAlliance CertificationType = "RAINFOREST_ALLIANCE"
	CertificationTypeUSDAOrganic        CertificationType = "USDA_ORGANIC"
	CertificationTypeEUOrganic          CertificationType = "EU_ORGANIC"
)

// ValidCertificationTypes is the set of valid certification types.
var ValidCertificationTypes = map[CertificationType]bool{
	CertificationTypeOrganic:            true,
	CertificationTypeGAP:                true,
	CertificationTypeFairtrade:          true,
	CertificationTypeRainforestAlliance: true,
	CertificationTypeUSDAOrganic:        true,
	CertificationTypeEUOrganic:          true,
}

// CertificationStatus represents the status of a certification.
type CertificationStatus string

const (
	CertificationStatusActive  CertificationStatus = "ACTIVE"
	CertificationStatusExpired CertificationStatus = "EXPIRED"
	CertificationStatusRevoked CertificationStatus = "REVOKED"
	CertificationStatusPending CertificationStatus = "PENDING"
)

// ComplianceStatusType represents the compliance status of a traceability record.
type ComplianceStatusType string

const (
	ComplianceStatusCompliant    ComplianceStatusType = "COMPLIANT"
	ComplianceStatusNonCompliant ComplianceStatusType = "NON_COMPLIANT"
	ComplianceStatusPending      ComplianceStatusType = "PENDING_REVIEW"
)

// TraceabilityRecord is the domain model for a traceability record.
type TraceabilityRecord struct {
	ID               string               `json:"id" db:"id"`
	TenantID         string               `json:"tenant_id" db:"tenant_id"`
	FarmID           string               `json:"farm_id" db:"farm_id"`
	FieldID          string               `json:"field_id" db:"field_id"`
	CropID           string               `json:"crop_id" db:"crop_id"`
	BatchNumber      string               `json:"batch_number" db:"batch_number"`
	ProductType      string               `json:"product_type" db:"product_type"`
	OriginCountry    string               `json:"origin_country" db:"origin_country"`
	OriginRegion     string               `json:"origin_region" db:"origin_region"`
	SeedSource       string               `json:"seed_source" db:"seed_source"`
	PlantingDate     *time.Time           `json:"planting_date" db:"planting_date"`
	HarvestDate      *time.Time           `json:"harvest_date" db:"harvest_date"`
	ProcessingDate   *time.Time           `json:"processing_date" db:"processing_date"`
	PackagingDate    *time.Time           `json:"packaging_date" db:"packaging_date"`
	QRCodeData       string               `json:"qr_code_data" db:"qr_code_data"`
	BlockchainHash   string               `json:"blockchain_hash" db:"blockchain_hash"`
	ChainOfCustody   []string             `json:"chain_of_custody" db:"chain_of_custody"`
	ComplianceStatus ComplianceStatusType `json:"compliance_status" db:"compliance_status"`
	Metadata         json.RawMessage      `json:"metadata" db:"metadata"`
	Version          int64                `json:"version" db:"version"`
	CreatedBy        string               `json:"created_by" db:"created_by"`
	UpdatedBy        string               `json:"updated_by" db:"updated_by"`
	CreatedAt        time.Time            `json:"created_at" db:"created_at"`
	UpdatedAt        time.Time            `json:"updated_at" db:"updated_at"`

	// Loaded associations (not stored directly, populated by service layer)
	SupplyChainEvents []SupplyChainEvent `json:"supply_chain_events,omitempty" db:"-"`
	Certifications    []Certification    `json:"certifications,omitempty" db:"-"`
}

// SupplyChainEvent is the domain model for a supply chain event.
type SupplyChainEvent struct {
	ID               string               `json:"id" db:"id"`
	RecordID         string               `json:"record_id" db:"record_id"`
	EventType        SupplyChainEventType `json:"event_type" db:"event_type"`
	EventTimestamp   time.Time            `json:"event_timestamp" db:"event_timestamp"`
	Location         string               `json:"location" db:"location"`
	Actor            string               `json:"actor" db:"actor"`
	Details          string               `json:"details" db:"details"`
	VerificationHash string               `json:"verification_hash" db:"verification_hash"`
	CreatedAt        time.Time            `json:"created_at" db:"created_at"`
}

// Certification is the domain model for a certification.
type Certification struct {
	ID         string              `json:"id" db:"id"`
	TenantID   string              `json:"tenant_id" db:"tenant_id"`
	RecordID   string              `json:"record_id" db:"record_id"`
	CertType   CertificationType   `json:"cert_type" db:"cert_type"`
	CertNumber string              `json:"cert_number" db:"cert_number"`
	IssuedBy   string              `json:"issued_by" db:"issued_by"`
	IssuedDate *time.Time          `json:"issued_date" db:"issued_date"`
	ExpiryDate *time.Time          `json:"expiry_date" db:"expiry_date"`
	Status     CertificationStatus `json:"status" db:"status"`
	VerifiedBy string              `json:"verified_by" db:"verified_by"`
	VerifiedAt *time.Time          `json:"verified_at" db:"verified_at"`
	Metadata   json.RawMessage     `json:"metadata" db:"metadata"`
	Version    int64               `json:"version" db:"version"`
	CreatedAt  time.Time           `json:"created_at" db:"created_at"`
	UpdatedAt  time.Time           `json:"updated_at" db:"updated_at"`
}

// BatchRecord is the domain model for a batch record.
type BatchRecord struct {
	ID                string          `json:"id" db:"id"`
	TenantID          string          `json:"tenant_id" db:"tenant_id"`
	RecordID          string          `json:"record_id" db:"record_id"`
	BatchNumber       string          `json:"batch_number" db:"batch_number"`
	Quantity          int32           `json:"quantity" db:"quantity"`
	Unit              string          `json:"unit" db:"unit"`
	ProductionDate    *time.Time      `json:"production_date" db:"production_date"`
	ExpiryDate        *time.Time      `json:"expiry_date" db:"expiry_date"`
	StorageConditions string          `json:"storage_conditions" db:"storage_conditions"`
	QualityGrade      string          `json:"quality_grade" db:"quality_grade"`
	Metadata          json.RawMessage `json:"metadata" db:"metadata"`
	Version           int64           `json:"version" db:"version"`
	CreatedAt         time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt         time.Time       `json:"updated_at" db:"updated_at"`
}

// QRCodeRecord is the domain model for a QR code.
type QRCodeRecord struct {
	ID          string     `json:"id" db:"id"`
	RecordID    string     `json:"record_id" db:"record_id"`
	BatchID     string     `json:"batch_id" db:"batch_id"`
	QRData      string     `json:"qr_data" db:"qr_data"`
	QRImageURL  string     `json:"qr_image_url" db:"qr_image_url"`
	ScanURL     string     `json:"scan_url" db:"scan_url"`
	GeneratedAt time.Time  `json:"generated_at" db:"generated_at"`
	ExpiresAt   *time.Time `json:"expires_at" db:"expires_at"`
	IsActive    bool       `json:"is_active" db:"is_active"`
}

// ComplianceReport is the domain model for a compliance report.
type ComplianceReport struct {
	ID              string               `json:"id" db:"id"`
	TenantID        string               `json:"tenant_id" db:"tenant_id"`
	RecordID        string               `json:"record_id" db:"record_id"`
	Status          ComplianceStatusType `json:"status" db:"status"`
	ReportType      string               `json:"report_type" db:"report_type"`
	Findings        []string             `json:"findings" db:"findings"`
	Recommendations []string             `json:"recommendations" db:"recommendations"`
	Auditor         string               `json:"auditor" db:"auditor"`
	AuditDate       *time.Time           `json:"audit_date" db:"audit_date"`
	NextAuditDate   *time.Time           `json:"next_audit_date" db:"next_audit_date"`
	ComplianceScore float64              `json:"compliance_score" db:"compliance_score"`
	Metadata        json.RawMessage      `json:"metadata" db:"metadata"`
	CreatedAt       time.Time            `json:"created_at" db:"created_at"`
}

// CreateRecordInput is the input for creating a traceability record.
type CreateRecordInput struct {
	FarmID         string
	FieldID        string
	CropID         string
	BatchNumber    string
	ProductType    string
	OriginCountry  string
	OriginRegion   string
	SeedSource     string
	PlantingDate   *time.Time
	HarvestDate    *time.Time
	ProcessingDate *time.Time
	PackagingDate  *time.Time
	Metadata       map[string]string
}

// AddSupplyChainEventInput is the input for adding a supply chain event.
type AddSupplyChainEventInput struct {
	RecordID  string
	EventType SupplyChainEventType
	Timestamp time.Time
	Location  string
	Actor     string
	Details   string
}

// CreateCertificationInput is the input for creating a certification.
type CreateCertificationInput struct {
	RecordID   string
	CertType   CertificationType
	CertNumber string
	IssuedBy   string
	IssuedDate *time.Time
	ExpiryDate *time.Time
	Metadata   map[string]string
}

// CreateBatchInput is the input for creating a batch record.
type CreateBatchInput struct {
	RecordID          string
	BatchNumber       string
	Quantity          int32
	Unit              string
	ProductionDate    *time.Time
	ExpiryDate        *time.Time
	StorageConditions string
	QualityGrade      string
	Metadata          map[string]string
}

// GenerateQRCodeInput is the input for generating a QR code.
type GenerateQRCodeInput struct {
	RecordID string
	BatchID  string
	BaseURL  string
}

// GenerateComplianceReportInput is the input for generating a compliance report.
type GenerateComplianceReportInput struct {
	RecordID   string
	ReportType string
	Auditor    string
}

// ListRecordsFilter holds filters for listing traceability records.
type ListRecordsFilter struct {
	FarmID           string
	CropID           string
	ProductType      string
	OriginCountry    string
	ComplianceStatus string
	Search           string
	PageSize         int32
	PageOffset       int32
}

// ListCertificationsFilter holds filters for listing certifications.
type ListCertificationsFilter struct {
	RecordID   string
	CertType   string
	Status     string
	PageSize   int32
	PageOffset int32
}

// ListBatchesFilter holds filters for listing batch records.
type ListBatchesFilter struct {
	RecordID   string
	PageSize   int32
	PageOffset int32
}
