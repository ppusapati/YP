package provisioning

import "time"

// ProvisioningStatus represents the current state of tenant provisioning.
type ProvisioningStatus string

const (
	// StatusPending indicates provisioning has not yet started.
	StatusPending ProvisioningStatus = "pending"
	// StatusCreatingRecord indicates the tenant record is being created in the master DB.
	StatusCreatingRecord ProvisioningStatus = "creating_record"
	// StatusCreatingDatabase indicates the tenant database is being created.
	StatusCreatingDatabase ProvisioningStatus = "creating_database"
	// StatusRunningMigrations indicates schema migrations are running.
	StatusRunningMigrations ProvisioningStatus = "running_migrations"
	// StatusSeedingData indicates default data is being seeded.
	StatusSeedingData ProvisioningStatus = "seeding_data"
	// StatusComplete indicates provisioning finished successfully.
	StatusComplete ProvisioningStatus = "complete"
	// StatusFailed indicates provisioning failed at some step.
	StatusFailed ProvisioningStatus = "failed"
	// StatusRollingBack indicates a rollback is in progress after failure.
	StatusRollingBack ProvisioningStatus = "rolling_back"
)

// CreateTenantRequest contains the parameters needed to provision a new tenant.
type CreateTenantRequest struct {
	// Name is the unique human-readable name for the tenant (used as DB name for paid tenants).
	Name string `json:"name"`
	// DisplayName is the friendly display name shown in the UI.
	DisplayName string `json:"display_name"`
	// Region is the geographic region for the tenant's data.
	Region string `json:"region"`
	// Type is the tenant tier: "free" (shared DB) or "paid" (dedicated DB).
	Type string `json:"type"`
	// AdminEmail is the email address for the initial admin user.
	AdminEmail string `json:"admin_email"`
	// AdminName is the display name for the initial admin user.
	AdminName string `json:"admin_name"`
}

// Validate checks that all required fields are present.
func (r *CreateTenantRequest) Validate() error {
	if r.Name == "" {
		return ErrNameRequired
	}
	if r.AdminEmail == "" {
		return ErrAdminEmailRequired
	}
	if r.Type != "" && r.Type != "free" && r.Type != "paid" {
		return ErrInvalidTenantType
	}
	return nil
}

// TenantInfo holds the result of a successful tenant provisioning.
type TenantInfo struct {
	// ID is the unique identifier assigned to the tenant.
	ID string `json:"id"`
	// Name is the tenant's unique name.
	Name string `json:"name"`
	// DisplayName is the tenant's friendly display name.
	DisplayName string `json:"display_name"`
	// Region is the tenant's data region.
	Region string `json:"region"`
	// Type is "free" or "paid".
	Type string `json:"type"`
	// DatabaseName is the name of the tenant's database (same as Name for paid; shared DB name for free).
	DatabaseName string `json:"database_name"`
	// AdminUserID is the ID of the initial admin user created during provisioning.
	AdminUserID string `json:"admin_user_id"`
	// CreatedAt is when the tenant was provisioned.
	CreatedAt time.Time `json:"created_at"`
}

// ProvisioningResult is returned by the provisioner and includes status metadata.
type ProvisioningResult struct {
	// Tenant is the provisioned tenant information.
	Tenant TenantInfo `json:"tenant"`
	// Status is the final provisioning status.
	Status ProvisioningStatus `json:"status"`
	// Steps records the outcome of each provisioning step.
	Steps []StepResult `json:"steps"`
	// Duration is the total provisioning time.
	Duration time.Duration `json:"duration"`
}

// StepResult records the outcome of an individual provisioning step.
type StepResult struct {
	// Name is the step name (e.g., "create_record", "create_database").
	Name string `json:"name"`
	// Status is the step's outcome.
	Status ProvisioningStatus `json:"status"`
	// Duration is how long the step took.
	Duration time.Duration `json:"duration"`
	// Error is the error message if the step failed (empty on success).
	Error string `json:"error,omitempty"`
}

// SeedData holds the default data created during tenant provisioning.
type SeedData struct {
	// AdminUserID is the ID of the seeded admin user.
	AdminUserID string `json:"admin_user_id"`
	// Roles is the list of default role names created.
	Roles []string `json:"roles"`
	// Settings is the map of default settings seeded.
	Settings map[string]string `json:"settings"`
}

// DefaultRoles returns the standard roles seeded for every new tenant.
func DefaultRoles() []string {
	return []string{"admin", "manager", "user", "viewer"}
}

// DefaultSettings returns the standard settings seeded for every new tenant.
func DefaultSettings() map[string]string {
	return map[string]string{
		"locale":          "en",
		"timezone":        "UTC",
		"date_format":     "YYYY-MM-DD",
		"currency":        "USD",
		"max_users":       "10",
		"storage_limit":   "1073741824", // 1 GB in bytes
		"session_timeout": "3600",       // 1 hour in seconds
	}
}
