// Package provisioning orchestrates new tenant setup: creating the tenant record,
// provisioning databases, running migrations, and seeding default data.
package provisioning

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"
)

// Sentinel errors returned by the provisioner.
var (
	ErrNameRequired       = errors.New("tenant name is required")
	ErrAdminEmailRequired = errors.New("admin email is required")
	ErrInvalidTenantType  = errors.New("tenant type must be 'free' or 'paid'")
	ErrTenantExists       = errors.New("tenant with this name already exists")
	ErrProvisioningFailed = errors.New("tenant provisioning failed")
)

// TenantStore persists tenant records in the master database.
type TenantStore interface {
	// CreateTenant inserts a new tenant record. Returns ErrTenantExists if the name is taken.
	CreateTenant(ctx context.Context, cfg saas.TenantConfig) error
	// GetByNameOrId retrieves a tenant by name or ID.
	GetByNameOrId(ctx context.Context, nameOrId string) (*saas.TenantConfig, error)
	// UpdateStatus sets the tenant's active flag.
	UpdateStatus(ctx context.Context, tenantID string, isActive bool) error
	// DeleteTenant removes a tenant record (used during rollback).
	DeleteTenant(ctx context.Context, tenantID string) error
}

// DatabaseCreator creates tenant-specific databases.
type DatabaseCreator interface {
	// CreateDatabase creates a new database with the given name.
	CreateDatabase(ctx context.Context, databaseName string) error
	// DropDatabase removes a database (used during rollback).
	DropDatabase(ctx context.Context, databaseName string) error
}

// PoolProvider returns a connection pool to a tenant's database by name.
type PoolProvider interface {
	// GetPool returns a pgxpool.Pool connected to the named database.
	GetPool(ctx context.Context, databaseName string) (*pgxpool.Pool, error)
}

// DataSeeder seeds default data into a newly provisioned tenant database.
type DataSeeder interface {
	// Seed inserts default data (admin user, roles, settings) and returns seed metadata.
	Seed(ctx context.Context, pool *pgxpool.Pool, req CreateTenantRequest, tenantID string) (*SeedData, error)
}

// TenantProvisioner orchestrates the full lifecycle of creating a new tenant.
type TenantProvisioner struct {
	masterPool  *pgxpool.Pool
	store       TenantStore
	dbCreator   DatabaseCreator
	poolProvider PoolProvider
	migrator    MigrationRunner
	seeder      DataSeeder
	sharedDBName string
}

// ProvisionerOption is a functional option for configuring TenantProvisioner.
type ProvisionerOption func(*TenantProvisioner)

// WithSharedDBName sets the shared database name for free-tier tenants.
func WithSharedDBName(name string) ProvisionerOption {
	return func(p *TenantProvisioner) {
		p.sharedDBName = name
	}
}

// NewTenantProvisioner creates a new provisioner with the required dependencies.
func NewTenantProvisioner(
	masterPool *pgxpool.Pool,
	store TenantStore,
	dbCreator DatabaseCreator,
	poolProvider PoolProvider,
	migrator MigrationRunner,
	seeder DataSeeder,
	opts ...ProvisionerOption,
) *TenantProvisioner {
	p := &TenantProvisioner{
		masterPool:   masterPool,
		store:        store,
		dbCreator:    dbCreator,
		poolProvider: poolProvider,
		migrator:     migrator,
		seeder:       seeder,
		sharedDBName: "shared",
	}
	for _, opt := range opts {
		opt(p)
	}
	return p
}

