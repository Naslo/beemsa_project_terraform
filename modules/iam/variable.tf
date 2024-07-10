variable "ecs_task_role_name" {
    type = string
}
variable "ecs_task_execution_role_name" {
    type = string
}
variable "codebuild_role_name" {
    type = string
}
variable "codepipeline_role_name" {
    type = string
}
variable "ecs_task_role_managed_policy_arns" {
    type = list(string)
}
variable "ecs_task_execution_role_managed_policy_arns" {
    type = list(string)
}
variable "codebuild_role_managed_policy_arns" {
    type = list(string)
}
variable "codepipeline_role_managed_policy_arns" {
    type = list(string)
}