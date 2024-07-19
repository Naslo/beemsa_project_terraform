variable "github_token" {
    type = string
    sensitive = true
}
variable "region" {
    type = string
}
variable "ecs_task_role_arn" {
}
variable "ecs_task_execution_role_arn" {
}
variable "manageKeywords_codebuild_role_arn" {
}
variable "issue_codebuild_role_arn" {
}
variable "keywordnews_codebuild_role_arn" {
}
variable "codepipeline_role_arn" {
}