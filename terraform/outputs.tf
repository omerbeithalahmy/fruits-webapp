output "alb_dns_name" {
    description = "ALB DNS name"
    value = aws_lb.app_lb.dns_name
}