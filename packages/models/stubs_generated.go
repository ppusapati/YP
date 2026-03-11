package models

import "time"

// ProjectAsset represents an asset allocated to a project.
type ProjectAsset struct {
	ID             string    `json:"id" db:"id"`
	ProjectID      string    `json:"project_id" db:"project_id"`
	EquipmentID    string    `json:"equipment_id" db:"equipment_id"`
	AllocationDate time.Time `json:"allocation_date" db:"allocation_date"`
	StartDate      string    `json:"start_date" db:"start_date"`
	EndDate        string    `json:"end_date" db:"end_date"`
	DailyRate      string    `json:"daily_rate" db:"daily_rate"`
	Status         string    `json:"status" db:"status"`
	CreatedAt      time.Time `json:"created_at" db:"created_at"`
	CreatedBy      string    `json:"created_by" db:"created_by"`
}

// UtilizationRecord represents usage tracking for a project asset.
type UtilizationRecord struct {
	ID             string    `json:"id" db:"id"`
	ProjectAssetID string    `json:"project_asset_id" db:"project_asset_id"`
	UsageDate      string    `json:"usage_date" db:"usage_date"`
	HoursUsed      string    `json:"hours_used" db:"hours_used"`
	UnitsUsed      string    `json:"units_used" db:"units_used"`
	Status         string    `json:"status" db:"status"`
	Notes          string    `json:"notes" db:"notes"`
	CreatedAt      time.Time `json:"created_at" db:"created_at"`
}

// AssetCostRecord represents the cost incurred by a project asset over a period.
type AssetCostRecord struct {
	ID             string    `json:"id" db:"id"`
	ProjectAssetID string    `json:"project_asset_id" db:"project_asset_id"`
	ProjectID      string    `json:"project_id" db:"project_id"`
	DaysUsed       int32     `json:"days_used" db:"days_used"`
	DailyRate      string    `json:"daily_rate" db:"daily_rate"`
	TotalCost      string    `json:"total_cost" db:"total_cost"`
	CostPeriod     string    `json:"cost_period" db:"cost_period"`
	CreatedAt      time.Time `json:"created_at" db:"created_at"`
}

// MaintenanceRecord represents a maintenance event for equipment.
type MaintenanceRecord struct {
	ID              string    `json:"id" db:"id"`
	EquipmentID     string    `json:"equipment_id" db:"equipment_id"`
	MaintenanceType string    `json:"maintenance_type" db:"maintenance_type"`
	ScheduledDate   string    `json:"scheduled_date" db:"scheduled_date"`
	Status          string    `json:"status" db:"status"`
	Cost            string    `json:"cost" db:"cost"`
	Description     string    `json:"description" db:"description"`
	CreatedAt       time.Time `json:"created_at" db:"created_at"`
}

// ServiceProject represents a service-oriented project.
type ServiceProject struct {
	ID            string    `json:"id" db:"id"`
	ProjectCode   string    `json:"project_code" db:"project_code"`
	ProjectName   string    `json:"project_name" db:"project_name"`
	CustomerID    string    `json:"customer_id" db:"customer_id"`
	StartDate     string    `json:"start_date" db:"start_date"`
	EndDate       string    `json:"end_date" db:"end_date"`
	Status        string    `json:"status" db:"status"`
	Description   string    `json:"description" db:"description"`
	EstimatedCost string    `json:"estimated_cost" db:"estimated_cost"`
	CreatedAt     time.Time `json:"created_at" db:"created_at"`
	CreatedBy     string    `json:"created_by" db:"created_by"`
}

