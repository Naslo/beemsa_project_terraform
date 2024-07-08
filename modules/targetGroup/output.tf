output "manageKeywords_TG" {
    value = aws_lb_target_group.target_groups["manageKeywords"]
}
output "issue_TG" {
    value = aws_lb_target_group.target_groups["issue"]
}
output "keywordnews_TG" {
    value = aws_lb_target_group.target_groups["keywordnews"]
}
output "manageKeywords_TG_arn" {
    value = aws_lb_target_group.target_groups["manageKeywords"].arn
}
output "issue_TG_arn" {
    value = aws_lb_target_group.target_groups["issue"].arn
}
output "keywordnews_TG_arn" {
    value = aws_lb_target_group.target_groups["keywordnews"].arn
}