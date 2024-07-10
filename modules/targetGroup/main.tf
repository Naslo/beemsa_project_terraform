resource "aws_lb_target_group" "target_groups" {
    for_each = var.target_groups

    name = each.value.name
    port = each.value.port
    protocol = each.value.protocol
    vpc_id = var.vpc_id
    target_type = each.value.target_type

    health_check {
        path = var.health_check_path
    }
}