// ServiceTask represents a task within a service project.
type ServiceTask struct {
	ID          string    `json:"id" db:"id"`
	TaskCode    string    `json:"task_code" db:"task_code"`
	ProjectID   string    `json:"project_id" db:"project_id"`
	TaskName    string    `json:"task_name" db:"task_name"`
	Status      string    `json:"status" db:"status"`
	Priority    string    `json:"priority" db:"priority"`
	AssignedTo  string    `json:"assigned_to" db:"assigned_to"`
	StartDate   string    `json:"start_date" db:"start_date"`
	EndDate     string    `json:"end_date" db:"end_date"`
	Description string    `json:"description" db:"description"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
}

// ResourceAllocation represents the assignment of a resource to a project.
type ResourceAllocation struct {
	ID                string    `json:"id" db:"id"`
	ProjectID         string    `json:"project_id" db:"project_id"`
	ResourceID        string    `json:"resource_id" db:"resource_id"`
	StartDate         string    `json:"start_date" db:"start_date"`
	EndDate           string    `json:"end_date" db:"end_date"`
	AllocationPercent int32     `json:"allocation_percent" db:"allocation_percent"`
	Role              string    `json:"role" db:"role"`
	CreatedAt         time.Time `json:"created_at" db:"created_at"`
}

// OrderLineItem represents a line item on an order (sales or project).
type OrderLineItem struct {
	ID        string    `json:"id" db:"id"`
	OrderID   string    `json:"order_id" db:"order_id"`
	LineNo    string    `json:"line_no" db:"line_no"`
	ProductID string    `json:"product_id" db:"product_id"`
	Quantity  float64   `json:"quantity" db:"quantity"`
	UnitPrice string    `json:"unit_price" db:"unit_price"`
	LineTotal string    `json:"line_total" db:"line_total"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
}

// ProjectOrder represents a work order associated with a project.
type ProjectOrder struct {
	ID          string    `json:"id" db:"id"`
	OrderNo     string    `json:"order_no" db:"order_no"`
	ProjectID   string    `json:"project_id" db:"project_id"`
	QuotationID string    `json:"quotation_id" db:"quotation_id"`
	OrderDate   time.Time `json:"order_date" db:"order_date"`
	Status      string    `json:"status" db:"status"`
	TotalAmount string    `json:"total_amount" db:"total_amount"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	CreatedBy   string    `json:"created_by" db:"created_by"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
	UpdatedBy   string    `json:"updated_by" db:"updated_by"`
}

// ProjectQuotation represents a quotation for a project.
type ProjectQuotation struct {
	ID            string    `json:"id" db:"id"`
	QuotationNo   string    `json:"quotation_no" db:"quotation_no"`
	ProjectID     string    `json:"project_id" db:"project_id"`
	QuotationDate time.Time `json:"quotation_date" db:"quotation_date"`
	ValidUntil    time.Time `json:"valid_until" db:"valid_until"`
	Status        string    `json:"status" db:"status"`
	TotalAmount   string    `json:"total_amount" db:"total_amount"`
	CreatedAt     time.Time `json:"created_at" db:"created_at"`
	CreatedBy     string    `json:"created_by" db:"created_by"`
	UpdatedAt     time.Time `json:"updated_at" db:"updated_at"`
	UpdatedBy     string    `json:"updated_by" db:"updated_by"`
}

// QuotationLineItem represents a line item on a quotation.
type QuotationLineItem struct {
	ID            string    `json:"id" db:"id"`
	QuotationID   string    `json:"quotation_id" db:"quotation_id"`
	LineNo        string    `json:"line_no" db:"line_no"`
	Description   string    `json:"description" db:"description"`
	Quantity      float64   `json:"quantity" db:"quantity"`
	UnitPrice     string    `json:"unit_price" db:"unit_price"`
	LineTotal     string    `json:"line_total" db:"line_total"`
	Specification string    `json:"specification" db:"specification"`
	CreatedAt     time.Time `json:"created_at" db:"created_at"`
}

// OrderProgress tracks the progress of an order over time.
type OrderProgress struct {
	ID                string    `json:"id" db:"id"`
	OrderID           string    `json:"order_id" db:"order_id"`
	ProgressDate      time.Time `json:"progress_date" db:"progress_date"`
	CompletionPercent float64   `json:"completion_percent" db:"completion_percent"`
	AmountBilledToDate float64  `json:"amount_billed_to_date" db:"amount_billed_to_date"`
	RemainingAmount   float64   `json:"remaining_amount" db:"remaining_amount"`
	Notes             string    `json:"notes" db:"notes"`
	CreatedAt         time.Time `json:"created_at" db:"created_at"`
	CreatedBy         string    `json:"created_by" db:"created_by"`
}

