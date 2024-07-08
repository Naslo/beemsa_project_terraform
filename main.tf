terraform {
    required_version = ">= 1.9, < 2.0"
}

provider "aws" {
    region = var.region_kr
}

module "vpc" {
    source = "./modules/vpc"
    
    vpc_name    = "VPC-ECS"
    igw_name    = "VPC-ECS-IGW"
    nat_gw_name = "VPC-ECS-NAT-GW"

    subnet_public_prefix     = "VPC-ECS-SUBNET-PUBLIC"
    subnet_private_prefix    = "VPC-ECS-SUBNET-PRIVATE"
    public_route_table_name  = "VPC-ECS-ROUTETABLE-PUBLIC"
    private_route_table_name = "VPC-ECS-ROUTETABLE-PRIVATE"

    availability_zones = ["ap-northeast-2a", "ap-northeast-2b"]

    vpc_cidr        = "10.0.0.0/16"
    public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

    public_route_table_cidr_block          = "0.0.0.0/0"
    nat_route_table_destination_cidr_block = "0.0.0.0/0"
}

module "security_groups" {
    source = "./modules/securityGroup"

    vpc_id      = module.vpc.vpc_id
    alb_sg_name = "ALB-SG"
    ecs_sg_name = "ECS-SG"

    ALB_SG_ingress_port = {
        "http"  = 80
        "https" = 443
    }
    ECS_SG_ingress_port = {
        "app_port" = 5000
    }
}

module "iam" {
    source = "./modules/iam"

    # ECS 역할/정책
    ecs_task_role_name           = "ecs_task_role"
    ecs_task_execution_role_name = "ecs_task_execution_role"

    ecs_task_role_managed_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
    ]
    ecs_task_execution_role_managed_policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
        "arn:aws:iam::aws:policy/CloudWatchFullAccess"
    ]

    # CICD 역할/정책
    codebuild_role_name    = "codebuild_role"
    codepipeline_role_name = "codepipeline_role"
    
    codebuild_role_managed_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
    ]
    codepipeline_role_managed_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
    ]
}

module "lb" {
    source = "./modules/lb"

    vpc_id     = module.vpc.vpc_id
    
    lb_name    = "ALB-ECS"
    lb_type    = "application"
    lb_subnets = module.vpc.lb_public_subnets
    lb_sg      = module.security_groups.alb_sg_ids

    host_name = module.route53.route53_zone_name
    domain_name = module.route53.route53_record_name

    http_listener_port  = 80
    https_listener_port = 443

    listener_http_roles = {
        "manageKeywords" = {
            priority = 20
            target_group_arn = module.target_group.manageKeywords_TG_arn
            path_pattern = ["/manageKeywords*"]
        }
        "issue" = {
            priority = 30
            target_group_arn = module.target_group.issue_TG_arn
            path_pattern = ["/issue"]
        }
        "keywordnews" = {
            priority = 40
            target_group_arn = module.target_group.keywordnews_TG_arn
            path_pattern = ["/news/*"]
        }
    }

    listener_https_roles = {
        "manageKeywords" = {
            priority = 20
            target_group_arn = module.target_group.manageKeywords_TG_arn
            path_pattern = ["/manageKeywords*"]
        }
        "issue" = {
            priority = 30
            target_group_arn = module.target_group.issue_TG_arn
            path_pattern = ["/issue"]
        }
        "keywordnews" = {
            priority = 40
            target_group_arn = module.target_group.keywordnews_TG_arn
            path_pattern = ["/news/*"]
        }
    }
}

module "route53" {
    source = "./modules/route53"

    route53_zone_name   = "hyperkittys.shop"
    route53_record_name = "api.hyperkittys.shop"

    alb_dns_name = module.lb.alb_dns_name
    alb_zone_id  = module.lb.alb_zone_id
}

module "target_group" {
    source = "./modules/targetGroup"

    vpc_id            = module.vpc.vpc_id
    health_check_path = "/health"

    target_groups = {
        "manageKeywords" = {
            name = "manageKeywords-TG"
            port = 5000
            protocol = "HTTP"
            target_type = "ip"
        }
        "issue" = {
            name = "issue-TG"
            port = 5000
            protocol = "HTTP"
            target_type = "ip"
        }
        "keywordnews" = {
            name = "keywordnews-TG"
            port = 5000
            protocol = "HTTP"
            target_type = "ip"
        }
    }
}

module "ecr" {
    source = "./modules/ecr"

    manageKeywords_repository_name = "keyword-management-service"
    issue_repository_name          = "hot-issue-service"
    keywordnews_repository_name    = "keyword-news-service"
}

module "ecs" {
    source = "./modules/ecs"
    depends_on = [
        module.lb,
        module.iam,
        module.target_group
    ]
    
    ecs_cluster_name    = "beemsa_cluster"
    ecs_task_role_arn           = module.iam.ecs_task_role_arn
    ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn

    ecs_sg_ids          = module.security_groups.ecs_sg_ids
    subnets_private_ids = module.vpc.ecs_private_subnets

