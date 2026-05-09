variable "project"            { type = string }
variable "environment"        { type = string }
variable "vpc_id"             { type = string }
variable "public_subnets"     { type = list(string) }
variable "frontend_subnets"   { type = list(string) }
variable "public_alb_sg_id"   { type = string }
variable "internal_alb_sg_id" { type = string }
