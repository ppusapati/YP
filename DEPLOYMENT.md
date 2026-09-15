# YieldPoint Production Deployment Guide

## Prerequisites

- Kubernetes cluster (1.28+) with nginx ingress controller and cert-manager
- PostgreSQL 16+ (managed or self-hosted)
- Container registry access (GitHub Container Registry configured)
- Domain name with DNS management access
- GitHub repository with Actions enabled

## 1. Secrets & Configuration

### 1.1 Generate Secrets

```bash
# Generate a strong JWT secret
JWT_SECRET=$(openssl rand -base64 64)

# Generate Postgres password
POSTGRES_PASSWORD=$(openssl rand -base64 32)

# Generate S3/MinIO credentials
S3_ACCESS_KEY_ID=$(openssl rand -hex 16)
S3_SECRET_ACCESS_KEY=$(openssl rand -base64 32)

# Generate Grafana admin password
GRAFANA_ADMIN_PASSWORD=$(openssl rand -base64 16)
```

### 1.2 Create Kubernetes Secrets

```bash
kubectl create namespace yieldpoint

kubectl -n yieldpoint create secret generic yieldpoint-secrets \
  --from-literal=POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  --from-literal=JWT_SECRET="$JWT_SECRET" \
  --from-literal=S3_ACCESS_KEY_ID="$S3_ACCESS_KEY_ID" \
  --from-literal=S3_SECRET_ACCESS_KEY="$S3_SECRET_ACCESS_KEY" \
  --from-literal=EXTERNAL_API_KEY="" \
  --from-literal=GRAFANA_ADMIN_PASSWORD="$GRAFANA_ADMIN_PASSWORD"
```

### 1.3 Create Database URL Secrets

Each service requires its own database. Replace `<host>` with your Postgres host.

```bash
kubectl -n yieldpoint create secret generic database-urls \
  --from-literal=AUTH_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/auth_service?sslmode=require" \
  --from-literal=FARM_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/farm_service?sslmode=require" \
  --from-literal=FIELD_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/field_service?sslmode=require" \
  --from-literal=CROP_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/crop_service?sslmode=require" \
  --from-literal=SOIL_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/soil_service?sslmode=require" \
  --from-literal=SENSOR_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/sensor_service?sslmode=require" \
  --from-literal=IRRIGATION_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/irrigation_service?sslmode=require" \
  --from-literal=PEST_PREDICTION_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/pest_prediction_service?sslmode=require" \
  --from-literal=PLANT_DIAGNOSIS_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/plant_diagnosis_service?sslmode=require" \
  --from-literal=YIELD_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/yield_service?sslmode=require" \
  --from-literal=COMMERCE_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/commerce_service?sslmode=require" \
  --from-literal=TRACEABILITY_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/traceability_service?sslmode=require" \
  --from-literal=SATELLITE_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/satellite_service?sslmode=require" \
  --from-literal=SATELLITE_INGESTION_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/satellite_ingestion_service?sslmode=require" \
  --from-literal=SATELLITE_PROCESSING_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/satellite_processing_service?sslmode=require" \
  --from-literal=SATELLITE_ANALYTICS_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/satellite_analytics_service?sslmode=require" \
  --from-literal=SATELLITE_TILE_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/satellite_tile_service?sslmode=require" \
  --from-literal=VEGETATION_INDEX_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/vegetation_index_service?sslmode=require" \
  --from-literal=TASK_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/task_service?sslmode=require" \
  --from-literal=AGRONOMY_SERVICE_DATABASE_URL="postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/agronomy_service?sslmode=require"
```

### 1.4 Configure GitHub Environments

In your GitHub repository settings, create two environments:

| Environment | Secret | Value |
|-------------|--------|-------|
| `staging` | `KUBE_CONFIG_STAGING` | Base64-encoded kubeconfig for staging cluster |
| `production` | `KUBE_CONFIG_PRODUCTION` | Base64-encoded kubeconfig for production cluster |

```bash
# Encode kubeconfig
cat ~/.kube/config | base64 -w 0
```

## 2. Database Setup

### 2.1 Create Databases

```bash
# Connect to your Postgres instance and run the init script
psql -h <host> -U yieldpoint -f scripts/init-databases.sh
```

This creates all 20 service databases:
auth_service, farm_service, field_service, crop_service, soil_service,
sensor_service, irrigation_service, pest_prediction_service,
plant_diagnosis_service, yield_service, commerce_service,
traceability_service, satellite_service, satellite_ingestion_service,
satellite_processing_service, satellite_analytics_service,
satellite_tile_service, vegetation_index_service, task_service,
agronomy_service.

### 2.2 Run Migrations

Each service has migrations in its `migrations/` directory:

```bash
for svc in auth farm field crop soil sensor irrigation pest-prediction \
  plant-diagnosis yield commerce traceability satellite \
  satellite-ingestion satellite-processing satellite-analytics \
  satellite-tile vegetation-index task agronomy; do
  echo "=== Migrating ${svc}-service ==="
  migrate -path ./${svc}-service/migrations \
    -database "postgres://yieldpoint:${POSTGRES_PASSWORD}@<host>:5432/${svc//-/_}_service?sslmode=require" \
    up
done
```

## 3. DNS & TLS

### 3.1 Configure DNS

Create an A record pointing your domain to the cluster's ingress IP:

```
api.yieldpoint.io -> <ingress-external-ip>
```

### 3.2 Install cert-manager (if not present)

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.0/cert-manager.yaml
```

### 3.3 Create ClusterIssuer

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
      - http01:
          ingress:
            class: nginx
```

### 3.4 Update Ingress Hostname

Edit `k8s/base/ingress.yaml` and replace `api.yieldpoint.io` with your actual domain.

