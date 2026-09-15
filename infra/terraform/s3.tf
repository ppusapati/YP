# ─────────────────────────────────────────────────────────────────────────────
# Object storage
#
# Two buckets with quite different lifetimes:
#
#   imagery — satellite scenes and derived rasters. The one store here that
#             cannot be rebuilt: a prescription can be recomputed and a yield
#             model retrained, but a scene of a particular field on a
#             particular day in a particular season exists once. Replicated
#             across regions.
#
#   uploads — photographs, lab report PDFs, exports. Recoverable in principle,
#             but a farmer's diagnosis photo is evidence for a claim, so it is
#             versioned and kept.
# ─────────────────────────────────────────────────────────────────────────────

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  # Bucket names are globally unique across every AWS account, so a name that
  # is only unique to this deployment collides with somebody else's.
  imagery_bucket = "${local.name}-imagery-${random_id.bucket_suffix.hex}"
  uploads_bucket = "${local.name}-uploads-${random_id.bucket_suffix.hex}"
}

# ── Imagery ──────────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "imagery" {
  bucket = local.imagery_bucket
  tags   = { Name = local.imagery_bucket }
}

resource "aws_s3_bucket_public_access_block" "imagery" {
  bucket = aws_s3_bucket.imagery.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "imagery" {
  bucket = aws_s3_bucket.imagery.id
  versioning_configuration {
    # Required for replication, and independently the thing that survives a
    # process overwriting a scene with a truncated one.
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "imagery" {
  bucket = aws_s3_bucket.imagery.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "imagery" {
  bucket = aws_s3_bucket.imagery.id

  rule {
    id     = "tier-old-scenes"
    status = "Enabled"

    filter {}

    # Scenes are read constantly for the current season and then almost never,
    # except when somebody assesses a claim against a field's history — which
    # is why they move down the tiers rather than expiring. Glacier Instant
    # Retrieval keeps them readable in milliseconds at a fifth of the cost.
    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 365
      storage_class = "GLACIER_IR"
    }
  }

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      # Versions are here to survive a bad write, not as an archive. Ninety
      # days is long past when anybody notices.
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      # A failed 500 MB scene upload otherwise bills for ever, invisibly: parts
      # of an incomplete multipart upload do not show in the object listing.
      days_after_initiation = 7
    }
  }
}

# ── Cross-region replication ─────────────────────────────────────────────────

resource "aws_s3_bucket" "imagery_replica" {
  count    = var.imagery_replication_enabled ? 1 : 0
  provider = aws.replica

  bucket = "${local.imagery_bucket}-replica"
  tags   = { Name = "${local.imagery_bucket}-replica" }
}

resource "aws_s3_bucket_public_access_block" "imagery_replica" {
  count    = var.imagery_replication_enabled ? 1 : 0
  provider = aws.replica

  bucket = aws_s3_bucket.imagery_replica[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "imagery_replica" {
  count    = var.imagery_replication_enabled ? 1 : 0
  provider = aws.replica

  bucket = aws_s3_bucket.imagery_replica[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "imagery_replica" {
  count    = var.imagery_replication_enabled ? 1 : 0
  provider = aws.replica

  bucket = aws_s3_bucket.imagery_replica[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "imagery_replica" {
  count    = var.imagery_replication_enabled ? 1 : 0
  provider = aws.replica

  bucket = aws_s3_bucket.imagery_replica[0].id

  rule {
    id     = "cold-storage"
    status = "Enabled"

    filter {}

    # The replica is not read in the ordinary course of things, so it goes cold
    # immediately. Standard storage in a second region would double the storage
    # bill to hold a copy nobody opens.
    transition {
      days          = 30
      storage_class = "GLACIER_IR"
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "imagery" {
  count = var.imagery_replication_enabled ? 1 : 0

  bucket = aws_s3_bucket.imagery.id
  role   = aws_iam_role.replication[0].arn

  rule {
    id       = "imagery"
    status   = "Enabled"
    priority = 1

    filter {}

    delete_marker_replication {
      # Deletions are NOT replicated.
      #
      # This is the decision that makes the replica useful. Replicating delete
      # markers would mean an accidental bucket-wide delete propagating to the
      # copy that exists to survive it — a second region protecting against
      # losing a region, but not against the far more likely mistake.
      status = "Disabled"
    }

    destination {
      bucket        = aws_s3_bucket.imagery_replica[0].arn
      storage_class = "STANDARD_IA"

      metrics {
        status = "Enabled"
        event_threshold {
          minutes = 15
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.imagery]
}

resource "aws_iam_role" "replication" {
  count = var.imagery_replication_enabled ? 1 : 0

  name = "${local.name}-s3-replication"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "replication" {
  count = var.imagery_replication_enabled ? 1 : 0

  name = "${local.name}-s3-replication"
  role = aws_iam_role.replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
        Resource = [aws_s3_bucket.imagery.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
        ]
        Resource = ["${aws_s3_bucket.imagery.arn}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
        ]
        Resource = ["${aws_s3_bucket.imagery_replica[0].arn}/*"]
      },
    ]
  })
}

# Replication that has silently stopped is worse than no replication, because
# the dashboard still says the copy exists.
resource "aws_cloudwatch_metric_alarm" "replication_latency" {
  count = var.imagery_replication_enabled ? 1 : 0

  alarm_name          = "${local.name}-imagery-replication-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReplicationLatency"
  namespace           = "AWS/S3"
  period              = 900
  statistic           = "Maximum"
  threshold           = 900
  alarm_description   = "Imagery replication is more than 15 minutes behind."
  treat_missing_data  = "notBreaching"

  dimensions = {
    SourceBucket      = aws_s3_bucket.imagery.id
    DestinationBucket = aws_s3_bucket.imagery_replica[0].id
    RuleId            = "imagery"
  }
}

# ── Uploads ──────────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "uploads" {
  bucket = local.uploads_bucket
  tags   = { Name = local.uploads_bucket }
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_cors_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  cors_rule {
    # Presigned uploads from the browser and the mobile app. GET is here too
    # so a diagnosis photo can be displayed from the bucket without proxying
    # every image through the platform.
    allowed_methods = ["GET", "PUT", "POST", "HEAD"]
    allowed_origins = var.cdn_domain != "" ? ["https://${var.cdn_domain}"] : ["*"]
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    id     = "tier-and-tidy"
    status = "Enabled"

    filter {}

    transition {
      days          = 180
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id     = "expire-exports"
    status = "Enabled"

    filter {
      prefix = "exports/"
    }

    # Generated reports and certification packs. Regenerable by definition, and
    # keeping them for ever means keeping a stale answer somebody might send on.
    expiration {
      days = 30
    }
  }
}
