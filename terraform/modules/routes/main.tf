resource "aws_route_table" "this" {
  vpc_id = var.vpc_id
  
  dynamic "route" {
    for_each = var.routes
    content{
      cidr_block                = route.value.cidr_block
      gateway_id                = route.value.gateway_id
      nat_gateway_id            = route.value.nat_gateway_id
      vpc_peering_connection_id = route.value.vpc_peering_connection_id
    }
  }

  tags = {
    Name = var.routetable_name
  }
}

resource "aws_route_table_association" "this" {
  count          = length(var.subnet_id)
  subnet_id      = var.subnet_id[count.index]
  route_table_id = aws_route_table.this.id
}