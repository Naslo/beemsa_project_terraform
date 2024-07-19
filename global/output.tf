output "ecs_task_role_arn" {
    value = module.iam_global.ecs_task_role_arn
}
output "ecs_task_execution_role_arn" {
    value = module.iam_global.ecs_task_execution_role_arn
}
output "codepipeline_role_arn" {
    value = module.iam_global.codepipeline_role_arn
}
output "manageKeywords_codebuild_role_arn" {
    value = module.iam_global.manageKeywords_codebuild_role_arn
}
output "issue_codebuild_role_arn" {
    value = module.iam_global.manageKeywords_codebuild_role_arn
}
output "keywordnews_codebuild_role_arn" {
    value = module.iam_global.manageKeywords_codebuild_role_arn
}