    task_definitions = {
        "manageKeywords" = {
            family = "manageKeywords_task"
            container_definitions_name = "manageKeyword_container"
            container_definitions_image = module.ecr.manageKeywords_repository_url
        }
        "issue" = {
            family = "issue_task"
            container_definitions_name = "issue_container"
            container_definitions_image = module.ecr.issue_repository_url
        }
        "keywordnews" = {
            family = "keywordnews_task"
            container_definitions_name = "keywordnews_container"
            container_definitions_image = module.ecr.keywordnews_repository_url
        }
    }
    ecs_services = {
        "manageKeywords" = {
            name = "manageKeywords_service"
            load_balancer_target_group_arn = module.target_group.manageKeywords_TG.arn
            load_balancer_container_name = "manageKeyword_container"
        }
        "issue" = {
            name = "issue_service"
            load_balancer_target_group_arn = module.target_group.issue_TG.arn
            load_balancer_container_name = "issue_container"
        }
        "keywordnews" = {
            name = "keywordnews_service"
            load_balancer_target_group_arn = module.target_group.keywordnews_TG.arn
            load_balancer_container_name = "keywordnews_container"
        }
    }
}

module "autoscaling" {
    source = "./modules/autoscaling"

    ecs_cluster_name = module.ecs.cluster_name
    autoscaling_policy_type = "TargetTrackingScaling"
    autoscaling_service_namespace = "ecs"
    scalable_dimension = "ecs:service:DesiredCount"
    cpu_predefined_metric_type = "ECSServiceAverageCPUUtilization"
    memory_predefined_metric_type = "ECSServiceAverageMemoryUtilization"

    autoscaling_targets = {
        "manageKeywords" = {
            service_name = module.ecs.manageKeywords_service_name
        }
        "issue" = {
            service_name = module.ecs.issue_service_name
        }
        "keywordnews" = {
            service_name = module.ecs.keywordnews_service_name
        }
    }
    autoscaling_cpu = {
        "manageKeywords" = {
            name = "manageKeywords_scale_cpu"
        }
        "issue" = {
            name = "issue_scale_cpu"
        }
        "keywordnews" = {
            name = "keywordnews_scale_cpu"
        }
    }
    autoscaling_memory = {
        "manageKeywords" = {
            name = "manageKeywords_scale_memory"
        }
        "issue" = {
            name = "issue_scale_memory"
        }
        "keywordnews" = {
            name = "keywordnews_scale_memory"
        }
    }
}

module "s3" {
    source = "./modules/s3"

    codepipeline_bucket_name = "beemsa-cicd-bucket"
}

module "codecommit" {
    source = "./modules/codecommit"

    codecommit_repository_name = "BeeMSA_ECS"
}

module "codebuild" {
    source = "./modules/codebuild"
    depends_on = [ 
        module.iam
    ]

    codebuild_projects = {
        manageKeywords = {
            name = "manageKeywords_codebuild"
            buildspec = "keyword_management/buildspec.yml"
            role_arn = module.iam.manageKeywords_codebuild_role_arn
        }
        issue = {
            name = "issue_codebuild"
            buildspec = "issue/buildspec.yml"
            role_arn = module.iam.issue_codebuild_role_arn
        }
        keywordnews = {
            name = "keywordnews_codebuild"
            buildspec = "keyword_news/buildspec.yml"
            role_arn = module.iam.keywordnews_codebuild_role_arn
        }
    }

    manageKeywords_codebuild_role_arn = module.iam.manageKeywords_codebuild_role_arn
    issue_codebuild_role_arn = module.iam.issue_codebuild_role_arn
    keywordnews_codebuild_role_arn = module.iam.keywordnews_codebuild_role_arn
    codecommit_repo_clone_url_http = module.codecommit.codecommit_repository_clone_url_http
}

module "codepipeline" {
    source = "./modules/codepipeline"
    depends_on = [
        module.s3,
        module.codecommit,
        module.codebuild,
        module.ecs,
        module.iam
    ]
    
    beemsa_codepipeline_name         = "BeeMSA_codepipeline"
    codepipeline_artifact_store_type = "S3"
    codepipeline_bucket_name         = module.s3.codepipeline_bucket_name
    codepipeline_role_arn            = module.iam.codepipeline_role_arn

    source_stage_codecommit_name  = "CodeCommit_Source"
    source_stage_output_artifacts = "SourceArtifacts"
    codecommit_repository_name    = module.codecommit.codecommit_repository_name
    codecommit_branch_name        = "master"

    ecs_cluster_name       = module.ecs.cluster_name
    depoly_stage_file_name = "imagedefinitions.json"

    build_stage_actions = {
        "manageKeywords" = {
            name = "manageKeywords_build"
            output_artifacts = ["manageKeywords_BuildArtifacts"]
            codebuild_project_name = module.codebuild.manageKeywords_codebuild_name
        }
        "issue" = {
            name = "issue_build"
            output_artifacts = ["issue_BuildArtifacts"]
            codebuild_project_name = module.codebuild.issue_codebuild_name
        }
        "keywordnews" = {
            name = "keywordnews_build"
            output_artifacts = ["keywordnews_BuildArtifacts"]
            codebuild_project_name = module.codebuild.keywordnews_codebuild_name
        }
    }

    deploy_stage_actions = {
        "manageKeywords" = {
            name = "manageKeywords_deploy"
            input_artifacts = ["manageKeywords_BuildArtifacts"]
            service_name  = module.ecs.manageKeywords_service_name
        }
        "issue" = {
            name = "issue_deploy"
            input_artifacts = ["issue_BuildArtifacts"]
            service_name  = module.ecs.issue_service_name
        }
        "keywordnews" = {
            name = "keywordnews_deploy"
            input_artifacts = ["keywordnews_BuildArtifacts"]
            service_name  = module.ecs.keywordnews_service_name
        }
    }
}