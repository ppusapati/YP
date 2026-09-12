# YieldPoint Disaster Recovery Plan

## Overview

This document defines the disaster recovery (DR) strategy for the YieldPoint precision agriculture platform. The platform operates 20 PostgreSQL service databases on a shared instance, supporting real-time sensor data, satellite imagery processing, and farm management operations.

## Recovery Objectives

| Metric | Target | Notes |
|--------|--------|-------|
| **RPO** (Recovery Point Objective) | < 1 hour | Maximum acceptable data loss window |
| **RTO** (Recovery Time Objective) | < 30 minutes | Maximum acceptable downtime |
| **MTTR** (Mean Time To Recover) | < 20 minutes | Average expected recovery time |

### How We Meet These Targets

- **RPO < 1 hour**: Daily full backups at 02:00 UTC combined with continuous WAL archiving (5-minute archive timeout). WAL segments capture every write, so the true RPO under normal operation is approximately 5 minutes. The 1-hour target accounts for the worst-case delay in WAL shipping.
- **RTO < 30 minutes**: Streaming replication keeps a hot standby replica that can be promoted to primary within seconds. A full restore from backup (worst case, when the replica is also lost) takes approximately 15-25 minutes depending on database sizes.

## Architecture

```
                      ┌───────────────────────┐
                      │   Application Layer    │
                      │  (20 service databases)│
                      └──────────┬────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
              ┌─────┴─────┐           ┌───────┴───────┐
              │  Primary   │──stream──▶│   Replica     │
              │  (r/w)     │           │   (read-only) │
              └─────┬─────┘           └───────────────┘
                    │
          ┌─────────┼─────────┐
          │         │         │
    ┌─────┴──┐ ┌────┴───┐ ┌──┴──────┐
    │ WAL    │ │ Daily  │ │ Cross-  │
    │ Archive│ │ Backup │ │ Region  │
    │ (5min) │ │ (S3)   │ │ Replica │
    └────────┘ └────────┘ └─────────┘
```

## Backup Schedule

### Daily Automated Backups

| Property | Value |
|----------|-------|
| Schedule | Daily at 02:00 UTC |
| Method | `pg_dump` per database, gzip compressed |
| Storage | S3/MinIO (`yieldpoint-backups` bucket) |
| Path format | `YYYY/MM/DD/<database>_<timestamp>.sql.gz` |
| Global objects | `pg_dumpall --globals-only` (roles, tablespaces) |
| Retention | 30 days (configurable via `RETENTION_DAYS`) |

### WAL Archiving (Continuous)

| Property | Value |
|----------|-------|
| Archive timeout | 5 minutes (300 seconds) |
| Storage | `/var/lib/postgresql/wal_archive` (PVC) |
| Retention | 7 days |
| Purpose | Point-in-time recovery between daily backups |

### Weekly Backup Verification

| Property | Value |
|----------|-------|
| Schedule | Sundays at 06:00 UTC |
| Method | Restore to temp database, run integrity checks |
| Checks | Table counts, PK/FK constraints, table readability |
| Notification | Webhook (Slack, PagerDuty, etc.) |

## Data Retention Policies

| Service | Database | Retention | Backup Priority | Notes |
|---------|----------|-----------|-----------------|-------|
| Auth | `auth_service` | Indefinite | Critical | User credentials, tokens |
| Farm | `farm_service` | Indefinite | Critical | Core farm definitions |
| Field | `field_service` | Indefinite | Critical | Field boundaries, geospatial data |
| Crop | `crop_service` | 5 years | High | Crop history, planting records |
| Soil | `soil_service` | 5 years | High | Soil test results, profiles |
| Sensor | `sensor_service` | 2 years | High | IoT sensor readings (time-series) |
| Irrigation | `irrigation_service` | 3 years | High | Irrigation schedules, water usage |
| Pest Prediction | `pest_prediction_service` | 3 years | High | Pest models, alert history |
| Plant Diagnosis | `plant_diagnosis_service` | 3 years | Medium | Diagnosis images, results |
| Yield | `yield_service` | Indefinite | Critical | Yield data, historical trends |
| Commerce | `commerce_service` | 7 years | Critical | Transactions, invoices (regulatory) |
| Traceability | `traceability_service` | 7 years | Critical | Supply chain records (regulatory) |
| Satellite | `satellite_service` | 2 years | High | Satellite metadata, job records |
| Satellite Ingestion | `satellite_ingestion_service` | 1 year | Medium | Ingestion queue, temp metadata |
| Satellite Processing | `satellite_processing_service` | 1 year | Medium | Processing pipeline state |
| Satellite Analytics | `satellite_analytics_service` | 3 years | High | Derived analytics, NDVI history |
| Satellite Tile | `satellite_tile_service` | 1 year | Medium | Tile cache metadata |
| Vegetation Index | `vegetation_index_service` | 3 years | High | Vegetation index time-series |
| Task | `task_service` | 2 years | Medium | Farm task history |
| Agronomy | `agronomy_service` | 5 years | High | Agronomic recommendations |