// POLineItem represents a line item on a purchase order.
type POLineItem struct {
	ID        string    `json:"id" db:"id"`
	POID      string    `json:"po_id" db:"po_id"`
	LineNo    string    `json:"line_no" db:"line_no"`
	ProductID string    `json:"product_id" db:"product_id"`
	Quantity  float64   `json:"quantity" db:"quantity"`
	UnitPrice string    `json:"unit_price" db:"unit_price"`
	LineTotal string    `json:"line_total" db:"line_total"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
}

// ProjectPOLineItem represents a line item on a project purchase order.
type ProjectPOLineItem struct {
	ID          string    `json:"id" db:"id"`
	ProjectPOID string    `json:"project_po_id" db:"project_po_id"`
	LineNo      string    `json:"line_no" db:"line_no"`
	Description string    `json:"description" db:"description"`
	Quantity    float64   `json:"quantity" db:"quantity"`
	UnitPrice   string    `json:"unit_price" db:"unit_price"`
	LineTotal   string    `json:"line_total" db:"line_total"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
}

// ProjectPurchaseOrder represents a purchase order for a project.
type ProjectPurchaseOrder struct {
	ID          string    `json:"id" db:"id"`
	PONumber    string    `json:"po_number" db:"po_number"`
	ProjectID   string    `json:"project_id" db:"project_id"`
	VendorID    string    `json:"vendor_id" db:"vendor_id"`
	PODate      time.Time `json:"po_date" db:"po_date"`
	Status      string    `json:"status" db:"status"`
	TotalAmount string    `json:"total_amount" db:"total_amount"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	CreatedBy   string    `json:"created_by" db:"created_by"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
	UpdatedBy   string    `json:"updated_by" db:"updated_by"`
}

// VendorContract represents a contract between a vendor and a project.
type VendorContract struct {
	ID           string    `json:"id" db:"id"`
	VendorID     string    `json:"vendor_id" db:"vendor_id"`
	ProjectID    string    `json:"project_id" db:"project_id"`
	ContractDate time.Time `json:"contract_date" db:"contract_date"`
	Status       string    `json:"status" db:"status"`
	PaymentTerms string    `json:"payment_terms" db:"payment_terms"`
	CreatedAt    time.Time `json:"created_at" db:"created_at"`
	CreatedBy    string    `json:"created_by" db:"created_by"`
}

// FieldInventoryItem represents an inventory item available at a field location.
type FieldInventoryItem struct {
	ItemID       string  `json:"item_id" db:"item_id"`
	ItemCode     string  `json:"item_code" db:"item_code"`
	ItemName     string  `json:"item_name" db:"item_name"`
	AvailableQty float64 `json:"available_qty" db:"available_qty"`
	AllocatedQty float64 `json:"allocated_qty" db:"allocated_qty"`
	ConsumedQty  float64 `json:"consumed_qty" db:"consumed_qty"`
	UOM          string  `json:"uom" db:"uom"`
	ReorderLevel float64 `json:"reorder_level" db:"reorder_level"`
	BinLocation  string  `json:"bin_location" db:"bin_location"`
	LocationID   string  `json:"location_id" db:"location_id"`
}

// ProjectMaterialStatus represents the status of materials in a project context.
type ProjectMaterialStatus int32

const (
	ProjectMaterialStatusUnspecified ProjectMaterialStatus = 0
	ProjectMaterialStatusDraft      ProjectMaterialStatus = 1
	ProjectMaterialStatusApproved   ProjectMaterialStatus = 2
	ProjectMaterialStatusActive     ProjectMaterialStatus = 3
	ProjectMaterialStatusCompleted  ProjectMaterialStatus = 4
	ProjectMaterialStatusCancelled  ProjectMaterialStatus = 5
)

