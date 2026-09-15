# ─────────────────────────────────────────────────────────────────────────────
# PostgreSQL
#
# A Multi-AZ primary and N read replicas.
#
# Multi-AZ is what makes failover automatic: AWS keeps a synchronous standby in
# another availability zone and promotes it on its own, usually within a minute
# or two, with no election to run and no operator to install. That is the same
# question CloudNativePG or Patroni answers in a self-hosted cluster —
# k8s/postgres/replicated gives that deployment streaming replication but not
# automatic promotion, which is stated there rather than implied.
#
# The read replicas exist for the read-heavy services. satellite, analytics and
# the tile server do large read-only queries that have no business competing
# with a farmer saving an inspection, and pointing them at the replica endpoint
# is the difference between a slow report and a slow platform.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_db_subnet_group" "main" {
  name       = local.name
  subnet_ids = [for subnet in aws_subnet.database : subnet.id]
  tags       = { Name = local.name }
}

resource "aws_security_group" "database" {
  name        = "${local.name}-database"
  description = "Postgres, reachable only from the cluster nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Postgres from the EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_eks_cluster.main.vpc_config[0].cluster_security_group_id]
  }

  # No egress rule at all. The default security group allows all outbound;
  # naming an empty egress here removes it, so a database that is somehow
  # executing code cannot open a connection out of the VPC.

  tags = { Name = "${local.name}-database" }
}

resource "aws_kms_key" "database" {
  description             = "${local.name} RDS storage encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "database" {
  name          = "alias/${local.name}-rds"
  target_key_id = aws_kms_key.database.key_id
}

resource "aws_db_parameter_group" "main" {
  name   = local.name
  family = "postgres16"

  # Log anything slower than a second, and record who ran it.
  #
  # The same settings docker-compose.yml applies locally, for the same reason:
  # the answer to "which query is slow" is otherwise a guess. One second is
  # deliberately not aggressive — a threshold that fires on ordinary queries
  # produces a log nobody reads.
  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
    # Changing shared_preload_libraries needs a restart, and RDS will not do it
    # silently. Without this the apply succeeds and the parameter sits in
    # "pending-reboot" for ever.
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "pg_stat_statements.track"
    value = "top"
  }

  parameter {
    name  = "log_lock_waits"
    value = "1"
  }

  parameter {
    name  = "log_autovacuum_min_duration"
    value = "0"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_password" "database" {
  length  = 40
  special = true
  # RDS rejects these three in a master password, and the failure arrives
  # fifteen minutes into an apply.
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_instance" "primary" {
  identifier = "${local.name}-primary"

  engine         = "postgres"
  engine_version = "16"
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.database.arn

  db_name  = "yieldpoint"
  username = "yieldpoint"
  password = random_password.database.result
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  parameter_group_name   = aws_db_parameter_group.main.name

  multi_az = var.db_multi_az

  backup_retention_period = var.db_backup_retention_days
  # 18:30 UTC is midnight in India: the window least likely to overlap a farmer
  # recording a harvest.
  backup_window         = "18:30-19:30"
  maintenance_window    = "sun:19:30-sun:20:30"
  copy_tags_to_snapshot = true

  # A destroy without this leaves nothing to recover from, and the one time it
  # matters is the time it was not meant to be destroyed.
  skip_final_snapshot       = false
  final_snapshot_identifier = "${local.name}-final-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  deletion_protection       = var.db_deletion_protection

  performance_insights_enabled    = true
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.rds_monitoring.arn
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  auto_minor_version_upgrade = true

  lifecycle {
    ignore_changes = [
      # The password is rotated by Secrets Manager, not by terraform. Without
      # this every apply after the first rotation resets it to the value in
      # state, and every service loses its connection at once.
      password,
      # Recomputed on every plan because of the timestamp, which would show a
      # spurious change forever.
      final_snapshot_identifier,
    ]
  }

  tags = { Name = "${local.name}-primary" }
}

resource "aws_db_instance" "replica" {
  count = var.db_replica_count

  identifier          = "${local.name}-replica-${count.index + 1}"
  replicate_source_db = aws_db_instance.primary.identifier
  instance_class      = var.db_replica_instance_class

  # Inherited from the source: storage, engine version, subnet group. Setting
  # them here is what produces "cannot specify X for a replica" on apply.
  vpc_security_group_ids = [aws_security_group.database.id]
  parameter_group_name   = aws_db_parameter_group.main.name

  # A replica is rebuilt from the primary, so a backup of one is a backup of
  # data that already has one.
  backup_retention_period = 0
  skip_final_snapshot     = true

  performance_insights_enabled = true
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_monitoring.arn

  auto_minor_version_upgrade = true

  tags = {
    Name = "${local.name}-replica-${count.index + 1}"
    Role = "read-replica"
  }
}

resource "aws_iam_role" "rds_monitoring" {
  name = "${local.name}-rds-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ── Alarms ───────────────────────────────────────────────────────────────────
#
# Replica lag is the one that matters most and the one nobody sets up. A
# replica that has fallen a minute behind is still answering queries, still
# healthy by every other measure, and quietly serving a satellite report from a
# minute ago — which looks like the platform losing data rather than like a
# replication problem.

resource "aws_cloudwatch_metric_alarm" "replica_lag" {
  count = var.db_replica_count

  alarm_name          = "${local.name}-replica-${count.index + 1}-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "ReplicaLag"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 30
  alarm_description   = "Read replica is more than 30s behind the primary; reads from it are stale."
  treat_missing_data  = "breaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.replica[count.index].identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "database_storage" {
  alarm_name          = "${local.name}-database-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  # 10 GB. Storage autoscaling handles the ordinary case; this fires when
  # something is filling the disk faster than autoscaling raises the ceiling.
  threshold          = 10 * 1024 * 1024 * 1024
  alarm_description  = "Primary is running out of disk."
  treat_missing_data = "breaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.primary.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "database_connections" {
  alarm_name          = "${local.name}-database-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Maximum"
  # Thirty services with a pool each add up faster than people expect, and the
  # failure mode is every service failing to connect at once.
  threshold          = 400
  alarm_description  = "Connection count is approaching the instance limit."
  treat_missing_data = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.primary.identifier
  }
}
