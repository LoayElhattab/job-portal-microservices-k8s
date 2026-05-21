output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs (NAT, future ALB)."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs (EKS nodes and RDS)."
  value       = aws_subnet.private[*].id
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint."
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 CA cert for kubectl."
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "eks_nodes_security_group_id" {
  description = "Security group attached to EKS worker nodes (RDS ingress source)."
  value       = aws_security_group.eks_nodes.id
}

output "rds_endpoint" {
  description = "RDS hostname for k8s DB_HOST."
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "RDS port."
  value       = aws_db_instance.main.port
}

output "rds_username" {
  description = "RDS master username."
  value       = aws_db_instance.main.username
}

output "rds_password" {
  description = "RDS master password (sensitive). Store in k8s secret; do not commit."
  value       = random_password.db_master.result
  sensitive   = true
}

output "configure_kubectl" {
  description = "Command to merge kubeconfig after apply."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}
