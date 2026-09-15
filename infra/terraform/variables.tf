variable "environment" {
  description = "Environment name; every resource is prefixed with it."
  type        = string

  validation {
    # Used in bucket names and DNS, which are lowercase and dash-only. Catching
    # it here beats an apply that fails on the seventeenth resource.
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.environment))
    error_message = "environment must be lowercase alphanumeric with dashes, 2-21 characters."
  }
}

variable "region" {
  description = "Primary AWS region."
  type        = string
  default     = "ap-south-1" # Mumbai: the farms are in India and so is the latency
}

variable "replica_region" {
  description = "Region that holds the satellite imagery replica."
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "kubernetes_version" {
  description = "EKS control plane version."
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "Instance types for the general node group."
  type        = list(string)
  default     = ["t3.large"]
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 10
}

variable "node_desired_size" {
  type    = number
  default = 3
}

variable "compute_instance_types" {
  description = <<-EOT
    Instance types for the compute node group that runs satellite processing
    and the AI gateway. Separate from the general pool because those workloads
    are CPU- and memory-hungry in bursts, and mixing them means either every
    node is oversized or the bursts evict the services next to them.
  EOT
  type        = list(string)
  default     = ["c6i.2xlarge"]
}

variable "compute_max_size" {
  type    = number
  default = 6
}

variable "db_instance_class" {
  description = "RDS instance class for the primary."
  type        = string
  default     = "db.t4g.large"
}

variable "db_replica_instance_class" {
  description = "RDS instance class for the read replicas."
  type        = string
  default     = "db.t4g.large"
}

variable "db_replica_count" {
  description = <<-EOT
    Read replicas. The read-heavy services — satellite, analytics, the tile
    server — are pointed at the replica endpoint; everything that writes stays
    on the primary. Zero is valid and gives a Multi-AZ primary with no read
    scaling, which is the right shape for staging.
  EOT
  type        = number
  default     = 2
}

variable "db_allocated_storage" {
  type    = number
  default = 100
}

variable "db_max_allocated_storage" {
  description = "Storage autoscaling ceiling. Satellite imagery metadata grows."
  type        = number
  default     = 1000
}

variable "db_multi_az" {
  description = <<-EOT
    Multi-AZ deployment, which is what makes failover automatic: AWS promotes
    the standby on its own, typically within a minute or two, with no manual
    step and no election to run. This is the managed answer to the same
    question CloudNativePG or Patroni answers in a self-hosted cluster.
  EOT
  type        = bool
  default     = true
}

variable "db_backup_retention_days" {
  type    = number
  default = 30
}

variable "db_deletion_protection" {
  type    = bool
  default = true
}

variable "secret_rotation_days" {
  description = <<-EOT
    How often the database password is rotated. Thirty days is short enough to
    limit the window a leaked credential is useful for and long enough that the
    rotation is not itself the most likely cause of an outage.
  EOT
  type        = number
  default     = 30
}

variable "imagery_replication_enabled" {
  description = <<-EOT
    Cross-region replication for satellite imagery.

    The imagery bucket is the one store here that cannot be rebuilt: a
    prescription can be recomputed and a yield model retrained, but a scene
    from a particular field on a particular day in a particular season exists
    once. S3 is already multi-AZ within a region, so this is protection against
    losing the region or against an accidental bucket-wide delete, which
    versioning alone does not cover if the bucket itself goes.
  EOT
  type        = bool
  default     = true
}

variable "cdn_domain" {
  description = "Domain the CDN serves from. Empty disables the CDN and its certificate."
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = <<-EOT
    An existing us-east-1 certificate for the CDN domain. Empty issues one,
    which requires the DNS validation records to be created before the apply
    completes — so an existing ARN is the faster path in an account where the
    zone is managed elsewhere.
  EOT
  type        = string
  default     = ""
}

variable "allowed_admin_cidrs" {
  description = <<-EOT
    CIDRs allowed to reach the EKS public API endpoint.

    Defaults to empty rather than to 0.0.0.0/0. An open Kubernetes API is the
    single most common way a cluster is lost, and a default that works
    everywhere is a default that is open everywhere.
  EOT
  type        = list(string)
  default     = []
}
