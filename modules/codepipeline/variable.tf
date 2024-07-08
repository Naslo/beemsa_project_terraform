variable "codepipeline_role_arn" {
}
variable "beemsa_codepipeline_name" {
    type = string
}
variable "codepipeline_bucket_name" {
    type = string
}
variable "codepipeline_artifact_store_type" {
    type = string
}
variable "ecs_cluster_name" {
    type = string
}
variable "source_stage_codecommit_name" {
    type = string
}
variable "source_stage_output_artifacts" {
    type = string
}
variable "codecommit_repository_name" {
    type = string
}
variable "codecommit_branch_name" {
    type = string
}
variable "build_stage_actions" {
    type = map(object({
        name = string
        output_artifacts = list(string)
        codebuild_project_name = string
    }))
    validation {
        condition     = can(var.build_stage_actions["manageKeywords"]) && can(var.build_stage_actions["issue"]) && can(var.build_stage_actions["keywordnews"])
        error_message = "build_stage_actions must include manageKeywords, issue, and keywordnews"
    }
}
variable "deploy_stage_actions" {
    type = map(object({
        name = string
        input_artifacts = list(string)
        service_name = string
    }))
    validation {
        condition     = can(var.deploy_stage_actions["manageKeywords"]) && can(var.deploy_stage_actions["issue"]) && can(var.deploy_stage_actions["keywordnews"])
        error_message = "deploy_stage_actions must include manageKeywords, issue, and keywordnews"
    }
}
variable "depoly_stage_file_name" {
    type = string
}