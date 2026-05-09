output "vpc_id"              { value = aws_vpc.main.id }
output "public_subnet_ids"   { value = aws_subnet.public[*].id }
output "frontend_subnet_ids" { value = aws_subnet.frontend[*].id }
output "backend_subnet_ids"  { value = aws_subnet.backend[*].id }
output "db_subnet_ids"       { value = aws_subnet.database[*].id }
output "bastion_public_ip" { value = aws_instance.bastion.public_ip }
output "bastion_sg_id" { value = aws_security_group.bastion_sg.id }