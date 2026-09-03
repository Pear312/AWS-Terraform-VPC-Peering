provider "aws" {
  region = "us-east-1"
}
/////////////////////////////////
//
// VPC 1
//
/////////////////////////////////
resource "aws_vpc" "prod_vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "NextWork VPC 1"
  }
}

// Public Subnet 
resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.1.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "NextWork Public Subnet 1"
  }
}

// Network ACL
resource "aws_network_acl" "acl" {
  vpc_id = aws_vpc.prod_vpc.id
  subnet_ids = [aws_subnet.subnet_1.id]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "NextWork ACL"
  }
}

// Route Table
resource "aws_route_table" "prod_route_table" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    cidr_block = "10.2.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_to_vpc2.id
  }

  tags = {
    Name = "NextWork Public Route Table 1"
  }
}

resource "aws_route_table_association" "subnet_assoc" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.prod_route_table.id
}


// Security Group
resource "aws_security_group" "nextwork_sg" {
  name        = "NextWork Security Group"
  description = "A Security Group for the NextWork VPC."
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "All ICMP"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "NextWork Security Group"
  }
}

// Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "NextWork IG"
  }
}


/////////////////////////////////
//
// VPC 2
//
/////////////////////////////////
resource "aws_vpc" "prod_vpc_2" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "NextWork VPC 2"
  }
}

// Public Subnet 
resource "aws_subnet" "subnet_2" {
  vpc_id = aws_vpc.prod_vpc_2.id
  cidr_block = "10.2.0.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "NextWork Public Subnet 2"
  }
}

// Network ACL
resource "aws_network_acl" "acl2" {
  vpc_id = aws_vpc.prod_vpc_2.id
  subnet_ids = [aws_subnet.subnet_2.id]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "NextWork ACL"
  }
}

// Route Table
resource "aws_route_table" "prod_route_table2" {
  vpc_id = aws_vpc.prod_vpc_2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw2.id
  }

  route {
    cidr_block = "10.1.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_to_vpc2.id
  }

  tags = {
    Name = "NextWork Public Route Table 2"
  }
}

resource "aws_route_table_association" "subnet_assoc2" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.prod_route_table2.id
}


// Security Group 2
resource "aws_security_group" "nextwork_sg2" {
  name        = "NextWork Security Group"
  description = "A Security Group for the NextWork VPC."
  vpc_id      = aws_vpc.prod_vpc_2.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "All ICMP"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "NextWork Security Group 2"
  }
}

// Internet Gateway 2
resource "aws_internet_gateway" "gw2" {
  vpc_id = aws_vpc.prod_vpc_2.id

  tags = {
    Name = "NextWork IG 2"
  }
}


//////////////
// VPC Peering
//////////////
resource "aws_vpc_peering_connection" "vpc1_to_vpc2" {
  vpc_id      = aws_vpc.prod_vpc.id
  peer_vpc_id = aws_vpc.prod_vpc_2.id
  auto_accept = true

  tags = {
    Name = "VPC 1 <> VPC 2"
  }
}


#
# Launch EC2 into both private and public subnets
#

// EC2 VPC 1
resource "aws_instance" "public_server_1" {
  ami = "ami-0bdc7d025135d7b49"
  instance_type = "t2.micro"
  key_name = "devKey"

  subnet_id = aws_subnet.subnet_1.id

  vpc_security_group_ids = [aws_security_group.nextwork_sg.id]

  tags = {
    Name = "Instance - VPC 1"
  }
}

// EC2 VPC 2
resource "aws_instance" "public_server_2" {
  ami = "ami-0bdc7d025135d7b49"
  instance_type = "t2.micro"
  key_name = "devKey"

  subnet_id = aws_subnet.subnet_2.id

  vpc_security_group_ids = [aws_security_group.nextwork_sg2.id]

  tags = {
    Name = "Instance - VPC 2"
  }
}


///////////////////////////////
//      CloudWatch
//          &
//       Flow Logs
///////////////////////////////

// Cloudwatch log
resource "aws_cloudwatch_log_group" "log_group" {
  name = "/nextwork/vpc-flow-logs"
  retention_in_days = 5

  tags = {
    Name = "NextWorkVPCFlowLogsGroup"
  }
}

// Flow log
resource "aws_flow_log" "VPC_1" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  vpc_id          = aws_vpc.prod_vpc.id
  log_destination = aws_cloudwatch_log_group.log_group.arn
  traffic_type    = "ALL"
  max_aggregation_interval = 60
}

// IAM Policy  
resource "aws_iam_policy" "allow_write_send" {
  name        = "NextWorkVPCFlowLogsPolicy"
  path        = "/"
  description = "Allows VPC Flow Logs the permission to write logs and send them to CloudWatch"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        "Resource": "*"
      }
    ]
  })
}

// IAM role 
resource "aws_iam_role" "flow_log_role" {
  name = "Flow Log Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "Statement1"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      },
    ]
  })
}

// Attach permissions to role
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.flow_log_role.name
  policy_arn = aws_iam_policy.allow_write_send.arn
}

// step #5 Test vpc peering

