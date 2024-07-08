variable "vpc_id" {
}
variable "ALB_SG_ingress_port" {
    type = map(number)
}
variable "ECS_SG_ingress_port" {
    type = map(number)
}
variable "tags" {
    type = map(string)
    default = {}
}
variable "alb_sg_name" {
    type = string
}
variable "ecs_sg_name" {
    type = string
}