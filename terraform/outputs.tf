output "public_alb_dns" {
  description = "Public ALB DNS — point your domain here"
  value       = module.alb.public_alb_dns
}

output "internal_alb_dns" {
  description = "Internal ALB DNS for backend"
  value       = module.alb.internal_alb_dns
}

output "rds_endpoint" {
  description = "RDS primary endpoint"
  value       = module.rds.rds_endpoint
  sensitive   = true
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
