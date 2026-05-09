variable "project"     { type = string }
variable "environment" { type = string }
variable "vpc_id"      { type = string }
variable "vpc_cidr"    { type = string }
variable "bastion_sg_id" {
  description = "The ID of the Bastion Security Group"
  type        = string
}