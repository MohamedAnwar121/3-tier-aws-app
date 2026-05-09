output "public_alb_dns"  { value = aws_lb.public.dns_name }
output "internal_alb_dns" { value = aws_lb.internal.dns_name }
output "frontend_tg_arn"  { value = aws_lb_target_group.frontend.arn }
output "backend_tg_arn"   { value = aws_lb_target_group.backend.arn }
