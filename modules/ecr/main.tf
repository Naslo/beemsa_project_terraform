data "aws_ecr_repository" "manage_keyword_repo" {
    name = var.manageKeywords_repository_name
}
data "aws_ecr_repository" "issue_repo" {
    name = var.issue_repository_name
}
data "aws_ecr_repository" "keywordnews_repo" {
    name = var.keywordnews_repository_name
}