## Recovery Procedures

### Scenario 1: Replica Failure (No Data Loss)

**Impact**: Reduced read capacity, no write disruption.
**RTO**: ~5 minutes.

```bash
# 1. Verify primary is healthy
psql -h postgres-primary -U yieldpoint -c "SELECT pg_is_in_recovery();"
# Expected: f (false — not in recovery, is primary)

# 2. Delete the failed replica pod (Kubernetes recreates it)
kubectl -n yieldpoint delete pod postgres-replica-0

# 3. Monitor replica bootstrap
kubectl -n yieldpoint logs -f postgres-replica-0

# 4. Verify replication is streaming
psql -h postgres-primary -U yieldpoint -c \
  "SELECT client_addr, state, sent_lsn, replay_lsn FROM pg_stat_replication;"
```

### Scenario 2: Primary Failure with Healthy Replica (Failover)

**Impact**: Brief write outage during promotion.
**RTO**: ~2 minutes.

```bash
# 1. Verify primary is truly down
kubectl -n yieldpoint get pod postgres-primary-0
pg_isready -h postgres-primary.yieldpoint.svc.cluster.local -p 5432

# 2. Promote the replica to primary
kubectl -n yieldpoint exec postgres-replica-0 -- \
  psql -U yieldpoint -c "SELECT pg_promote();"

# 3. Verify the replica is no longer in recovery mode
kubectl -n yieldpoint exec postgres-replica-0 -- \
  psql -U yieldpoint -c "SELECT pg_is_in_recovery();"
# Expected: f (false — promoted to primary)

# 4. Update the postgres service to point to the promoted replica
kubectl -n yieldpoint patch service postgres \
  -p '{"spec":{"selector":{"app.kubernetes.io/component":"replica"}}}'

# 5. Investigate and rebuild the old primary as a new replica
# (see Scenario 4 below)
```

### Scenario 3: Full Database Restore from Backup

**Impact**: Full outage during restore.
**RTO**: ~15-25 minutes (depends on data volume).

```bash
# 1. Stop all application services to prevent writes during restore
kubectl -n yieldpoint scale deployment --all --replicas=0

# 2. Restore all databases from a specific date
export PGHOST=postgres-primary.yieldpoint.svc.cluster.local
export PGUSER=yieldpoint
export PGPASSWORD="<password>"
export BACKUP_BUCKET=yieldpoint-backups
export FORCE=1

./scripts/backup/pg-restore.sh --all --date 20260912

# 3. Restart application services
kubectl -n yieldpoint scale deployment --all --replicas=1

# 4. Rebuild replica from the restored primary
kubectl -n yieldpoint delete pvc postgres-data-postgres-replica-0
kubectl -n yieldpoint delete pod postgres-replica-0
# StatefulSet recreates the pod, which bootstraps from primary
```

### Scenario 4: Point-in-Time Recovery (PITR)

**Impact**: Full outage during recovery.
**RTO**: ~20-30 minutes.

Use this when you need to recover to a specific moment (e.g., just before an accidental deletion).

```bash
# 1. Stop all application services
kubectl -n yieldpoint scale deployment --all --replicas=0

# 2. Restore the most recent full backup before the target time
./scripts/backup/pg-restore.sh --all --date 20260912 --force

# 3. Configure PITR target
./scripts/backup/pg-restore.sh --pitr --target-time "2026-09-12 14:30:00+00"

# 4. Restart PostgreSQL to begin WAL replay
kubectl -n yieldpoint exec postgres-primary-0 -- \
  pg_ctl -D /var/lib/postgresql/data restart

# 5. Monitor recovery progress in PostgreSQL logs
kubectl -n yieldpoint logs -f postgres-primary-0

# 6. Once recovery completes, restart services
kubectl -n yieldpoint scale deployment --all --replicas=1
```

### Scenario 5: Single Database Restore

**Impact**: Outage limited to one service.
**RTO**: ~5-10 minutes.

```bash
# Restore a single database (e.g., crop_service) from a specific date
./scripts/backup/pg-restore.sh --db crop_service --date 20260912

# Or from a local backup file
./scripts/backup/pg-restore.sh --db crop_service --file /path/to/crop_service_20260912T020000Z.sql.gz
```

## Streaming Replication

### Architecture

- **Primary** (`postgres-primary`): Accepts all read/write traffic. Streams WAL to replicas.
- **Replica** (`postgres-replica`): Hot standby accepting read-only queries. Can be promoted to primary.
- **Replication Slot**: `replica_slot_1` ensures WAL segments are retained until the replica has consumed them.

### Monitoring Replication Lag

