variable "ecs_cluster_name" {
    type = string
}
variable "ecs_task_role_arn" {
}
variable "ecs_task_execution_role_arn" {
}
variable "subnets_private_ids" {
}
variable "ecs_sg_ids" {
}
variable "task_definitions" {
    type = map(object({
        family = string
        container_definitions_name = string
        container_definitions_image = string
    }))
    validation {
        condition     = can(var.task_definitions["manageKeywords"]) && can(var.task_definitions["issue"]) && can(var.task_definitions["keywordnews"])
        error_message = "task_definitions must include manageKeywords, issue, and keywordnews"
    }
}
variable "ecs_services" {
    type = map(object({
        name = string
        load_balancer_target_group_arn = string
        load_balancer_container_name = string
    }))
    validation {
        condition     = can(var.ecs_services["manageKeywords"]) && can(var.ecs_services["issue"]) && can(var.ecs_services["keywordnews"])
        error_message = "ecs_services must include manageKeywords, issue, and keywordnews"
    }
}