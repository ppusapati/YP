//go:build integration

// Package tests contains integration tests for the farm-service.
// These tests exercise the full request path: ConnectRPC client -> HTTP ->
// interceptor chain -> handler -> application service -> postgres repository -> DB.
//
// Prerequisites:
//   - A running PostgreSQL instance with PostGIS extension
//   - DATABASE_URL environment variable pointing to the test database
//   - The test will create and tear down tables automatically
//
// Run with:
//
//	DATABASE_URL="postgres://user:pass@localhost:5432/farm_test?sslmode=disable" \
//	  go test -tags=integration -v -count=1 ./farm-service/tests/...
package tests

import (
	"context"
	"fmt"
	"net"
	"net/http"
	"os"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/golang-jwt/jwt/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"

	"p9e.in/samavaya/packages/authz"
	"p9e.in/samavaya/packages/connect/interceptors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	pb "p9e.in/samavaya/agriculture/farm-service/api/v1"
	"p9e.in/samavaya/agriculture/farm-service/api/v1/farmv1connect"
	grpcadapter "p9e.in/samavaya/agriculture/farm-service/internal/adapters/inbound/grpc"
	kafkaadapter "p9e.in/samavaya/agriculture/farm-service/internal/adapters/outbound/kafka"
	postgresadapter "p9e.in/samavaya/agriculture/farm-service/internal/adapters/outbound/postgres"
	"p9e.in/samavaya/agriculture/farm-service/internal/application"
)

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const testJWTSecret = "integration-test-secret-key-very-long-32"

// Test tenant and user identifiers. Deterministic for easy cleanup.
const (
	testTenantID = "tenant_integ_001"
	testUserID   = "user_integ_001"
	testRole     = "admin"
)

// ---------------------------------------------------------------------------
// Schema SQL (mirrors farm-service/sqlc/schema/001_farms.sql)
// Executed once before the test suite; torn down afterward.
// ---------------------------------------------------------------------------

const schemaUp = `
CREATE EXTENSION IF NOT EXISTS postgis;

DO $$ BEGIN
  CREATE TYPE farm_type AS ENUM ('CROP', 'LIVESTOCK', 'MIXED', 'AQUACULTURE');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE farm_status AS ENUM ('ACTIVE', 'INACTIVE', 'PENDING', 'SUSPENDED', 'ARCHIVED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE soil_type AS ENUM ('CLAY', 'SANDY', 'LOAMY', 'SILT', 'PEAT', 'CHALKY', 'LATERITE', 'BLACK', 'RED', 'ALLUVIAL');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE climate_zone AS ENUM ('TROPICAL', 'SUBTROPICAL', 'ARID', 'SEMIARID', 'TEMPERATE', 'CONTINENTAL', 'POLAR', 'MEDITERRANEAN', 'MONSOON');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS farms (
    id              BIGSERIAL PRIMARY KEY,
    uuid            VARCHAR(26) NOT NULL UNIQUE,
    tenant_id       VARCHAR(26) NOT NULL,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    total_area_hectares DOUBLE PRECISION NOT NULL DEFAULT 0,
    latitude        DOUBLE PRECISION,
    longitude       DOUBLE PRECISION,
    elevation_meters DOUBLE PRECISION DEFAULT 0,
    farm_type       farm_type NOT NULL DEFAULT 'CROP',
    status          farm_status NOT NULL DEFAULT 'PENDING',
    soil_type       soil_type,
    climate_zone    climate_zone,
    address         TEXT,
    region          VARCHAR(255),
    country         VARCHAR(100),
    metadata        JSONB DEFAULT '{}',
    version         BIGINT NOT NULL DEFAULT 1,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_by      VARCHAR(26) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(26),
    updated_at      TIMESTAMPTZ,
    deleted_by      VARCHAR(26),
    deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS farm_boundaries (
    id              BIGSERIAL PRIMARY KEY,
    uuid            VARCHAR(26) NOT NULL UNIQUE,
    farm_id         BIGINT NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    farm_uuid       VARCHAR(26) NOT NULL,
    tenant_id       VARCHAR(26) NOT NULL,
    geojson         TEXT NOT NULL,
    boundary        GEOMETRY(Polygon, 4326),
    area_hectares   DOUBLE PRECISION NOT NULL DEFAULT 0,
    perimeter_meters DOUBLE PRECISION NOT NULL DEFAULT 0,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_by      VARCHAR(26) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(26),
    updated_at      TIMESTAMPTZ,
    deleted_by      VARCHAR(26),
    deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS farm_owners (
    id                    BIGSERIAL PRIMARY KEY,
    uuid                  VARCHAR(26) NOT NULL UNIQUE,
    farm_id               BIGINT NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    farm_uuid             VARCHAR(26) NOT NULL,
    tenant_id             VARCHAR(26) NOT NULL,
    user_id               VARCHAR(26) NOT NULL,
    owner_name            VARCHAR(255) NOT NULL,
    email                 VARCHAR(255),
    phone                 VARCHAR(50),
    is_primary            BOOLEAN NOT NULL DEFAULT FALSE,
    ownership_percentage  DOUBLE PRECISION NOT NULL DEFAULT 100.0,
    acquired_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active             BOOLEAN NOT NULL DEFAULT TRUE,
    created_by            VARCHAR(26) NOT NULL,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by            VARCHAR(26),
    updated_at            TIMESTAMPTZ,
    deleted_by            VARCHAR(26),
    deleted_at            TIMESTAMPTZ
);
`

