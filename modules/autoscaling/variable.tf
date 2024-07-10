variable "ecs_cluster_name" {
    type = string
}
variable "autoscaling_policy_type" {
    type = string
}
variable "autoscaling_service_namespace" {
    type = string
}
variable "scalable_dimension" {
    type = string
}
variable "cpu_predefined_metric_type" {
    type = string
}
variable "memory_predefined_metric_type" {
    type = string
}
variable "autoscaling_targets" {
    type = map(object({
        service_name = string
        max_capacity = number
        min_capacity = number
    }))
    validation {
        condition     = can(var.autoscaling_targets["manageKeywords"]) && can(var.autoscaling_targets["issue"]) && can(var.autoscaling_targets["keywordnews"])
        error_message = "autoscaling_targets must include manageKeywords, issue, and keywordnews"
    }
}
variable "autoscaling_cpu" {
    type = map(object({
        name = string
        target_value = number
        scale_out_cooldown = number
        scale_in_cooldown = number
    }))
    validation {
        condition     = can(var.autoscaling_cpu["manageKeywords"]) && can(var.autoscaling_cpu["issue"]) && can(var.autoscaling_cpu["keywordnews"])
        error_message = "autoscaling_cpu must include manageKeywords, issue, and keywordnews"
    }
}
variable "autoscaling_memory" {
    type = map(object({
        name = string
        target_value = number
        scale_out_cooldown = number
        scale_in_cooldown = number
    }))
    validation {
        condition     = can(var.autoscaling_memory["manageKeywords"]) && can(var.autoscaling_memory["issue"]) && can(var.autoscaling_memory["keywordnews"])
        error_message = "autoscaling_memory must include manageKeywords, issue, and keywordnews"
    }
}