variable "vpc_id" {
}
variable "health_check_path" {
    type = string
}
variable "target_groups" {
    type = map(object({
        name = string
        port = number
        protocol = string
        target_type = string
    }))
    validation {
        condition     = can(var.target_groups["manageKeywords"]) && can(var.target_groups["issue"]) && can(var.target_groups["keywordnews"])
        error_message = "target_groups must include manageKeywords, issue, and keywordnews"
    }
}