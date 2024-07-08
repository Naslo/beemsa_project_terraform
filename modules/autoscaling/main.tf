resource "aws_appautoscaling_target" "autoscaling_targets" {
    for_each = var.autoscaling_targets

    max_capacity = 5
    min_capacity = 1
    resource_id = "service/${var.ecs_cluster_name}/${each.value.service_name}"
    scalable_dimension = var.scalable_dimension
    service_namespace = var.autoscaling_service_namespace
}

resource "aws_appautoscaling_policy" "autoscaling_cpu" {
    for_each = var.autoscaling_cpu

    name = each.value.name
    policy_type = var.autoscaling_policy_type
    service_namespace = var.autoscaling_service_namespace
    resource_id = aws_appautoscaling_target.autoscaling_targets[each.key].resource_id
    scalable_dimension = var.scalable_dimension
    
    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
            predefined_metric_type = var.cpu_predefined_metric_type
        }
        target_value = 70.0
        scale_out_cooldown = 60
        scale_in_cooldown = 60
    }
}

resource "aws_appautoscaling_policy" "autoscaling_memory" {
    for_each = var.autoscaling_memory
    
    name = each.value.name
    policy_type = var.autoscaling_policy_type
    service_namespace = var.autoscaling_service_namespace
    resource_id = aws_appautoscaling_target.autoscaling_targets[each.key].resource_id
    scalable_dimension = var.scalable_dimension
    
    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
            predefined_metric_type = var.memory_predefined_metric_type
        }
        target_value = 70.0
        scale_out_cooldown = 60
        scale_in_cooldown = 60
    }
}