// Equipment represents a piece of equipment/asset in the system.
type Equipment struct {
	ID                   string                 `json:"id" db:"id"`
	TenantID             string                 `json:"tenant_id" db:"tenant_id"`
	CompanyID            string                 `json:"company_id" db:"company_id"`
	BranchID             string                 `json:"branch_id" db:"branch_id"`
	EquipmentCode        string                 `json:"equipment_code" db:"equipment_code"`
	EquipmentName        string                 `json:"equipment_name" db:"equipment_name"`
	Description          *string                `json:"description,omitempty" db:"description"`
	CategoryID           string                 `json:"category_id" db:"category_id"`
	Manufacturer         *string                `json:"manufacturer,omitempty" db:"manufacturer"`
	ModelNumber          *string                `json:"model_number,omitempty" db:"model_number"`
	SerialNumber         *string                `json:"serial_number,omitempty" db:"serial_number"`
	Specifications       map[string]interface{} `json:"specifications,omitempty"`
	PurchaseDate         *time.Time             `json:"purchase_date,omitempty" db:"purchase_date"`
	PurchaseCost         float64                `json:"purchase_cost" db:"purchase_cost"`
	WarrantyExpiry       *time.Time             `json:"warranty_expiry,omitempty" db:"warranty_expiry"`
	LocationID           *string                `json:"location_id,omitempty" db:"location_id"`
	DepartmentID         *string                `json:"department_id,omitempty" db:"department_id"`
	CustodianID          *string                `json:"custodian_id,omitempty" db:"custodian_id"`
	Status               string                 `json:"status" db:"status"`
	LastCalibrationDate  *time.Time             `json:"last_calibration_date,omitempty" db:"last_calibration_date"`
	NextCalibrationDate  *time.Time             `json:"next_calibration_date,omitempty" db:"next_calibration_date"`
	AssetID              *string                `json:"asset_id,omitempty" db:"asset_id"`
	CustomFields         map[string]interface{} `json:"custom_fields,omitempty"`
	CreatedAt            time.Time              `json:"created_at" db:"created_at"`
	CreatedBy            string                 `json:"created_by" db:"created_by"`
	UpdatedAt            time.Time              `json:"updated_at" db:"updated_at"`
	UpdatedBy            *string                `json:"updated_by,omitempty" db:"updated_by"`
	DeletedAt            *time.Time             `json:"deleted_at,omitempty" db:"deleted_at"`
}

// DepreciationSchedule represents a depreciation schedule entry for an asset.
type DepreciationSchedule struct {
	ID                      string     `json:"id" db:"id"`
	TenantID                string     `json:"tenant_id" db:"tenant_id"`
	CompanyID               string     `json:"company_id" db:"company_id"`
	BranchID                string     `json:"branch_id" db:"branch_id"`
	AssetID                 string     `json:"asset_id" db:"asset_id"`
	SetupID                 string     `json:"setup_id" db:"setup_id"`
	PeriodNumber            int32      `json:"period_number" db:"period_number"`
	PeriodStart             *time.Time `json:"period_start,omitempty" db:"period_start"`
	PeriodEnd               *time.Time `json:"period_end,omitempty" db:"period_end"`
	OpeningValue            float64    `json:"opening_value" db:"opening_value"`
	DepreciationAmount      float64    `json:"depreciation_amount" db:"depreciation_amount"`
	AccumulatedDepreciation float64    `json:"accumulated_depreciation" db:"accumulated_depreciation"`
	ClosingValue            float64    `json:"closing_value" db:"closing_value"`
	IsProcessed             bool       `json:"is_processed" db:"is_processed"`
	DepreciationRunID       *string    `json:"depreciation_run_id,omitempty" db:"depreciation_run_id"`
	ProcessedAt             *time.Time `json:"processed_at,omitempty" db:"processed_at"`
	CreatedAt               time.Time  `json:"created_at" db:"created_at"`
	CreatedBy               string     `json:"created_by" db:"created_by"`
	UpdatedAt               time.Time  `json:"updated_at" db:"updated_at"`
	UpdatedBy               *string    `json:"updated_by,omitempty" db:"updated_by"`
	DeletedAt               *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
	DeletedBy               *string    `json:"deleted_by,omitempty" db:"deleted_by"`
}

