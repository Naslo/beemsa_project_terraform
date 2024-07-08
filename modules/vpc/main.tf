resource "aws_vpc" "VPC-ECS" {
    cidr_block = var.vpc_cidr
    tags = merge(var.tags, { Name = "${var.vpc_name}" })
}

resource "aws_subnet" "VPC-ECS-SUBNET-PUBLIC" {
    count = length(var.public_subnets)
    vpc_id = aws_vpc.VPC-ECS.id
    cidr_block = var.public_subnets[count.index]
    availability_zone = var.availability_zones[count.index]
    tags = merge(var.tags, { Name = "${var.subnet_public_prefix}-${count.index + 1}" })
}

resource "aws_subnet" "VPC-ECS-SUBNET-PRIVATE" {
    count = length(var.private_subnets)
    vpc_id = aws_vpc.VPC-ECS.id
    cidr_block = var.private_subnets[count.index]
    availability_zone = var.availability_zones[count.index]
    tags = merge(var.tags, { Name = "${var.subnet_private_prefix}-${count.index + 1}" })
}

resource "aws_route_table" "VPC-ECS-ROUTETABLE-PUBLIC" {
    vpc_id = aws_vpc.VPC-ECS.id
    route {
        cidr_block = var.public_route_table_cidr_block
        gateway_id = aws_internet_gateway.VPC-ECS-IGW.id
    }
    tags = merge(var.tags, { Name = "${var.public_route_table_name}" })
}

resource "aws_route_table" "VPC-ECS-ROUTETABLE-PRIVATE" {
    vpc_id = aws_vpc.VPC-ECS.id
    tags = merge(var.tags, { Name = "${var.private_route_table_name}" })
}

resource "aws_route_table_association" "ROUTETABLE-PUBLIC" {
    count = length(var.public_subnets)
    subnet_id = aws_subnet.VPC-ECS-SUBNET-PUBLIC[count.index].id
    route_table_id = aws_route_table.VPC-ECS-ROUTETABLE-PUBLIC.id
}

resource "aws_route_table_association" "ROUTETABLE-PRIVATE" {
    count = length(var.private_subnets)
    subnet_id = aws_subnet.VPC-ECS-SUBNET-PRIVATE[count.index].id
    route_table_id = aws_route_table.VPC-ECS-ROUTETABLE-PRIVATE.id
}

resource "aws_internet_gateway" "VPC-ECS-IGW" {
    vpc_id = aws_vpc.VPC-ECS.id
    tags = merge(var.tags, { Name = "${var.igw_name}" })
}

resource "aws_eip" "VPC-ECS-NAT-EIP" {
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_nat_gateway" "VPC-ECS-NAT-GW" {
    allocation_id = aws_eip.VPC-ECS-NAT-EIP.id
    subnet_id = aws_subnet.VPC-ECS-SUBNET-PUBLIC[0].id
    tags = merge(var.tags, { Name = "${var.nat_gw_name}" })
}

resource "aws_route" "ROUTETABLE-NAT" {
    route_table_id = aws_route_table.VPC-ECS-ROUTETABLE-PRIVATE.id
    destination_cidr_block = var.nat_route_table_destination_cidr_block
    nat_gateway_id = aws_nat_gateway.VPC-ECS-NAT-GW.id
}
