output "alb_sg_ids" {
    value = [
        aws_security_group.ALB-SG.id
    ]
}

output "ecs_sg_ids" {
    value = [
        aws_security_group.ECS-SG.id
    ]
}