// SalesOrder represents a sales order in the system.
type SalesOrder struct {
	ID                    string     `json:"id" db:"id"`
	TenantID              string     `json:"tenant_id" db:"tenant_id"`
	CompanyID             string     `json:"company_id" db:"company_id"`
	BranchID              string     `json:"branch_id" db:"branch_id"`
	OrderNumber           string     `json:"order_number" db:"order_number"`
	OrderType             string     `json:"order_type" db:"order_type"`
	Status                string     `json:"status" db:"status"`
	CustomerID            string     `json:"customer_id" db:"customer_id"`
	CustomerName          *string    `json:"customer_name,omitempty" db:"customer_name"`
	BillingAddressID      *string    `json:"billing_address_id,omitempty" db:"billing_address_id"`
	ShippingAddressID     *string    `json:"shipping_address_id,omitempty" db:"shipping_address_id"`
	OrderDate             *time.Time `json:"order_date,omitempty" db:"order_date"`
	RequestedDeliveryDate *time.Time `json:"requested_delivery_date,omitempty" db:"requested_delivery_date"`
	PromisedDeliveryDate  *time.Time `json:"promised_delivery_date,omitempty" db:"promised_delivery_date"`
	CurrencyID            *string    `json:"currency_id,omitempty" db:"currency_id"`
	Subtotal              float64    `json:"subtotal" db:"subtotal"`
	DiscountAmount        float64    `json:"discount_amount" db:"discount_amount"`
	TaxAmount             float64    `json:"tax_amount" db:"tax_amount"`
	ShippingAmount        float64    `json:"shipping_amount" db:"shipping_amount"`
	TotalAmount           float64    `json:"total_amount" db:"total_amount"`
	QuoteID               *string    `json:"quote_id,omitempty" db:"quote_id"`
	IsActive              bool       `json:"is_active" db:"is_active"`
	IsDeleted             bool       `json:"is_deleted" db:"is_deleted"`
	CreatedAt             time.Time  `json:"created_at" db:"created_at"`
	CreatedBy             string     `json:"created_by" db:"created_by"`
	UpdatedAt             time.Time  `json:"updated_at" db:"updated_at"`
	UpdatedBy             *string    `json:"updated_by,omitempty" db:"updated_by"`
	DeletedAt             *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
	DeletedBy             *string    `json:"deleted_by,omitempty" db:"deleted_by"`
}

// PurchaseOrder represents a purchase order in the system.
type PurchaseOrder struct {
	ID                   string     `json:"id" db:"id"`
	TenantID             string     `json:"tenant_id" db:"tenant_id"`
	CompanyID            string     `json:"company_id" db:"company_id"`
	BranchID             string     `json:"branch_id" db:"branch_id"`
	PONumber             string     `json:"po_number" db:"po_number"`
	PODate               *time.Time `json:"po_date,omitempty" db:"po_date"`
	RevisionNumber       int32      `json:"revision_number" db:"revision_number"`
	VendorID             string     `json:"vendor_id" db:"vendor_id"`
	VendorName           string     `json:"vendor_name" db:"vendor_name"`
	VendorContactID      *string    `json:"vendor_contact_id,omitempty" db:"vendor_contact_id"`
	ShipToAddressID      *string    `json:"ship_to_address_id,omitempty" db:"ship_to_address_id"`
	BillToAddressID      *string    `json:"bill_to_address_id,omitempty" db:"bill_to_address_id"`
	PaymentTerms         *string    `json:"payment_terms,omitempty" db:"payment_terms"`
	DeliveryTerms        *string    `json:"delivery_terms,omitempty" db:"delivery_terms"`
	Incoterms            *string    `json:"incoterms,omitempty" db:"incoterms"`
	CurrencyCode         string     `json:"currency_code" db:"currency_code"`
	ExchangeRate         float64    `json:"exchange_rate" db:"exchange_rate"`
	ExpectedDeliveryDate *time.Time `json:"expected_delivery_date,omitempty" db:"expected_delivery_date"`
	ValidUntil           *time.Time `json:"valid_until,omitempty" db:"valid_until"`
	Subtotal             float64    `json:"subtotal" db:"subtotal"`
	DiscountAmount       float64    `json:"discount_amount" db:"discount_amount"`
	TaxAmount            float64    `json:"tax_amount" db:"tax_amount"`
	FreightAmount        float64    `json:"freight_amount" db:"freight_amount"`
	OtherCharges         float64    `json:"other_charges" db:"other_charges"`
	TotalAmount          float64    `json:"total_amount" db:"total_amount"`
	RequisitionID        *string    `json:"requisition_id,omitempty" db:"requisition_id"`
	RfqID                *string    `json:"rfq_id,omitempty" db:"rfq_id"`
	ContractID           *string    `json:"contract_id,omitempty" db:"contract_id"`
	Status               string     `json:"status" db:"status"`
	ApprovalStatus       *string    `json:"approval_status,omitempty" db:"approval_status"`
	IsBlanketOrder       *bool      `json:"is_blanket_order,omitempty" db:"is_blanket_order"`
	InternalNotes        *string    `json:"internal_notes,omitempty" db:"internal_notes"`
	VendorNotes          *string    `json:"vendor_notes,omitempty" db:"vendor_notes"`
	TermsConditions      *string    `json:"terms_conditions,omitempty" db:"terms_conditions"`
	ApprovedBy           *string    `json:"approved_by,omitempty" db:"approved_by"`
	ApprovedAt           *time.Time `json:"approved_at,omitempty" db:"approved_at"`
	CreatedAt            *time.Time `json:"created_at,omitempty" db:"created_at"`
	CreatedBy            string     `json:"created_by" db:"created_by"`
	UpdatedAt            *time.Time `json:"updated_at,omitempty" db:"updated_at"`
	UpdatedBy            *string    `json:"updated_by,omitempty" db:"updated_by"`
}

