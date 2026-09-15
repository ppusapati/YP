# Staging.
#
# Everything here is chosen to answer "does the code work" for as little money
# as possible. It is deliberately not a small production: a staging that
# differs only in size hides the failures that come from differing in shape,
# and one that costs as much as production gets switched off.

environment = "staging"
region      = "ap-south-1"

kubernetes_version  = "1.30"
node_instance_types = ["t3.medium"]
node_min_size       = 2
node_max_size       = 4
node_desired_size   = 2

compute_instance_types = ["c6i.xlarge"]
compute_max_size       = 2

db_instance_class        = "db.t4g.medium"
db_allocated_storage     = 50
db_max_allocated_storage = 200

# No Multi-AZ and no read replicas. Staging losing its database for ten minutes
# during a failover is a coffee break, and paying for a standby to find that out
# is not worth it.
db_multi_az              = false
db_replica_count         = 0
db_backup_retention_days = 7
db_deletion_protection   = false

# No cross-region replica: staging imagery is test data, and a copy of test
# data in a second region protects nothing.
imagery_replication_enabled = false

# Empty until somebody fills in the office and VPN ranges. An empty list keeps
# the Kubernetes API private, which is the right state for it to be in until
# then.
allowed_admin_cidrs = []
