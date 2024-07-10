output "manageKeywords_repository_url" {
    value = data.aws_ecr_repository.manage_keyword_repo.repository_url
}
output "issue_repository_url" {
    value = data.aws_ecr_repository.issue_repo.repository_url
}
output "keywordnews_repository_url" {
    value = data.aws_ecr_repository.keywordnews_repo.repository_url
}