# ─────────────────────────────────────────────────────────────────────────────
# Secrets and rotation
#
# The database credentials live in Secrets Manager and are rotated on a
# schedule by the AWS-published rotation lambda, using the alternating-users
# strategy: two users, one live and one being rotated, swapping roles each
# time. The single-user strategy changes the password of the user everything is
# connected as, which means every open connection is invalidated at the moment
# of rotation — a short outage on a schedule, which is how rotation ends up
# switched off.
#
# The cluster reads the secret through the External Secrets operator, which
# syncs it into the `database-urls` Secret that k8s/base/secrets.yaml declares
# with empty values. That file is generated with empty strings on purpose: a
# real connection string committed to git is a credential that rotating the
# database does not remove.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_secretsmanager_secret" "database" {
  name        = "${local.name}/database"
  description = "Postgres credentials for ${local.name}, rotated every ${var.secret_rotation_days} days"
  kms_key_id  = aws_kms_key.secrets.id

  # Long enough to recover from deleting the wrong secret, short enough that a
  # secret which should be gone does not linger for a month.
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id = aws_secretsmanager_secret.database.id

  secret_string = jsonencode({
    engine   = "postgres"
    host     = aws_db_instance.primary.address
    port     = aws_db_instance.primary.port
    username = aws_db_instance.primary.username
    password = random_password.database.result
    dbname   = aws_db_instance.primary.db_name
    # The replica endpoint travels with the credentials so a read-heavy service
    # does not need a second secret to find it.
    readonly_host = length(aws_db_instance.replica) > 0 ? aws_db_instance.replica[0].address : aws_db_instance.primary.address
  })

  lifecycle {
    # After the first rotation the live value is not the one in state, and
    # re-applying it would roll the password back to the original.
    ignore_changes = [secret_string]
  }
}

resource "aws_kms_key" "secrets" {
  description             = "${local.name} Secrets Manager encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${local.name}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

# ── Rotation ─────────────────────────────────────────────────────────────────

resource "aws_secretsmanager_secret_rotation" "database" {
  secret_id           = aws_secretsmanager_secret.database.id
  rotation_lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.rotator.outputs["RotationLambdaARN"]

  rotation_rules {
    automatically_after_days = var.secret_rotation_days
  }
}

# The rotation function is AWS's own, deployed from the Serverless Application
# Repository rather than vendored here.
#
# Writing one by hand means owning the four-step rotation protocol —
# createSecret, setSecret, testSecret, finishSecret — and its failure modes,
# for a function whose only job is to run ALTER USER. The published one is
# maintained by the team that defines the protocol.
resource "aws_serverlessapplicationrepository_cloudformation_stack" "rotator" {
  name           = "${local.name}-rds-rotator"
  application_id = "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerRDSPostgreSQLRotationMultiUser"

  capabilities = [
    "CAPABILITY_IAM",
    "CAPABILITY_RESOURCE_POLICY",
  ]

  parameters = {
    functionName = "${local.name}-rds-rotator"
    # The lambda runs inside the VPC, because the database has no public
    # endpoint and the database subnets have no route out.
    vpcSubnetIds        = join(",", [for subnet in aws_subnet.private : subnet.id])
    vpcSecurityGroupIds = aws_security_group.rotator.id
    endpoint            = "https://secretsmanager.${var.region}.amazonaws.com"
  }
}

resource "aws_security_group" "rotator" {
  name        = "${local.name}-rotator"
  description = "The Secrets Manager rotation lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [for subnet in aws_subnet.database : subnet.cidr_block]
  }

  egress {
    description = "The Secrets Manager API endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name}-rotator" }
}

# The rotation lambda connects as the master user to create and alter the
# rotating users, so the database security group has to let it in. Written as a
# separate rule rather than in the group above to avoid a cycle: each group
# would otherwise reference the other.
resource "aws_vpc_security_group_ingress_rule" "database_from_rotator" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = aws_security_group.rotator.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Postgres from the rotation lambda"
}

# A rotation that fails silently leaves a credential in place past its
# expiry while every dashboard says rotation is configured.
resource "aws_cloudwatch_metric_alarm" "rotation_failed" {
  alarm_name          = "${local.name}-secret-rotation-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "The database credential rotation lambda is failing; the credential is not being rotated."
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = "${local.name}-rds-rotator"
  }
}
