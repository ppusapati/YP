# ─────────────────────────────────────────────────────────────────────────────
# Kubernetes cluster
#
# Two node groups. The general pool runs the thirty Go services, which are
# small and numerous; the compute pool runs satellite processing and the AI
# gateway, which are few and large. Mixing them means either paying for
# c6i-shaped nodes to run a service that needs 128Mi, or watching a satellite
# job evict half the platform when it bursts.
#
# The compute pool is tainted, so nothing lands on it without asking. The
# production overlay's node affinity asks for `node-pool: yieldpoint-production`,
# which the general pool carries.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_eks_cluster" "main" {
  name     = local.name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = concat(
      [for subnet in aws_subnet.private : subnet.id],
      [for subnet in aws_subnet.public : subnet.id],
    )

    endpoint_private_access = true

    # Public access only when someone has said which addresses. An open
    # Kubernetes API is the most common way a cluster is lost, and a default
    # that works from anywhere is a default that is reachable from anywhere.
    endpoint_public_access = length(var.allowed_admin_cidrs) > 0
    public_access_cidrs    = var.allowed_admin_cidrs
  }

  # Audit is the log that answers "who deleted the namespace". The others are
  # cheap and are the ones anybody reads during an incident.
  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks.arn
    }
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_cloudwatch_log_group.eks,
  ]

  tags = { Name = local.name }
}

# Created explicitly so it has a retention policy. EKS creates this group on
# its own if it is missing, with retention set to "never expire".
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${local.name}/cluster"
  retention_in_days = 90
}

resource "aws_kms_key" "eks" {
  description             = "${local.name} EKS secret envelope encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${local.name}-eks"
  target_key_id = aws_kms_key.eks.key_id
}

# ── Node groups ──────────────────────────────────────────────────────────────

resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "general"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = [for subnet in aws_subnet.private : subnet.id]
  instance_types  = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    # One node at a time. Two nodes draining together on a three-node cluster
    # is most of the platform rescheduling at once, and the PodDisruptionBudgets
    # in k8s/base would rightly block it — slowly.
    max_unavailable = 1
  }

  labels = {
    "node-pool" = "yieldpoint-${var.environment}"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_registry,
  ]

  lifecycle {
    # The cluster autoscaler owns this after the first apply. Without the
    # ignore, every terraform apply scales the cluster back to desired_size
    # and evicts whatever the autoscaler had added for a load spike.
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = { Name = "${local.name}-general" }
}

resource "aws_eks_node_group" "compute" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "compute"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = [for subnet in aws_subnet.private : subnet.id]
  instance_types  = var.compute_instance_types

  scaling_config {
    # Scales to zero when nothing is asking for it. Satellite processing is
    # bursty by nature — a scene arrives, it is processed, and then nothing
    # happens for hours — and paying for an idle c6i.2xlarge between bursts is
    # most of what this pool would otherwise cost.
    desired_size = 0
    min_size     = 0
    max_size     = var.compute_max_size
  }

  taint {
    key    = "workload"
    value  = "compute"
    effect = "NO_SCHEDULE"
  }

  labels = {
    "node-pool" = "yieldpoint-compute"
    "workload"  = "compute"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_registry,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = { Name = "${local.name}-compute" }
}

# ── Add-ons ──────────────────────────────────────────────────────────────────

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "vpc-cni"
  addon_version = null

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "coredns"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  # CoreDNS will not schedule until there is a node to put it on, and a cluster
  # with no DNS looks like every service being broken rather than like a
  # missing add-on.
  depends_on = [aws_eks_node_group.general]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
}

# Without the EBS CSI driver every PersistentVolumeClaim stays Pending, which
# on this platform means Postgres and Kafka never start.
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi.arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [aws_eks_node_group.general]
}

# ── IAM ──────────────────────────────────────────────────────────────────────

resource "aws_iam_role" "cluster" {
  name = "${local.name}-eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "node" {
  name = "${local.name}-eks-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_worker" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_registry" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# IRSA: pods assume roles through the cluster's OIDC provider rather than
# inheriting the node role. Without it every pod on a node can do everything
# the node can, which on a multi-tenant platform means every service can read
# every bucket.
data "tls_certificate" "oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
}

locals {
  oidc_provider = replace(aws_iam_openid_connect_provider.eks.url, "https://", "")
}

resource "aws_iam_role" "ebs_csi" {
  name = "${local.name}-ebs-csi"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.eks.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_provider}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          "${local.oidc_provider}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# The role the platform's pods assume to reach S3 and Secrets Manager. Scoped
# to this deployment's buckets and secrets, not to the account's.
resource "aws_iam_role" "platform" {
  name = "${local.name}-platform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.eks.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "${local.oidc_provider}:sub" = "system:serviceaccount:yieldpoint*:*"
        }
        StringEquals = {
          "${local.oidc_provider}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "platform" {
  name = "${local.name}-platform"
  role = aws_iam_role.platform.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.imagery.arn,
          "${aws_s3_bucket.imagery.arn}/*",
          aws_s3_bucket.uploads.arn,
          "${aws_s3_bucket.uploads.arn}/*",
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [aws_secretsmanager_secret.database.arn]
      },
    ]
  })
}
