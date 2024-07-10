resource "aws_codebuild_project" "codebuild_projects" {
    for_each = var.codebuild_projects

    name         = each.value.name
    service_role = each.value.role_arn
    source_version = "main"

    artifacts {
        type = "NO_ARTIFACTS"
    }

    environment {
        compute_type = "BUILD_GENERAL1_SMALL"
        image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
        type         = "LINUX_CONTAINER"

        environment_variable {
            name  = "GITHUB_TOKEN"
            value = var.github_token
            type  = "PLAINTEXT"
        }
    }

    source {
        type      = "GITHUB"
        location  = "https://github.com/Hyperkittys/BeeMSA_ECS.git"
        buildspec = each.value.buildspec
        report_build_status = true
    }
}