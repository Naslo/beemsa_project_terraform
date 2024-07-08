data "aws_codecommit_repository" "codecommit_repo" {
    repository_name = var.codecommit_repository_name
}