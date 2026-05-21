variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment label (e.g. dev). Document multi_az=true for prod RDS."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Short project name used in resource naming."
  type        = string
  default     = "jobportal"
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = "jobportal-dev"
}

variable "cluster_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.29"
}

variable "eks_node_instance_types" {
  description = "EC2 instance types for the EKS managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  type    = number
  default = 2
}

variable "eks_node_min_size" {
  type    = number
  default = 1
}

variable "eks_node_max_size" {
  type    = number
  default = 3
}

variable "rds_instance_class" {
  description = "RDS instance class. Dev-sized; scale up for prod."
  type        = string
  default     = "db.t4g.micro"
}

variable "rds_engine_version" {
  description = "PostgreSQL major.minor for RDS (matches project Postgres 16)."
  type        = string
  default     = "16.4"
}

variable "rds_allocated_storage" {
  type    = number
  default = 20
}

variable "db_username" {
  description = "RDS master username (matches k8s DB_USER / POSTGRES_USER)."
  type        = string
  default     = "jobportal"
}
