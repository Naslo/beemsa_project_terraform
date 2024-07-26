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
    managed_policy_arns = var.codepipeline_role_managed_policy_arns
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
    role = aws_iam_role.codebuild_role.id

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Resource": [
                    "arn:aws:logs:ap-northeast-2:${var.account_id}:log-group:/aws/codebuild/manageKeywords_codebuild",
                    "arn:aws:logs:ap-northeast-2:${var.account_id}:log-group:/aws/codebuild/manageKeywords_codebuild:*",
                    "arn:aws:logs:ap-northeast-2:${var.account_id}:log-group:/aws/codebuild/issue_codebuild",
                    "arn:aws:logs:ap-northeast-2:${var.account_id}:log-group:/aws/codebuild/issue_codebuild:*",
                    "arn:aws:logs:ap-northeast-2:${var.account_id}:log-group:/aws/codebuild/keywordnews_codebuild",
                    "arn:aws:logs:ap-northeast-2:${var.account_id}:log-group:/aws/codebuild/keywordnews_codebuild:*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "s3:PutObject",
                    "s3:GetObject",
                    "s3:GetObjectVersion",
                    "s3:GetBucketAcl",
                    "s3:GetBucketLocation"
                ],
                "Resource": [
                    "arn:aws:s3:::beemsa-cicd-bucket",
                    "arn:aws:s3:::beemsa-cicd-bucket/*",
                    "arn:aws:s3:::beemsa-cicd-bucket-usa",
                    "arn:aws:s3:::beemsa-cicd-bucket-usa/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "codebuild:CreateReportGroup",
                    "codebuild:CreateReport",
                    "codebuild:UpdateReport",
                    "codebuild:BatchPutTestCases",
                    "codebuild:BatchPutCodeCoverages"
                ],
                "Resource": [
                    "arn:aws:codebuild:ap-northeast-2:${var.account_id}:report-group/manageKeywords_codebuild",
                    "arn:aws:codebuild:ap-northeast-2:${var.account_id}:report-group/manageKeywords_codebuild:*",
                    "arn:aws:codebuild:ap-northeast-2:${var.account_id}:report-group/issue_codebuild",
                    "arn:aws:codebuild:ap-northeast-2:${var.account_id}:report-group/issue_codebuild:*",
                    "arn:aws:codebuild:ap-northeast-2:${var.account_id}:report-group/keywordnews_codebuild",
                    "arn:aws:codebuild:ap-northeast-2:${var.account_id}:report-group/keywordnews_codebuild:*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:BatchGetImage",
                    "ecr:CompleteLayerUpload",
                    "ecr:UploadLayerPart",
                    "ecr:InitiateLayerUpload",
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:PutImage"
                ],
                "Resource": [
                    "arn:aws:ecr:ap-northeast-2:${var.account_id}:repository/*"
                ]
            }
        ]
    })
}

resource "aws_iam_role_policy" "codepipeline_role_policy" {
    role = aws_iam_role.codepipeline_role.id

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "iam:PassRole"
                ],
                "Resource": "*",
                "Condition": {
                    "StringEqualsIfExists": {
                        "iam:PassedToService": [
                            "ecs-tasks.amazonaws.com",
                            "codebuild.amazonaws.com"
                        ]
                    }
                }
            },
            {
                "Effect": "Allow",
                "Action": [
                    "ecs:DescribeServices",
                    "ecs:UpdateService",
                    "ecs:DescribeTaskDefinition",
                    "ecs:RegisterTaskDefinition",
                    "ecs:DescribeClusters",
                    "ecs:RunTask"
                ],
                "Resource": [
                    "arn:aws:ecs:ap-northeast-2:${var.account_id}:cluster/beemsa_cluster",
                    "arn:aws:ecs:ap-northeast-2:${var.account_id}:service/beemsa_cluster/issue_service",
                    "arn:aws:ecs:ap-northeast-2:${var.account_id}:service/beemsa_cluster/keywordnews_service",
                    "arn:aws:ecs:ap-northeast-2:${var.account_id}:service/beemsa_cluster/manageKeywords_service",
                    "arn:aws:ecs:ap-northeast-2:${var.account_id}:task-definition/issue_task",
                    "arn:aws:ecs:ap-northeast-2:${var.account_id}:task-definition/keywordnews_task",
                    "arn:aws:ecs:ap-northeast-2:${var.account_id}:task-definition/manageKeywords_task",
                    "arn:aws:iam::${var.account_id}:role/ecs_task_role",
                    "arn:aws:iam::${var.account_id}:role/ecs_task_execution_role"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:BatchGetImage",
                    "ecr:InitiateLayerUpload",
                    "ecr:UploadLayerPart",
                    "ecr:CompleteLayerUpload",
                    "ecr:PutImage"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "s3:PutObject",
                    "s3:GetObject",
                    "s3:GetObjectVersion",
                    "s3:GetBucketAcl",
                    "s3:GetBucketLocation"
                ],
                "Resource": [
                    "arn:aws:s3:::beemsa-cicd-bucket",
                    "arn:aws:s3:::beemsa-cicd-bucket/*",
                    "arn:aws:s3:::beemsa-cicd-bucket-usa",
                    "arn:aws:s3:::beemsa-cicd-bucket-usa/*"
                ]
            }
        ]
    })
}