const schemaDown = `
DROP TABLE IF EXISTS farm_owners CASCADE;
DROP TABLE IF EXISTS farm_boundaries CASCADE;
DROP TABLE IF EXISTS farms CASCADE;
`

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// signTestJWT creates an HS256 JWT with the given claims using the test secret.
func signTestJWT(t *testing.T, tenantID, userID, role string) string {
	t.Helper()

	claims := &authz.CustomClaims{
		UserID:   userID,
		TenantID: tenantID,
		Role:     role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(1 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    "farm-service-integration-test",
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString([]byte(testJWTSecret))
	if err != nil {
		t.Fatalf("failed to sign JWT: %v", err)
	}
	return signed
}

// connectDB creates a pgxpool connected to DATABASE_URL. Skips the test if the
// env var is empty or the database is unreachable.
func connectDB(t *testing.T) *pgxpool.Pool {
	t.Helper()

	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		t.Skip("DATABASE_URL not set -- skipping integration test")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		t.Skipf("cannot connect to test database: %v", err)
	}
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		t.Skipf("database ping failed: %v", err)
	}
	return pool
}

// applySchema runs the given SQL against the pool.
func applySchema(t *testing.T, pool *pgxpool.Pool, sql string) {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	if _, err := pool.Exec(ctx, sql); err != nil {
		t.Fatalf("schema execution failed: %v", err)
	}
}

// cleanTestData removes rows inserted by this test run (identified by tenant_id).
func cleanTestData(t *testing.T, pool *pgxpool.Pool) {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	_, _ = pool.Exec(ctx, "DELETE FROM farm_owners  WHERE tenant_id = $1", testTenantID)
	_, _ = pool.Exec(ctx, "DELETE FROM farm_boundaries WHERE tenant_id = $1", testTenantID)
	_, _ = pool.Exec(ctx, "DELETE FROM farms WHERE tenant_id = $1", testTenantID)
}

// bridgeUserContextToConnectionInfo is a Connect interceptor that copies the
// authenticated user's tenant_id into p9context.ConnectionInfo so that
// p9context.TenantID(ctx) returns a non-empty value.
//
// In production this bridge will likely live in the interceptor chain or be
// handled by the DB middleware; for tests we make it explicit.
func bridgeUserContextToConnectionInfo(pool *pgxpool.Pool) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			user, ok := p9context.FromUserContext(ctx)
			if ok && user != nil && user.TenantID != "" {
				info := &saas.ConnectionInfo{
					Pool:           pool,
					TenantID:       user.TenantID,
					RequiresFilter: true,
				}
				ctx = p9context.NewConnectionInfo(ctx, info)
			}
			return next(ctx, req)
		}
	}
}

