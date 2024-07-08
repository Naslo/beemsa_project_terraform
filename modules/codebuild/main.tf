resource "aws_codebuild_project" "codebuild_projects" {
    for_each = var.codebuild_projects

    name         = each.value.name
    service_role = each.value.role_arn

    artifacts {
        type = "NO_ARTIFACTS"
    }
    environment {
        compute_type = "BUILD_GENERAL1_SMALL"
        image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
        type         = "LINUX_CONTAINER"
    }
    source {
        type      = "CODECOMMIT"
        location  = var.codecommit_repo_clone_url_http
        buildspec = each.value.buildspec
    }
}