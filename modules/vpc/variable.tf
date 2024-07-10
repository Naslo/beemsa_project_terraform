variable "vpc_name" {
    type = string
}
variable "public_route_table_name" {
    type = string
}
variable "private_route_table_name" {
    type = string
}
variable "igw_name" {
    type = string
}
variable "nat_gw_name" {
    type = string
}
variable "vpc_cidr" {
    type = string
}
variable "public_subnets" {
    type = list(string)
}
variable "private_subnets" {
    type = list(string)
}
variable "availability_zones" {
    type = list(string)
}
variable "tags" {
    type = map(string)
    default = {}
}
variable "subnet_public_prefix" {
    type = string
}
variable "subnet_private_prefix" {
    type = string
}
variable "public_route_table_cidr_block" {
    type = string
}
variable "nat_route_table_destination_cidr_block" {
    type = string
}