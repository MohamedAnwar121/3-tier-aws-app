output "vpc_id"              { value = aws_vpc.main.id }
output "public_subnet_ids"   { value = aws_subnet.public[*].id }
output "frontend_subnet_ids" { value = aws_subnet.frontend[*].id }
output "backend_subnet_ids"  { value = aws_subnet.backend[*].id }
output "db_subnet_ids"       { value = aws_subnet.database[*].id }
