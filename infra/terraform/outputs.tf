output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "kubeconfig_command" {
  description = "Run this to point kubectl at the cluster."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.main.name}"
}

output "platform_role_arn" {
  description = "Annotate the platform's ServiceAccounts with this for IRSA."
  value       = aws_iam_role.platform.arn
}

output "database_endpoint" {
  value = aws_db_instance.primary.endpoint
}

output "database_replica_endpoints" {
  description = "Point the read-heavy services — satellite, analytics, tiles — at these."
  value       = [for replica in aws_db_instance.replica : replica.endpoint]
}

output "database_secret_arn" {
  description = "The rotated credentials, for External Secrets to sync into the cluster."
  value       = aws_secretsmanager_secret.database.arn
}

output "imagery_bucket" {
  value = aws_s3_bucket.imagery.id
}

output "imagery_replica_bucket" {
  value = var.imagery_replication_enabled ? aws_s3_bucket.imagery_replica[0].id : null
}

output "uploads_bucket" {
  value = aws_s3_bucket.uploads.id
}

output "static_bucket" {
  value = local.cdn_enabled ? aws_s3_bucket.static[0].id : null
}

output "cdn_domain_name" {
  description = "Point the CDN domain's CNAME at this."
  value       = local.cdn_enabled ? aws_cloudfront_distribution.main[0].domain_name : null
}

# Not marked sensitive, because it is not: the password is generated into
# Secrets Manager and rotated from there, and this is only the initial value's
# location, never the value.
output "database_username" {
  value = aws_db_instance.primary.username
}
