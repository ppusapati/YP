# Production.

environment    = "production"
region         = "ap-south-1"      # Mumbai, where the farms are
replica_region = "ap-southeast-1"  # Singapore, for the imagery replica

kubernetes_version  = "1.30"
node_instance_types = ["t3.large", "t3a.large"] # two families, so one being short in an AZ is not an outage
node_min_size       = 3
node_max_size       = 20
node_desired_size   = 4

compute_instance_types = ["c6i.2xlarge"]
compute_max_size       = 8

db_instance_class         = "db.r6g.xlarge"
db_replica_instance_class = "db.r6g.large"
db_allocated_storage      = 200
db_max_allocated_storage  = 2000

# Multi-AZ is the automatic failover: AWS promotes the standby on its own,
# typically within a minute or two, with no operator and no election.
db_multi_az = true

# Two read replicas for satellite, analytics and the tile server. Their queries
# are large and read-only and have no business competing with a farmer saving
# an inspection.
db_replica_count = 2

db_backup_retention_days = 30
db_deletion_protection   = true

secret_rotation_days = 30

# The imagery bucket is the one store that cannot be rebuilt.
imagery_replication_enabled = true

cdn_domain = "app.yieldpoint.io"

# Fill in with the office and VPN ranges before the first apply. Left empty the
# Kubernetes API stays private, which means kubectl only works from inside the
# VPC or through a bastion — inconvenient, and the correct default.
allowed_admin_cidrs = []
