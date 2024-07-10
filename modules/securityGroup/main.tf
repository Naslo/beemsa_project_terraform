resource "aws_security_group" "ALB-SG" {
    name = var.alb_sg_name
    vpc_id = var.vpc_id

    ingress {
        from_port = var.ALB_SG_ingress_port["http"]
        to_port = var.ALB_SG_ingress_port["http"]
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = var.ALB_SG_ingress_port["https"]
        to_port = var.ALB_SG_ingress_port["https"]
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = merge(var.tags, {Name = "${var.alb_sg_name}"})
}
resource "aws_security_group" "ECS-SG" {
    name = var.ecs_sg_name
    vpc_id = var.vpc_id

    ingress {
        from_port = var.ECS_SG_ingress_port["app_port"]
        to_port = var.ECS_SG_ingress_port["app_port"]
        protocol = "tcp"
        security_groups = [aws_security_group.ALB-SG.id]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = merge(var.tags, {Name = "${var.ecs_sg_name}"})
}