-- 001_vegetation_index.sql
-- Schema for the vegetation-index-service: compute_tasks, vegetation_indices

-- Enum types
CREATE TYPE vegetation_index_type AS ENUM (
    'NDVI', 'NDWI', 'EVI', 'SAVI', 'MSAVI', 'NDRE', 'GNDVI', 'LAI'
);

CREATE TYPE compute_status AS ENUM (
    'QUEUED', 'COMPUTING', 'INTERSECTING', 'COMPLETED', 'FAILED'
);

-- Compute tasks table
CREATE TABLE compute_tasks (
    id                      BIGSERIAL PRIMARY KEY,
    uuid                    VARCHAR(26) NOT NULL UNIQUE,
    tenant_id               VARCHAR(26) NOT NULL,
    processing_job_uuid     VARCHAR(26) NOT NULL,
    farm_uuid               VARCHAR(26) NOT NULL,
    index_types             vegetation_index_type[] NOT NULL,
    status                  compute_status NOT NULL DEFAULT 'QUEUED',
    error_message           TEXT,
    compute_time_seconds    DOUBLE PRECISION DEFAULT 0,
    version                 BIGINT NOT NULL DEFAULT 1,
    is_active               BOOLEAN NOT NULL DEFAULT TRUE,
    created_by              VARCHAR(26) NOT NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by              VARCHAR(26),
    updated_at              TIMESTAMPTZ,
    completed_at            TIMESTAMPTZ,
    deleted_at              TIMESTAMPTZ,
    deleted_by              VARCHAR(26)
);

-- Vegetation indices table
CREATE TABLE vegetation_indices (
    id                      BIGSERIAL PRIMARY KEY,
    uuid                    VARCHAR(26) NOT NULL UNIQUE,
    tenant_id               VARCHAR(26) NOT NULL,
    farm_uuid               VARCHAR(26) NOT NULL,
    field_uuid              VARCHAR(26),
    processing_job_uuid     VARCHAR(26) NOT NULL,
    compute_task_uuid       VARCHAR(26) NOT NULL,
    index_type              vegetation_index_type NOT NULL,
    mean_value              DOUBLE PRECISION NOT NULL DEFAULT 0,
    min_value               DOUBLE PRECISION NOT NULL DEFAULT 0,
    max_value               DOUBLE PRECISION NOT NULL DEFAULT 0,
    std_deviation           DOUBLE PRECISION NOT NULL DEFAULT 0,
    median_value            DOUBLE PRECISION NOT NULL DEFAULT 0,
    pixel_count             BIGINT NOT NULL DEFAULT 0,
    coverage_percent        DOUBLE PRECISION NOT NULL DEFAULT 0,
    raster_s3_key           TEXT,
    acquisition_date        TIMESTAMPTZ NOT NULL,
    computed_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active               BOOLEAN NOT NULL DEFAULT TRUE,
    created_by              VARCHAR(26) NOT NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ,
    deleted_by              VARCHAR(26)
);

-- Indexes for compute_tasks
CREATE INDEX idx_compute_tasks_tenant_id ON compute_tasks(tenant_id);
CREATE INDEX idx_compute_tasks_uuid ON compute_tasks(uuid);
CREATE INDEX idx_compute_tasks_processing_job ON compute_tasks(processing_job_uuid);
CREATE INDEX idx_compute_tasks_farm_uuid ON compute_tasks(farm_uuid);
CREATE INDEX idx_compute_tasks_status ON compute_tasks(tenant_id, status);
CREATE INDEX idx_compute_tasks_created_at ON compute_tasks(tenant_id, created_at DESC);
CREATE INDEX idx_compute_tasks_active ON compute_tasks(tenant_id, is_active) WHERE is_active = TRUE AND deleted_at IS NULL;

-- Indexes for vegetation_indices
CREATE INDEX idx_vegetation_indices_tenant_id ON vegetation_indices(tenant_id);
CREATE INDEX idx_vegetation_indices_uuid ON vegetation_indices(uuid);
CREATE INDEX idx_vegetation_indices_farm_uuid ON vegetation_indices(farm_uuid);
CREATE INDEX idx_vegetation_indices_field_uuid ON vegetation_indices(field_uuid);
CREATE INDEX idx_vegetation_indices_index_type ON vegetation_indices(tenant_id, index_type);
CREATE INDEX idx_vegetation_indices_acquisition_date ON vegetation_indices(tenant_id, acquisition_date DESC);
CREATE INDEX idx_vegetation_indices_compute_task ON vegetation_indices(compute_task_uuid);
CREATE INDEX idx_vegetation_indices_processing_job ON vegetation_indices(processing_job_uuid);
CREATE INDEX idx_vegetation_indices_farm_type_date ON vegetation_indices(farm_uuid, index_type, acquisition_date DESC);
CREATE INDEX idx_vegetation_indices_field_type_date ON vegetation_indices(field_uuid, index_type, acquisition_date DESC);
CREATE INDEX idx_vegetation_indices_active ON vegetation_indices(tenant_id, is_active) WHERE is_active = TRUE AND deleted_at IS NULL;
