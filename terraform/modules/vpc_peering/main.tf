resource "aws_vpc_peering_connection" "this" {
  vpc_id      = var.requester_id
  peer_vpc_id = var.accepter_id
  auto_accept = true

  tags = {
    Name = "VPC 1 <> VPC 2"
  }
}