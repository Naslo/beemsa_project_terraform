variable "lb_name" {
    type = string
}
variable "lb_type" {
    type = string
}
variable "lb_sg" {
    type = list(string)
}
variable "lb_subnets" {
}
variable "vpc_id" {
}
variable "host_name" {
    type = string
}
variable "domain_name" {
    type = string  
}
variable "http_listener_port" {
    type = number
}
variable "https_listener_port" {
    type = number
}
variable "listener_http_roles" {
    type = map(object({
        priority = string
        target_group_arn = string
        path_pattern = list(string)
    }))
    validation {
        condition     = can(var.listener_http_roles["manageKeywords"]) && can(var.listener_http_roles["issue"]) && can(var.listener_http_roles["keywordnews"])
        error_message = "listener_http_roles must include manageKeywords, issue, and keywordnews"
    }
}
variable "listener_https_roles" {
    type = map(object({
        priority = string
        target_group_arn = string
        path_pattern = list(string)
    }))
    validation {
        condition     = can(var.listener_https_roles["manageKeywords"]) && can(var.listener_https_roles["issue"]) && can(var.listener_https_roles["keywordnews"])
        error_message = "listener_https_roles must include manageKeywords, issue, and keywordnews"
    }
}