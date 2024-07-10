output "cluster_name" {
    value = aws_ecs_cluster.ecs_cluster.name
}
output "manageKeywords_service_name" {
    value = var.ecs_services["manageKeywords"].name
}
output "issue_service_name" {
    value = var.ecs_services["issue"].name
}
output "keywordnews_service_name" {
    value = var.ecs_services["keywordnews"].name
}
output "manageKeywords_container_name" {
    value = var.task_definitions["manageKeywords"].container_definitions_name
}
output "issue_container_name" {
    value = var.task_definitions["issue"].container_definitions_name
}
output "keywordnews_containere_name" {
    value = var.task_definitions["keywordnews"].container_definitions_name
}