// GoodsReceipt represents a goods receipt for a purchase order.
type GoodsReceipt struct {
	ID               string     `json:"id" db:"id"`
	TenantID         string     `json:"tenant_id" db:"tenant_id"`
	CompanyID        string     `json:"company_id" db:"company_id"`
	BranchID         string     `json:"branch_id" db:"branch_id"`
	GRNNumber        string     `json:"grn_number" db:"grn_number"`
	POID             string     `json:"po_id" db:"po_id"`
	ReceiptDate      *time.Time `json:"receipt_date,omitempty" db:"receipt_date"`
	ReceivedBy       string     `json:"received_by" db:"received_by"`
	WarehouseID      *string    `json:"warehouse_id,omitempty" db:"warehouse_id"`
	Status           string     `json:"status" db:"status"`
	InspectionStatus *string    `json:"inspection_status,omitempty" db:"inspection_status"`
	Notes            *string    `json:"notes,omitempty" db:"notes"`
	CreatedAt        *time.Time `json:"created_at,omitempty" db:"created_at"`
	CreatedBy        string     `json:"created_by" db:"created_by"`
	UpdatedAt        *time.Time `json:"updated_at,omitempty" db:"updated_at"`
	UpdatedBy        *string    `json:"updated_by,omitempty" db:"updated_by"`
}

// ProjectMilestone represents a milestone within a project.
type ProjectMilestone struct {
	ID                 string    `json:"id" db:"id"`
	TenantID           string    `json:"tenant_id" db:"tenant_id"`
	CompanyID          string    `json:"company_id" db:"company_id"`
	BranchID           string    `json:"branch_id" db:"branch_id"`
	ProjectID          string    `json:"project_id" db:"project_id"`
	MilestoneCode      string    `json:"milestone_code" db:"milestone_code"`
	MilestoneName      string    `json:"milestone_name" db:"milestone_name"`
	Description        string    `json:"description" db:"description"`
	MilestoneType      string    `json:"milestone_type" db:"milestone_type"`
	SequenceNumber     int32     `json:"sequence_number" db:"sequence_number"`
	PlannedDate        time.Time `json:"planned_date" db:"planned_date"`
	ActualDate         time.Time `json:"actual_date" db:"actual_date"`
	Status             string    `json:"status" db:"status"`
	IsPaymentMilestone bool      `json:"is_payment_milestone" db:"is_payment_milestone"`
	PaymentPercent     float64   `json:"payment_percent" db:"payment_percent"`
	PaymentAmount      float64   `json:"payment_amount" db:"payment_amount"`
	IsBillable         bool      `json:"is_billable" db:"is_billable"`
	CompletionCriteria string    `json:"completion_criteria" db:"completion_criteria"`
	Notes              string    `json:"notes" db:"notes"`
	CompletedBy        string    `json:"completed_by" db:"completed_by"`
	IsActive           bool      `json:"is_active" db:"is_active"`
	IsDeleted          bool      `json:"is_deleted" db:"is_deleted"`
	CreatedAt          time.Time `json:"created_at" db:"created_at"`
	CreatedBy          string    `json:"created_by" db:"created_by"`
	UpdatedAt          time.Time `json:"updated_at" db:"updated_at"`
	UpdatedBy          string    `json:"updated_by" db:"updated_by"`
}