// startTestServer wires all farm-service layers, starts an HTTP server on a
// random port, and returns the base URL (e.g. "http://127.0.0.1:54321") and a
// shutdown function.
func startTestServer(t *testing.T, pool *pgxpool.Pool) (baseURL string, shutdown func()) {
	t.Helper()

	// Logger
	zapLogger, _ := zap.NewDevelopment()
	logger := p9log.NewLogger(zapLogger)

	// JWT validator
	jwtValidator := interceptors.NewAuthzJWTValidator()

	// Outbound adapters
	repo := postgresadapter.NewFarmRepository(pool, logger)
	pub := kafkaadapter.NewEventPublisher(nil, logger) // nil producer = no-op events

	// Application service
	svc := application.NewFarmService(repo, pub, pool, logger)

	// Inbound adapter (ConnectRPC handler)
	handler := grpcadapter.NewFarmHandler(svc, logger)

	// Build interceptor chain.
	// Order: Recovery -> RequestID -> Logging -> DB -> Auth -> Bridge -> RLS(Tenant)
	chain := []connect.Interceptor{
		interceptors.RecoveryInterceptor(),
		interceptors.RequestIDInterceptor(),
		interceptors.LoggingInterceptor(),
		interceptors.DBInterceptor(pool),
		interceptors.AuthInterceptor(jwtValidator),
		bridgeUserContextToConnectionInfo(pool),
		interceptors.TenantLevelInterceptor(),
	}

	mux := http.NewServeMux()
	path, farmHTTPHandler := farmv1connect.NewFarmServiceHandler(
		handler,
		connect.WithInterceptors(chain...),
	)
	mux.Handle(path, farmHTTPHandler)

	// Listen on a random port.
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("failed to listen: %v", err)
	}

	srv := &http.Server{Handler: mux}
	go func() {
		if err := srv.Serve(listener); err != nil && err != http.ErrServerClosed {
			// Log but don't fatal -- the main goroutine may already be exiting.
			t.Logf("server error: %v", err)
		}
	}()

	addr := listener.Addr().(*net.TCPAddr)
	base := fmt.Sprintf("http://127.0.0.1:%d", addr.Port)

	return base, func() {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		_ = srv.Shutdown(ctx)
	}
}

// newAuthenticatedClient creates a FarmServiceClient that attaches the given
// JWT bearer token to every request.
func newAuthenticatedClient(baseURL, token string) farmv1connect.FarmServiceClient {
	return farmv1connect.NewFarmServiceClient(
		&http.Client{},
		baseURL,
		connect.WithInterceptors(bearerTokenInterceptor(token)),
	)
}

// bearerTokenInterceptor is a client-side interceptor that sets the
// Authorization header on every outgoing request.
func bearerTokenInterceptor(token string) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			req.Header().Set("Authorization", "Bearer "+token)
			return next(ctx, req)
		}
	}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

