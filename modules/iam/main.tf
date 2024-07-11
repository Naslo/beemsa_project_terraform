resource "aws_iam_role" "ecs_task_role" {
    name = var.ecs_task_role_name
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
        Effect    = "Allow",
        Principal = {
            Service = "ecs-tasks.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
        }]
    })

    managed_policy_arns = var.ecs_task_role_managed_policy_arns
}

resource "aws_iam_role" "ecs_task_execution_role" {
    name = var.ecs_task_execution_role_name
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
        Effect    = "Allow",
        Principal = {
            Service = "ecs-tasks.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
        }]
    })

    managed_policy_arns = var.ecs_task_execution_role_managed_policy_arns
}

resource "aws_iam_role" "codebuild_role" {
    name = var.codebuild_role_name
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    Service = "codebuild.amazonaws.com"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })
    
    managed_policy_arns = var.codebuild_role_managed_policy_arns
}

resource "aws_iam_role" "codepipeline_role" {
    name = var.codepipeline_role_name

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    Service = "codepipeline.amazonaws.com"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
    role = aws_iam_role.codebuild_role.id

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                    "s3:*",
                    "codecommit:*",
                    "codebuild:*",
                    "ecs:*",
                    "ecr:*"
                ],
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role_policy" "codepipeline_role_policy" {
    role = aws_iam_role.codepipeline_role.id

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = [
                    "s3:*",
                    "codecommit:*",
                    "codebuild:*",
                    "codedeploy:*",
                    "ecs:*",
                    "ecr:*",
                    "iam:PassRole"
                ],
                Resource = "*"
            }
        ]
    })
}