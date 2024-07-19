module "vpc" {
    source = "../../modules/vpc"

    vpc_name    = "VPC-ECS"
    igw_name    = "VPC-ECS-IGW"
    nat_gw_name = "VPC-ECS-NAT-GW"

    subnet_public_prefix     = "VPC-ECS-SUBNET-PUBLIC"
    subnet_private_prefix    = "VPC-ECS-SUBNET-PRIVATE"
    public_route_table_name  = "VPC-ECS-ROUTETABLE-PUBLIC"
    private_route_table_name = "VPC-ECS-ROUTETABLE-PRIVATE"

    availability_zones = ["us-east-1a", "us-east-1b"]

    vpc_cidr        = "10.0.0.0/16"
    public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

    public_route_table_cidr_block          = "0.0.0.0/0"
    nat_route_table_destination_cidr_block = "0.0.0.0/0"
}

module "security_groups" {
    source = "../../modules/securityGroup"

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

module "route53" {
    source = "../../modules/route53"

    route53_zone_name   = "hyperkittys.shop"
    route53_record_name = "api.hyperkittys.shop"

    alb_dns_name = module.lb.alb_dns_name
    alb_zone_id  = module.lb.alb_zone_id

    continent_location_name = "NA"
    continent_record_name = "NA-record"
}

module "lb" {
    source = "../../modules/lb"

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

module "target_group" {
    source = "../../modules/targetGroup"

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
    source = "../../modules/ecr"

    manageKeywords_repository_name = "keyword-management-service"
    issue_repository_name          = "hot-issue-service"
    keywordnews_repository_name    = "keyword-news-service"
}

module "ecs" {
    source = "../../modules/ecs"
    depends_on = [
        module.lb,
        module.target_group
    ]
    
    ecs_cluster_name    = "beemsa_cluster"
    ecs_task_role_arn           = var.ecs_task_role_arn
    ecs_task_execution_role_arn = var.ecs_task_execution_role_arn

    ecs_sg_ids          = module.security_groups.ecs_sg_ids
    subnets_private_ids = module.vpc.ecs_private_subnets

    autoscaling_policy_type = "TargetTrackingScaling"
    autoscaling_service_namespace = "ecs"
    scalable_dimension = "ecs:service:DesiredCount"
    cpu_predefined_metric_type = "ECSServiceAverageCPUUtilization"
    memory_predefined_metric_type = "ECSServiceAverageMemoryUtilization"

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
            max_capacity = 5
            min_capacity = 1
            autoscaling_name = "manageKeywords_scale_cpu"
            target_value = 70
            scale_out_cooldown = 30
            scale_in_cooldown = 30
        }
        "issue" = {
            name = "issue_service"
            load_balancer_target_group_arn = module.target_group.issue_TG.arn
            load_balancer_container_name = "issue_container"
            max_capacity = 5
            min_capacity = 1
            autoscaling_name = "issue_scale_cpu"
            target_value = 70
            scale_out_cooldown = 30
            scale_in_cooldown = 30
        }
        "keywordnews" = {
            name = "keywordnews_service"
            load_balancer_target_group_arn = module.target_group.keywordnews_TG.arn
            load_balancer_container_name = "keywordnews_container"
            max_capacity = 5
            min_capacity = 1
            autoscaling_name = "keywordnews_scale_cpu"
            target_value = 70
            scale_out_cooldown = 30
            scale_in_cooldown = 30
        }
    }
}

module "s3" {
    source = "../../modules/s3"

    codepipeline_bucket_name = "beemsa-cicd-bucket-usa"
}

module "codebuild" {
    source = "../../modules/codebuild"

    codebuild_projects = {
        manageKeywords = {
            name = "manageKeywords_codebuild"
            buildspec = "keyword_management/buildspec.yml"
            role_arn = var.manageKeywords_codebuild_role_arn
        }
        issue = {
            name = "issue_codebuild"
            buildspec = "issue/buildspec.yml"
            role_arn = var.issue_codebuild_role_arn
        }
        keywordnews = {
            name = "keywordnews_codebuild"
            buildspec = "keyword_news/buildspec.yml"
            role_arn = var.keywordnews_codebuild_role_arn
        }
    }

    manageKeywords_codebuild_role_arn = var.manageKeywords_codebuild_role_arn
    issue_codebuild_role_arn = var.issue_codebuild_role_arn
    keywordnews_codebuild_role_arn = var.keywordnews_codebuild_role_arn
    github_token = var.github_token
    aws_region = var.region
}

module "codepipeline" {
    source = "../../modules/codepipeline"
    depends_on = [
        module.s3,
        module.codebuild,
        module.ecs
    ]
    
    beemsa_codepipeline_name         = "BeeMSA_codepipeline"
    codepipeline_artifact_store_type = "S3"
    codepipeline_bucket_name         = module.s3.codepipeline_bucket_name
    codepipeline_role_arn            = var.codepipeline_role_arn

    source_stage_github_name  = "GitHub_Source"
    source_stage_output_artifacts = "SourceArtifacts"
    github_branch_name        = "main"
    github_owner = "Hyperkittys"
    github_repository = "BeeMSA_ECS"
    github_token = var.github_token
    
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