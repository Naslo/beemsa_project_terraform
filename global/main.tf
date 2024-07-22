module "iam_global" {
    source = "../modules/iam"

    account_id = var.account_id
    
    # ECS 역할/정책
    ecs_task_role_name           = "ecs_task_role"
    ecs_task_execution_role_name = "ecs_task_execution_role"

    ecs_task_role_managed_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
    ]
    ecs_task_execution_role_managed_policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
        "arn:aws:iam::aws:policy/CloudWatchFullAccess" # 얘 남겨두기(지표는 최대로)
    ]

    # CICD 역할/정책
    codebuild_role_name    = "codebuild_role"
    codepipeline_role_name = "codepipeline_role"

    codebuild_role_managed_policy_arns = [
        "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
    ]

    codepipeline_role_managed_policy_arns = [
        "arn:aws:iam::aws:policy/AWSCodeStarFullAccess",
        "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
    ]
}