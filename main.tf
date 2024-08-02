terraform {
    required_version = ">= 1.9, < 2.0"
    
    backend "s3" {
        bucket = "beemsa-terraform-state-bucket"
        key = "terraform.tfstate"
        region = "ap-northeast-2"
        encrypt = true
        dynamodb_table = "terraform_lock_table"
    }
}

provider "aws" {
    region = var.region_kr
}

provider "aws" {
    region = var.region_us
    alias = "usa"
}

module "global" {
    source = "./global"

    account_id = var.account_id
}

module "kr" {
    depends_on = [ 
        module.global
     ]
    source = "./regions/ap-northeast-2"

    github_token = var.github_token
    region = var.region_kr

    ecs_task_role_arn = module.global.ecs_task_role_arn
    ecs_task_execution_role_arn = module.global.ecs_task_execution_role_arn
    manageKeywords_codebuild_role_arn = module.global.manageKeywords_codebuild_role_arn
    issue_codebuild_role_arn = module.global.issue_codebuild_role_arn
    keywordnews_codebuild_role_arn = module.global.keywordnews_codebuild_role_arn
    codepipeline_role_arn = module.global.codepipeline_role_arn
}

module "usa" {
    providers = {
      aws = aws.usa
    }
    depends_on = [ 
        module.global
    ]
    source = "./regions/us-east-1"

    github_token = var.github_token
    region = var.region_us

    ecs_task_role_arn = module.global.ecs_task_role_arn
    ecs_task_execution_role_arn = module.global.ecs_task_execution_role_arn
    manageKeywords_codebuild_role_arn = module.global.manageKeywords_codebuild_role_arn
    issue_codebuild_role_arn = module.global.issue_codebuild_role_arn
    keywordnews_codebuild_role_arn = module.global.keywordnews_codebuild_role_arn
    codepipeline_role_arn = module.global.codepipeline_role_arn
}
