variable "project" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vault_address" {
  description = "HashiCorp Vault server URL"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Two availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI ID (must match your region)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
}

variable "frontend_min" {
  description = "Frontend ASG minimum instances"
  type        = number
  default     = 2
}

variable "frontend_max" {
  description = "Frontend ASG maximum instances"
  type        = number
  default     = 4
}

variable "backend_min" {
  description = "Backend ASG minimum instances"
  type        = number
  default     = 2
}

variable "backend_max" {
  description = "Backend ASG maximum instances"
  type        = number
  default     = 4
}

variable "db_name" {
  description = "RDS database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "dbadmin"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}