// Provision executes the full tenant provisioning workflow:
//  1. Validate the request
//  2. Create tenant record in master DB
//  3. Create tenant-specific database (paid tier only)
//  4. Run migrations for all services
//  5. Seed default data (admin user, roles, settings)
//
// On failure at any step, previous steps are rolled back.
func (p *TenantProvisioner) Provision(ctx context.Context, req CreateTenantRequest) (*ProvisioningResult, error) {
	start := time.Now()
	result := &ProvisioningResult{
		Status: StatusPending,
	}

	// Step 0: Validate request
	if err := req.Validate(); err != nil {
		result.Status = StatusFailed
		return result, err
	}

	// Determine tenant type, default to free
	tenantType := saas.TenantTypeFree
	if req.Type == "paid" {
		tenantType = saas.TenantTypePaid
	}

	tenantID := uuid.New().String()

	// Step 1: Create tenant record in master DB
	step1Start := time.Now()
	result.Status = StatusCreatingRecord

	tenantCfg := saas.TenantConfig{
		ID:       tenantID,
		Name:     req.Name,
		Region:   req.Region,
		Type:     tenantType,
		IsActive: false, // activated only after full provisioning
	}

	if err := p.store.CreateTenant(ctx, tenantCfg); err != nil {
		result.Status = StatusFailed
		result.Steps = append(result.Steps, StepResult{
			Name:     "create_record",
			Status:   StatusFailed,
			Duration: time.Since(step1Start),
			Error:    err.Error(),
		})
		result.Duration = time.Since(start)
		return result, fmt.Errorf("create tenant record: %w", err)
	}

	result.Steps = append(result.Steps, StepResult{
		Name:     "create_record",
		Status:   StatusComplete,
		Duration: time.Since(step1Start),
	})

	// Step 2: Create tenant database (paid tier only; free tier uses shared DB)
	step2Start := time.Now()
	result.Status = StatusCreatingDatabase

	dbName := p.sharedDBName
	if tenantType == saas.TenantTypePaid {
		dbName = req.Name
		if err := p.dbCreator.CreateDatabase(ctx, dbName); err != nil {
			result.Status = StatusFailed
			result.Steps = append(result.Steps, StepResult{
				Name:     "create_database",
				Status:   StatusFailed,
				Duration: time.Since(step2Start),
				Error:    err.Error(),
			})
			// Rollback step 1
			p.rollbackRecord(ctx, tenantID)
			result.Duration = time.Since(start)
			return result, fmt.Errorf("create database: %w", err)
		}
	}

	result.Steps = append(result.Steps, StepResult{
		Name:     "create_database",
		Status:   StatusComplete,
		Duration: time.Since(step2Start),
	})

	// Step 3: Run migrations
	step3Start := time.Now()
	result.Status = StatusRunningMigrations

	pool, err := p.poolProvider.GetPool(ctx, dbName)
	if err != nil {
		result.Status = StatusFailed
		result.Steps = append(result.Steps, StepResult{
			Name:     "run_migrations",
			Status:   StatusFailed,
			Duration: time.Since(step3Start),
			Error:    err.Error(),
		})
		p.rollbackDatabase(ctx, tenantType, dbName, tenantID)
		result.Duration = time.Since(start)
		return result, fmt.Errorf("get pool for migrations: %w", err)
	}

	if err := p.migrator.RunMigrations(ctx, pool, tenantID); err != nil {
		result.Status = StatusFailed
		result.Steps = append(result.Steps, StepResult{
			Name:     "run_migrations",
			Status:   StatusFailed,
			Duration: time.Since(step3Start),
			Error:    err.Error(),
		})
		p.rollbackDatabase(ctx, tenantType, dbName, tenantID)
		result.Duration = time.Since(start)
		return result, fmt.Errorf("run migrations: %w", err)
	}

	result.Steps = append(result.Steps, StepResult{
		Name:     "run_migrations",
		Status:   StatusComplete,
		Duration: time.Since(step3Start),
	})

	// Step 4: Seed default data
	step4Start := time.Now()
	result.Status = StatusSeedingData

	seedData, err := p.seeder.Seed(ctx, pool, req, tenantID)
	if err != nil {
		result.Status = StatusFailed
		result.Steps = append(result.Steps, StepResult{
			Name:     "seed_data",
			Status:   StatusFailed,
			Duration: time.Since(step4Start),
			Error:    err.Error(),
		})
		p.rollbackDatabase(ctx, tenantType, dbName, tenantID)
		result.Duration = time.Since(start)
		return result, fmt.Errorf("seed data: %w", err)
	}

	result.Steps = append(result.Steps, StepResult{
		Name:     "seed_data",
		Status:   StatusComplete,
		Duration: time.Since(step4Start),
	})

	// Step 5: Activate tenant
	if err := p.store.UpdateStatus(ctx, tenantID, true); err != nil {
		p9log.Errorf("provisioning: failed to activate tenant %s: %v", tenantID, err)
		// Non-fatal: tenant was created, just not activated. Operator can activate manually.
	}

	result.Status = StatusComplete
	result.Duration = time.Since(start)
	result.Tenant = TenantInfo{
		ID:           tenantID,
		Name:         req.Name,
		DisplayName:  req.DisplayName,
		Region:       req.Region,
		Type:         string(tenantType),
		DatabaseName: dbName,
		AdminUserID:  seedData.AdminUserID,
		CreatedAt:    time.Now(),
	}

	return result, nil
}

// rollbackRecord deletes the tenant record from the master DB.
func (p *TenantProvisioner) rollbackRecord(ctx context.Context, tenantID string) {
	if err := p.store.DeleteTenant(ctx, tenantID); err != nil {
		p9log.Errorf("provisioning rollback: failed to delete tenant record %s: %v", tenantID, err)
	}
}

// rollbackDatabase drops the dedicated DB (paid only) and deletes the tenant record.
func (p *TenantProvisioner) rollbackDatabase(ctx context.Context, tenantType saas.TenantType, dbName, tenantID string) {
	if tenantType == saas.TenantTypePaid {
		if err := p.dbCreator.DropDatabase(ctx, dbName); err != nil {
			p9log.Errorf("provisioning rollback: failed to drop database %s: %v", dbName, err)
		}
	}
	p.rollbackRecord(ctx, tenantID)
}