## 4. Deploy

### 4.1 Option A: Automated (CI/CD)

Push to `main` to deploy to staging:
```bash
git push origin main
```

Tag a release to deploy to production:
```bash
git tag v1.0.0
git push origin v1.0.0
```

The CD pipeline (`.github/workflows/cd.yml`) will:
1. Build all service Docker images
2. Push to GitHub Container Registry (ghcr.io)
3. Deploy to staging (on main push) or production (on version tag)

### 4.2 Option B: Manual

```bash
# Build and push images
for svc in auth farm field crop soil sensor irrigation pest-prediction \
  plant-diagnosis yield commerce traceability satellite \
  satellite-ingestion satellite-processing satellite-analytics \
  satellite-tile vegetation-index task agronomy alert analytics \
  prescription; do
  docker build --build-arg SERVICE=${svc}-service \
    -t ghcr.io/<owner>/yieldpoint/${svc}-service:v1.0.0 .
  docker push ghcr.io/<owner>/yieldpoint/${svc}-service:v1.0.0
done

# Build monolith and ai-gateway
docker build -f cmd/monolith/Dockerfile -t ghcr.io/<owner>/yieldpoint/monolith:v1.0.0 .
docker build -f ai-gateway/Dockerfile -t ghcr.io/<owner>/yieldpoint/ai-gateway:v1.0.0 .

# Deploy k8s manifests
TAG=v1.0.0
for f in k8s/base/*.yaml; do
  sed "s|:latest|:${TAG}|g" "$f" | kubectl apply -f -
done

# Wait for rollout
kubectl -n yieldpoint rollout status deployment --timeout=300s \
  -l app.kubernetes.io/part-of=yieldpoint
```

### 4.3 Option C: Docker Compose (single-node)

For smaller deployments on a single server:

```bash
# Copy and fill in environment
cp .env.production.example .env

# Edit .env with real values
vim .env

# Start all services
docker compose up -d

# Check health
docker compose ps
```

## 5. Post-Deploy Verification

### 5.1 Health Checks

```bash
# Check all pods are running
kubectl -n yieldpoint get pods

# Check service endpoints
kubectl -n yieldpoint get svc

# Test auth endpoint
curl https://api.yieldpoint.io/health

# Test gRPC (requires grpcurl)
grpcurl -plaintext <ai-gateway-ip>:50051 grpc.health.v1.Health/Check
```

### 5.2 Monitoring

- Prometheus: `http://<cluster-ip>:9091` (or port-forward: `kubectl -n yieldpoint port-forward svc/prometheus 9091:9090`)
- Grafana: `http://<cluster-ip>:3001` (default login: admin / `$GRAFANA_ADMIN_PASSWORD`)

### 5.3 Smoke Tests

```bash
# Run integration test suite against staging
DATABASE_URL="postgres://..." go test -tags=e2e -v ./tests/integration/...
```

## 6. Rollback

### 6.1 Kubernetes

```bash
# Roll back a specific deployment
kubectl -n yieldpoint rollout undo deployment/auth-service

# Roll back to a specific revision
kubectl -n yieldpoint rollout undo deployment/auth-service --to-revision=2

# Roll back ALL services to previous tag
PREV_TAG=v0.9.0
for f in k8s/base/*.yaml; do
  sed "s|:latest|:${PREV_TAG}|g" "$f" | kubectl apply -f -
done
```

### 6.2 Database

```bash
# Roll back last migration for a service
migrate -path ./auth-service/migrations \
  -database "postgres://..." \
  down 1
```

## 7. Maintenance

### 7.1 Scaling

```bash
# Scale a service horizontally
kubectl -n yieldpoint scale deployment/farm-service --replicas=4

# Set up Horizontal Pod Autoscaler
kubectl -n yieldpoint autoscale deployment/farm-service \
  --min=2 --max=10 --cpu-percent=70
```

### 7.2 Log Access

```bash
# Tail logs for a service
kubectl -n yieldpoint logs -f deployment/auth-service

# All services
kubectl -n yieldpoint logs -f -l app.kubernetes.io/part-of=yieldpoint --max-log-requests=30
```

### 7.3 Database Backups

```bash
# Manual backup
pg_dump -h <host> -U yieldpoint -F c auth_service > backups/auth_service_$(date +%Y%m%d).dump

# Restore
pg_restore -h <host> -U yieldpoint -d auth_service backups/auth_service_20260912.dump
```

## Architecture Reference

```
Client → Ingress (nginx + TLS) → Service Mesh
  ├── auth-service          (JWT authentication)
  ├── farm-service          (farm management)
  ├── field-service         (field boundaries, zones)
  ├── crop-service          (crop lifecycle)
  ├── soil-service          (soil analysis)
  ├── sensor-service        (IoT sensor data)
  ├── irrigation-service    (irrigation scheduling)
  ├── yield-service         (yield prediction)
  ├── satellite-*-services  (satellite imagery pipeline)
  ├── vegetation-index      (NDVI, EVI computation)
  ├── pest-prediction       (pest/disease forecasting)
  ├── plant-diagnosis       (plant health analysis)
  ├── ai-gateway            (ML inference, terrain, water flow)
  ├── commerce-service      (marketplace)
  ├── traceability-service  (supply chain tracking)
  ├── task-service          (field task management)
  ├── agronomy-service      (advisory, inspections)
  ├── alert-service         (notifications)
  ├── analytics-service     (reporting)
  └── prescription-service  (treatment recommendations)

Infrastructure:
  ├── PostgreSQL 16         (per-service databases)
  ├── Kafka                 (event bus)
  ├── MinIO                 (object storage)
  ├── Prometheus            (metrics)
  └── Grafana               (dashboards)
```
