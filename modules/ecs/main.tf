resource "aws_ecs_cluster" "ecs_cluster" {
    name = var.ecs_cluster_name
    
    setting {
        name = "containerInsights"
        value = "enabled"
    }

    capacity_providers = [
        "FARGATE",
        "FARGATE_SPOT"
    ]

    default_capacity_provider_strategy {
        base = 1
        weight = 1
        capacity_provider = "FARGATE"
    }

    default_capacity_provider_strategy {
        capacity_provider = "FARGATE_SPOT"
        weight = 3  # Fargate Spot에 더 높은 가중치를 부여할 수 있음
    }
}

resource "aws_ecs_task_definition" "task_definitions" {
    for_each = var.task_definitions

    family = each.value.family
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    task_role_arn = var.ecs_task_role_arn                # 태스크 내에서 실행되는 애플리케이션이 사용할 aws 리소스에 대한 권한 부여
    execution_role_arn = var.ecs_task_execution_role_arn # 태스크를 실행할 때 필요한 권한
    cpu = 1024
    memory = 2048
    runtime_platform {
        cpu_architecture = "X86_64"
        operating_system_family = "LINUX"
    }

    container_definitions = jsonencode([
        {
            name = each.value.container_definitions_name
            image = "${each.value.container_definitions_image}:latest"
            portMappings = [
                {
                    containerPort = 5000
                    hostPort = 5000
                    protocol = "tcp"
                }
            ],
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group" = "/ecs/manageKeywords"
                    "awslogs-create-group" = "true"
                    "awslogs-region" = "ap-northeast-2"
                    "awslogs-stream-prefix" = "ecs"
                }
            }
        }
    ])
}

resource "aws_ecs_service" "ecs_services" {
    for_each = var.ecs_services
    name = each.value.name
    cluster = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.task_definitions[each.key].arn
    desired_count = 1
    launch_type = "FARGATE"
    network_configuration {
        subnets = var.subnets_private_ids
        security_groups = var.ecs_sg_ids
        assign_public_ip = false
    }
    load_balancer {
        target_group_arn = each.value.load_balancer_target_group_arn
        container_name = each.value.load_balancer_container_name
        container_port = 5000
    }
}

resource "aws_appautoscaling_target" "autoscaling_targets" {
    for_each = var.ecs_services

    max_capacity = each.value.max_capacity
    min_capacity = each.value.min_capacity
    resource_id = "service/${var.ecs_cluster_name}/${each.value.name}"
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
        target_value = each.value.target_value
        scale_out_cooldown = each.value.scale_out_cooldown
        scale_in_cooldown = each.value.scale_in_cooldown
    }
}