// TestFarmCreateRetrieveNoDuplicates exercises the primary acceptance flow:
//
//  1. Farmer creates a farm via the ConnectRPC API.
//  2. Backend validates the request (auth + business rules).
//  3. A row is persisted in PostgreSQL with the correct tenant_id.
//  4. The mobile client retrieves the farm by ID and all fields match.
//  5. Listing farms returns the created farm.
//  6. Creating a farm with the same name is rejected (no duplicates).
func TestFarmCreateRetrieveNoDuplicates(t *testing.T) {
	// ── Setup ───────────────────────────────────────────────────────────────

	// 1. Database
	pool := connectDB(t)
	defer pool.Close()

	applySchema(t, pool, schemaUp)
	t.Cleanup(func() { cleanTestData(t, pool) })

	// 2. JWT
	t.Setenv("JWT_SECRET", testJWTSecret)
	if err := authz.InitJWTFromEnv(); err != nil {
		t.Fatalf("InitJWTFromEnv: %v", err)
	}

	// 3. Server
	baseURL, shutdownServer := startTestServer(t, pool)
	defer shutdownServer()

	// 4. Authenticated ConnectRPC client
	token := signTestJWT(t, testTenantID, testUserID, testRole)
	client := newAuthenticatedClient(baseURL, token)

	ctx := context.Background()

	// ── Step 1: Create a farm ───────────────────────────────────────────────

	farmName := fmt.Sprintf("Integration Test Farm %d", time.Now().UnixNano())

	createReq := connect.NewRequest(&pb.CreateFarmRequest{
		Name:              farmName,
		Description:       "Created by integration test",
		TotalAreaHectares: 42.5,
		FarmType:          pb.FarmType_FARM_TYPE_CROP,
		SoilType:          pb.SoilType_SOIL_TYPE_LOAMY,
		ClimateZone:       pb.ClimateZone_CLIMATE_ZONE_TROPICAL,
		Region:            "Karnataka",
		Country:           "India",
		Location: &pb.FarmLocation{
			Latitude:  12.9716,
			Longitude: 77.5946,
		},
		Owner: &pb.FarmOwner{
			UserId:              testUserID,
			OwnerName:           "Test Farmer",
			Email:               "test@example.com",
			Phone:               "+919876543210",
			OwnershipPercentage: 100,
		},
	})

	createResp, err := client.CreateFarm(ctx, createReq)
	if err != nil {
		t.Fatalf("CreateFarm failed: %v", err)
	}

	createdFarm := createResp.Msg.GetFarm()
	if createdFarm == nil {
		t.Fatal("CreateFarm returned nil farm")
	}

	farmID := createdFarm.GetId()
	if farmID == "" {
		t.Fatal("created farm has empty ID")
	}

	t.Logf("Created farm: id=%s name=%s", farmID, createdFarm.GetName())

	// Verify create response fields
	if createdFarm.GetName() != farmName {
		t.Errorf("name: got %q, want %q", createdFarm.GetName(), farmName)
	}
	if createdFarm.GetTenantId() != testTenantID {
		t.Errorf("tenant_id: got %q, want %q", createdFarm.GetTenantId(), testTenantID)
	}
	if createdFarm.GetTotalAreaHectares() != 42.5 {
		t.Errorf("total_area_hectares: got %f, want 42.5", createdFarm.GetTotalAreaHectares())
	}
	if createdFarm.GetFarmType() != pb.FarmType_FARM_TYPE_CROP {
		t.Errorf("farm_type: got %v, want CROP", createdFarm.GetFarmType())
	}
	if createdFarm.GetStatus() != pb.FarmStatus_FARM_STATUS_PENDING {
		t.Errorf("status: got %v, want PENDING", createdFarm.GetStatus())
	}
	if createdFarm.GetRegion() != "Karnataka" {
		t.Errorf("region: got %q, want %q", createdFarm.GetRegion(), "Karnataka")
	}
	if createdFarm.GetCountry() != "India" {
		t.Errorf("country: got %q, want %q", createdFarm.GetCountry(), "India")
	}
	if createdFarm.GetVersion() != 1 {
		t.Errorf("version: got %d, want 1", createdFarm.GetVersion())
	}
	if createdFarm.GetCreatedBy() != testUserID {
		t.Errorf("created_by: got %q, want %q", createdFarm.GetCreatedBy(), testUserID)
	}

	// Verify owner was created
	if len(createdFarm.GetOwners()) == 0 {
		t.Error("expected at least one owner on the created farm")
	} else {
		owner := createdFarm.GetOwners()[0]
		if owner.GetOwnerName() != "Test Farmer" {
			t.Errorf("owner name: got %q, want %q", owner.GetOwnerName(), "Test Farmer")
		}
		if owner.GetUserId() != testUserID {
			t.Errorf("owner user_id: got %q, want %q", owner.GetUserId(), testUserID)
		}
		if !owner.GetIsPrimary() {
			t.Error("expected owner to be primary")
		}
	}

	// ── Step 2: Retrieve the farm by ID (simulates mobile fetch) ────────────

	getResp, err := client.GetFarm(ctx, connect.NewRequest(&pb.GetFarmRequest{
		Id: farmID,
	}))
	if err != nil {
		t.Fatalf("GetFarm failed: %v", err)
	}

	gotFarm := getResp.Msg.GetFarm()
	if gotFarm == nil {
		t.Fatal("GetFarm returned nil farm")
	}

	// Verify all fields round-trip correctly
	if gotFarm.GetId() != farmID {
		t.Errorf("GetFarm id: got %q, want %q", gotFarm.GetId(), farmID)
	}
	if gotFarm.GetName() != farmName {
		t.Errorf("GetFarm name: got %q, want %q", gotFarm.GetName(), farmName)
	}
	if gotFarm.GetTenantId() != testTenantID {
		t.Errorf("GetFarm tenant_id: got %q, want %q", gotFarm.GetTenantId(), testTenantID)
	}
	if gotFarm.GetTotalAreaHectares() != 42.5 {
		t.Errorf("GetFarm area: got %f, want 42.5", gotFarm.GetTotalAreaHectares())
	}
	if gotFarm.GetFarmType() != pb.FarmType_FARM_TYPE_CROP {
		t.Errorf("GetFarm farm_type: got %v, want CROP", gotFarm.GetFarmType())
	}
	if gotFarm.GetStatus() != pb.FarmStatus_FARM_STATUS_PENDING {
		t.Errorf("GetFarm status: got %v, want PENDING", gotFarm.GetStatus())
	}
	if gotFarm.GetDescription() != "Created by integration test" {
		t.Errorf("GetFarm description: got %q, want %q", gotFarm.GetDescription(), "Created by integration test")
	}

	// Verify location
	if loc := gotFarm.GetLocation(); loc != nil {
		if loc.GetLatitude() != 12.9716 {
			t.Errorf("GetFarm latitude: got %f, want 12.9716", loc.GetLatitude())
		}
		if loc.GetLongitude() != 77.5946 {
			t.Errorf("GetFarm longitude: got %f, want 77.5946", loc.GetLongitude())
		}
	} else {
		t.Error("GetFarm: expected location to be set")
	}

	// Verify owners are returned
	if len(gotFarm.GetOwners()) == 0 {
		t.Error("GetFarm: expected at least one owner")
	}

	// ── Step 3: List farms and verify the created farm appears ──────────────

	listResp, err := client.ListFarms(ctx, connect.NewRequest(&pb.ListFarmsRequest{
		PageSize: 50,
	}))
	if err != nil {
		t.Fatalf("ListFarms failed: %v", err)
	}

	if listResp.Msg.GetTotalCount() < 1 {
		t.Errorf("ListFarms total_count: got %d, want >= 1", listResp.Msg.GetTotalCount())
	}

	found := false
	for _, f := range listResp.Msg.GetFarms() {
		if f.GetId() == farmID {
			found = true
			if f.GetName() != farmName {
				t.Errorf("ListFarms farm name: got %q, want %q", f.GetName(), farmName)
			}
			break
		}
	}
	if !found {
		t.Errorf("ListFarms: created farm %s not found in listing", farmID)
	}

	// ── Step 4: Duplicate name is rejected ──────────────────────────────────

	dupReq := connect.NewRequest(&pb.CreateFarmRequest{
		Name:              farmName, // same name
		TotalAreaHectares: 10,
		FarmType:          pb.FarmType_FARM_TYPE_LIVESTOCK,
		Region:            "Tamil Nadu",
		Country:           "India",
	})
	_, dupErr := client.CreateFarm(ctx, dupReq)
	if dupErr == nil {
		t.Error("expected error when creating farm with duplicate name, got nil")
	} else {
		// The application returns a Conflict error (FARM_NAME_EXISTS).
		if connectErr, ok := asConnectError(dupErr); ok {
			if connectErr.Code() != connect.CodeAlreadyExists {
				t.Errorf("duplicate farm error code: got %v, want %v", connectErr.Code(), connect.CodeAlreadyExists)
			}
		}
		t.Logf("Duplicate farm correctly rejected: %v", dupErr)
	}

	// ── Step 5: Direct DB verification ──────────────────────────────────────

	var dbTenantID, dbName, dbFarmType, dbStatus, dbCreatedBy string
	var dbArea float64
	var dbVersion int64
	var dbIsActive bool

	dbCtx, dbCancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer dbCancel()

	err = pool.QueryRow(dbCtx,
		`SELECT tenant_id, name, total_area_hectares, farm_type, status, version, is_active, created_by
		 FROM farms WHERE uuid = $1`, farmID,
	).Scan(&dbTenantID, &dbName, &dbArea, &dbFarmType, &dbStatus, &dbVersion, &dbIsActive, &dbCreatedBy)
	if err != nil {
		t.Fatalf("direct DB query failed: %v", err)
	}

	if dbTenantID != testTenantID {
		t.Errorf("DB tenant_id: got %q, want %q", dbTenantID, testTenantID)
	}
	if dbName != farmName {
		t.Errorf("DB name: got %q, want %q", dbName, farmName)
	}
	if dbArea != 42.5 {
		t.Errorf("DB total_area_hectares: got %f, want 42.5", dbArea)
	}
	if dbFarmType != "CROP" {
		t.Errorf("DB farm_type: got %q, want %q", dbFarmType, "CROP")
	}
	if dbStatus != "PENDING" {
		t.Errorf("DB status: got %q, want %q", dbStatus, "PENDING")
	}
	if dbVersion != 1 {
		t.Errorf("DB version: got %d, want 1", dbVersion)
	}
	if !dbIsActive {
		t.Error("DB is_active: got false, want true")
	}
	if dbCreatedBy != testUserID {
		t.Errorf("DB created_by: got %q, want %q", dbCreatedBy, testUserID)
	}

	// Verify no duplicate rows exist.
	var farmCount int
	err = pool.QueryRow(dbCtx,
		`SELECT COUNT(*) FROM farms WHERE name = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		farmName, testTenantID,
	).Scan(&farmCount)
	if err != nil {
		t.Fatalf("duplicate count query failed: %v", err)
	}
	if farmCount != 1 {
		t.Errorf("expected exactly 1 active farm with name %q, got %d", farmName, farmCount)
	}

	t.Log("All assertions passed: farm created, retrieved, listed, duplicate rejected, DB verified")
}

// TestFarmCreateWithoutAuth verifies that unauthenticated requests are rejected.
func TestFarmCreateWithoutAuth(t *testing.T) {
	pool := connectDB(t)
	defer pool.Close()

	applySchema(t, pool, schemaUp)
	t.Cleanup(func() { cleanTestData(t, pool) })

	t.Setenv("JWT_SECRET", testJWTSecret)
	if err := authz.InitJWTFromEnv(); err != nil {
		t.Fatalf("InitJWTFromEnv: %v", err)
	}

	baseURL, shutdownServer := startTestServer(t, pool)
	defer shutdownServer()

	// Create client WITHOUT auth token
	unauthClient := farmv1connect.NewFarmServiceClient(
		&http.Client{},
		baseURL,
	)

	_, err := unauthClient.CreateFarm(context.Background(), connect.NewRequest(&pb.CreateFarmRequest{
		Name:     "Should Not Be Created",
		FarmType: pb.FarmType_FARM_TYPE_CROP,
	}))

	if err == nil {
		t.Fatal("expected unauthenticated error, got nil")
	}

	if connectErr, ok := asConnectError(err); ok {
		if connectErr.Code() != connect.CodeUnauthenticated {
			t.Errorf("expected Unauthenticated code, got %v", connectErr.Code())
		}
	}

	t.Log("Unauthenticated request correctly rejected")
}

// TestFarmTenantIsolation verifies that a farm created by one tenant is not
// visible to another tenant.
func TestFarmTenantIsolation(t *testing.T) {
	pool := connectDB(t)
	defer pool.Close()

	applySchema(t, pool, schemaUp)
	t.Cleanup(func() {
		cleanTestData(t, pool)
		// Also clean up tenant B data
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		_, _ = pool.Exec(ctx, "DELETE FROM farm_owners  WHERE tenant_id = $1", "tenant_integ_B")
		_, _ = pool.Exec(ctx, "DELETE FROM farm_boundaries WHERE tenant_id = $1", "tenant_integ_B")
		_, _ = pool.Exec(ctx, "DELETE FROM farms WHERE tenant_id = $1", "tenant_integ_B")
	})

	t.Setenv("JWT_SECRET", testJWTSecret)
	if err := authz.InitJWTFromEnv(); err != nil {
		t.Fatalf("InitJWTFromEnv: %v", err)
	}

	baseURL, shutdownServer := startTestServer(t, pool)
	defer shutdownServer()

	ctx := context.Background()

	// Tenant A creates a farm
	tokenA := signTestJWT(t, testTenantID, testUserID, testRole)
	clientA := newAuthenticatedClient(baseURL, tokenA)

	farmName := fmt.Sprintf("Tenant A Farm %d", time.Now().UnixNano())
	resp, err := clientA.CreateFarm(ctx, connect.NewRequest(&pb.CreateFarmRequest{
		Name:     farmName,
		FarmType: pb.FarmType_FARM_TYPE_CROP,
	}))
	if err != nil {
		t.Fatalf("Tenant A CreateFarm failed: %v", err)
	}
	farmID := resp.Msg.GetFarm().GetId()

	// Tenant B should NOT see Tenant A's farm
	tokenB := signTestJWT(t, "tenant_integ_B", "user_integ_B", testRole)
	clientB := newAuthenticatedClient(baseURL, tokenB)

	_, getErr := clientB.GetFarm(ctx, connect.NewRequest(&pb.GetFarmRequest{
		Id: farmID,
	}))
	if getErr == nil {
		t.Error("Tenant B should NOT be able to see Tenant A's farm")
	} else {
		if connectErr, ok := asConnectError(getErr); ok {
			if connectErr.Code() != connect.CodeNotFound {
				t.Errorf("expected NotFound for cross-tenant get, got %v", connectErr.Code())
			}
		}
	}

	// Tenant B's ListFarms should not include Tenant A's farm
	listResp, err := clientB.ListFarms(ctx, connect.NewRequest(&pb.ListFarmsRequest{
		PageSize: 100,
	}))
	if err != nil {
		t.Fatalf("Tenant B ListFarms failed: %v", err)
	}
	for _, f := range listResp.Msg.GetFarms() {
		if f.GetId() == farmID {
			t.Errorf("Tenant B can see Tenant A's farm %s in listing", farmID)
		}
	}

	t.Log("Tenant isolation verified: Tenant B cannot access Tenant A's farm")
}

// TestFarmCreateValidation verifies that invalid inputs are rejected.
func TestFarmCreateValidation(t *testing.T) {
	pool := connectDB(t)
	defer pool.Close()

	applySchema(t, pool, schemaUp)
	t.Cleanup(func() { cleanTestData(t, pool) })

	t.Setenv("JWT_SECRET", testJWTSecret)
	if err := authz.InitJWTFromEnv(); err != nil {
		t.Fatalf("InitJWTFromEnv: %v", err)
	}

	baseURL, shutdownServer := startTestServer(t, pool)
	defer shutdownServer()

	token := signTestJWT(t, testTenantID, testUserID, testRole)
	client := newAuthenticatedClient(baseURL, token)
	ctx := context.Background()

	// Missing name
	_, err := client.CreateFarm(ctx, connect.NewRequest(&pb.CreateFarmRequest{
		FarmType: pb.FarmType_FARM_TYPE_CROP,
	}))
	if err == nil {
		t.Error("expected error for missing farm name")
	}

	// Invalid farm type (UNSPECIFIED)
	_, err = client.CreateFarm(ctx, connect.NewRequest(&pb.CreateFarmRequest{
		Name:     "Valid Name",
		FarmType: pb.FarmType_FARM_TYPE_UNSPECIFIED,
	}))
	if err == nil {
		t.Error("expected error for unspecified farm type")
	}

	t.Log("Validation errors correctly returned for invalid inputs")
}

// asConnectError extracts a *connect.Error from err if present.
func asConnectError(err error) (*connect.Error, bool) {
	if cErr, ok := err.(*connect.Error); ok {
		return cErr, true
	}
	return nil, false
}