```sql
-- On the primary: check replication status
SELECT
  client_addr,
  application_name,
  state,
  sent_lsn,
  write_lsn,
  flush_lsn,
  replay_lsn,
  pg_wal_lsn_diff(sent_lsn, replay_lsn) AS replay_lag_bytes
FROM pg_stat_replication;

-- On the replica: check how far behind
SELECT
  pg_is_in_recovery() AS is_replica,
  pg_last_wal_receive_lsn() AS received_lsn,
  pg_last_wal_replay_lsn() AS replayed_lsn,
  pg_last_xact_replay_timestamp() AS last_replayed_at,
  NOW() - pg_last_xact_replay_timestamp() AS replication_delay;
```

**Alert thresholds**:
- Warning: replication delay > 30 seconds
- Critical: replication delay > 5 minutes or replication slot inactive

## Cross-Region Backup Strategy

### Satellite Imagery

Satellite imagery is the largest data category and requires special handling.

| Component | Strategy |
|-----------|----------|
| Raw imagery (S3) | S3 Cross-Region Replication to a secondary region |
| Processed tiles (S3) | S3 CRR with Intelligent-Tiering in secondary region |
| Metadata (PostgreSQL) | Standard database backup (included in daily dumps) |
| NDVI/index data | Standard database backup + S3 CRR for raster outputs |

### Cross-Region Database Replication

For production deployments requiring cross-region DR:

1. **Primary region**: US-East-1 — full PostgreSQL primary + replica
2. **DR region**: US-West-2 — asynchronous replica receiving WAL via streaming
3. **Backup storage**: S3 buckets in both regions with Cross-Region Replication enabled

```
US-East-1 (Primary)              US-West-2 (DR)
┌──────────────┐                 ┌──────────────┐
│   Primary    │───async WAL────▶│  DR Replica  │
│   Replica    │                 │  (read-only) │
└──────┬───────┘                 └──────────────┘
       │
       ▼
┌──────────────┐    S3 CRR       ┌──────────────┐
│ Backups (S3) │────────────────▶│ Backups (S3) │
│ Imagery (S3) │                 │ Imagery (S3) │
└──────────────┘                 └──────────────┘
```

## Failover Decision Tree

```
Is the primary PostgreSQL responding?
├── YES → Is replication lag acceptable (< 5 min)?
│         ├── YES → No action needed. Monitor.
│         └── NO  → Check replica health.
│                   ├── Replica healthy → Check network, WAL shipping.
│                   └── Replica unhealthy → Rebuild replica (Scenario 1).
└── NO  → Is the replica healthy?
          ├── YES → Promote replica to primary (Scenario 2).
          │         Then rebuild old primary as new replica.
          └── NO  → Full restore from backup (Scenario 3).
                    Consider PITR if data corruption (Scenario 4).
```

## Testing Schedule

| Test | Frequency | Owner | Procedure |
|------|-----------|-------|-----------|
| Backup verification | Weekly (automated) | Platform team | `verify-backup.sh` via CronJob |
| Single-database restore | Monthly | DBA | Restore one database to staging |
| Full DR failover | Quarterly | Platform + SRE | Promote replica, restore primary |
| Cross-region failover | Bi-annually | Platform + SRE | Promote DR region replica |
| PITR exercise | Quarterly | DBA | Restore to a specific point in time |

## Runbook Contacts

| Role | Responsibility |
|------|---------------|
| On-call SRE | First responder, executes failover procedures |
| DBA | Database recovery, PITR decisions, schema validation |
| Platform Lead | Escalation, cross-region failover authorization |
| Data Team | Post-recovery data integrity validation |

## Configuration Reference

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PGHOST` | `localhost` | PostgreSQL host |
| `PGPORT` | `5432` | PostgreSQL port |
| `PGUSER` | `yieldpoint` | PostgreSQL superuser |
| `PGPASSWORD` | (required) | PostgreSQL password |
| `BACKUP_BUCKET` | `yieldpoint-backups` | S3 bucket for backups |
| `S3_ENDPOINT` | (unset) | S3/MinIO endpoint URL |
| `RETENTION_DAYS` | `30` | Days to retain backups |
| `USE_MC` | `0` | Use MinIO `mc` instead of `aws` CLI |
| `REPLICATION_PASSWORD` | (required) | Password for `replicator` role |

### File Locations

| File | Purpose |
|------|---------|
| `scripts/backup/pg-backup.sh` | Daily automated backup |
| `scripts/backup/pg-restore.sh` | Restore from backup |
| `scripts/backup/verify-backup.sh` | Weekly backup verification |
| `k8s/base/backup-cronjob.yaml` | Kubernetes CronJob for backups |
| `k8s/base/postgres-replication.yaml` | Streaming replication config |
| `docker-compose.backup.yml` | Docker Compose backup overlay |
