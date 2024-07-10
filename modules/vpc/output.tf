output "vpc_id" {
    value = aws_vpc.VPC-ECS.id
}
output "lb_public_subnets" {
    value = aws_subnet.VPC-ECS-SUBNET-PUBLIC[*].id
}
output "ecs_private_subnets" {
    value = aws_subnet.VPC-ECS-SUBNET-PRIVATE[*].id
}