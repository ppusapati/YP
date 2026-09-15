# ─────────────────────────────────────────────────────────────────────────────
# YieldPoint cloud infrastructure
#
# What this does and does not cover
# ---------------------------------
# This describes the infrastructure a YieldPoint deployment sits on: the
# network, the Kubernetes cluster, the databases, the object storage and the
# CDN in front of the tiles. It does NOT deploy the platform itself — that is
# k8s/overlays, applied by .github/workflows/cd.yml. The boundary is
# deliberate: the cluster changes a few times a year and the platform changes
# a few times a day, and putting them in one apply means every deploy waits on
# a plan against a VPC nobody touched.
#
# It has never been applied against a real account. It is written from the AWS
# provider's documented resource schemas and is complete enough to plan, but
# the first apply will surface things a plan cannot — service quotas, an
# account without the EKS service-linked role, a region missing an instance
# class. That is worth saying out loud rather than implying otherwise by
# silence.
#
#   terraform init
#   terraform plan  -var-file=environments/staging.tfvars
#   terraform apply -var-file=environments/staging.tfvars
# ─────────────────────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    # Used to read the EKS OIDC issuer's certificate thumbprint, which is what
    # lets IAM trust the cluster's service account tokens.
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # State lives in S3 with DynamoDB locking, configured per environment with
  # `terraform init -backend-config=...`. Left partial on purpose: hardcoding a
  # bucket here means a second environment cannot be created without editing
  # the file it shares with the first.
  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "yieldpoint"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# The CDN's certificate has to live in us-east-1 whatever region everything
# else is in — a CloudFront requirement, not a choice.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "yieldpoint"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# The replica region for satellite imagery. Separate provider because
# cross-region replication needs a destination bucket in it.
provider "aws" {
  alias  = "replica"
  region = var.replica_region

  default_tags {
    tags = {
      Project     = "yieldpoint"
      Environment = var.environment
      ManagedBy   = "terraform"
      Role        = "replica"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "yieldpoint-${var.environment}"

  # Three AZs where the region has them. Two is the minimum for an RDS
  # Multi-AZ failover and for a cluster that survives losing one; a third
  # means losing one does not leave the remaining two carrying 50% more each.
  azs = slice(data.aws_availability_zones.available.names, 0,
  min(3, length(data.aws_availability_zones.available.names)))
}
