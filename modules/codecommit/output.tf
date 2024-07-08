output "codecommit_repository_name" {
    value = var.codecommit_repository_name
}
output "codecommit_repository_clone_url_http" {
    value = data.aws_codecommit_repository.codecommit_repo.clone_url_http
}