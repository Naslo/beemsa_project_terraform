variable "codebuild_projects" {
    type = map(object({
        name = string
        buildspec = string
        role_arn = string
    }))
    validation {
        condition     = can(var.codebuild_projects["manageKeywords"]) && can(var.codebuild_projects["issue"]) && can(var.codebuild_projects["keywordnews"])
        error_message = "codebuild_projects must include manageKeywords, issue, and keywordnews"
    }
}
variable "github_token" {
    type = string
}
variable "manageKeywords_codebuild_role_arn" {
}
variable "issue_codebuild_role_arn" {
}
variable "keywordnews_codebuild_role_arn" {
}