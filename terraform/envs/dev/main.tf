provider "aws" {
  region = var.region
}

///////////////
//           //
//   VPCS    //
//           //
///////////////
module "vpc_1" {
  source = "../../modules/vpc"
  
  cidr_block = "10.1.0.0/16"

  env = var.env
  instance_number = "1"
  igw_name = "IGW 1"
}

module "vpc_2" {
  source = "../../modules/vpc"
  
  cidr_block = "10.2.0.0/16"

  env = var.env
  instance_number = "2"
  igw_name = "IGW 2"
}


///////////////
//           //
//  Subnets  //
//           //
///////////////
module "subnet_1" {
  source = "../../modules/subnet"

  vpc_id = module.vpc_1.vpc_id
  cidr_block = "10.1.0.0/24"
  availability_zone = "us-east-1a"
  instance_number = "1"
}

module "subnet_2" {
  source = "../../modules/subnet"

  vpc_id = module.vpc_2.vpc_id
  cidr_block = "10.2.0.0/24"
  availability_zone = "us-east-1b"
  instance_number = "2"
}


///////////////////
//               //
//  Route Table  //
//               //
///////////////////
module "route_table_1" {
  source = "../../modules/routes"
  
  vpc_id = module.vpc_1.vpc_id

  routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.vpc_1.internet_gateway_id
    },
    {
      cidr_block                = "10.2.0.0/16"
      vpc_peering_connection_id = module.vpc_peering.id
    }
  ]

  routetable_name = "Route Table 1"

  subnet_id = [module.subnet_1.subnet_id]
}

module "route_table_2" {
  source = "../../modules/routes"
  
  vpc_id = module.vpc_2.vpc_id

  routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.vpc_2.internet_gateway_id
    },
    {
      cidr_block                = "10.1.0.0/16"
      vpc_peering_connection_id = module.vpc_peering.id
    }
  ]

  routetable_name = "Route Table 2"

  subnet_id = [module.subnet_2.subnet_id]
}


///////////////////
//               //
//  VPC Peering  //
//               //
///////////////////
module "vpc_peering" {
  source = "../../modules/vpc_peering"

  requester_id = module.vpc_1.vpc_id
  accepter_id  = module.vpc_2.vpc_id
}


///////////////////
//               //
//  Network ACL  //
//               //
///////////////////
module "aws_network_acl_1" {
  source = "../../modules/network_acl"

  vpc_id = module.vpc_1.vpc_id
  subnet_ids = [module.subnet_1.subnet_id]

  ingress = [
    {
      protocol   = "-1"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
    }
  ]

  egress = [
    {
      protocol   = "-1"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
    }
  ]
}

module "aws_network_acl_2" {
  source = "../../modules/network_acl"

  vpc_id = module.vpc_2.vpc_id
  subnet_ids = [module.subnet_2.subnet_id]

  ingress = [
    {
      protocol   = "-1"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
    }
  ]

  egress = [
    {
      protocol   = "-1"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
    }
  ]
}


///////////////////////
//                   //
//  Security Groups  //
//                   //
///////////////////////
module "security_group_1" {
  source = "../../modules/security_group"

  name        = "Security Group 1"
  description = "A Security Group for the VPC."
  vpc_id      = module.vpc_1.vpc_id

  ingress = [
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "All ICMP"
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

}

module "security_group_2" {
  source = "../../modules/security_group"

  name        = "Security Group 2"
  description = "A Security Group for the VPC."
  vpc_id      = module.vpc_2.vpc_id

  ingress = [
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "All ICMP"
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

}


/////////////////////
//                 //
//  EC2 Instances  //
//                 //
/////////////////////
module "instance_one" {
  source = "../../modules/EC2"

  ami = "ami-0bdc7d025135d7b49"
  instance_type = "t2.micro"

  subnet_id = module.subnet_1.subnet_id
  security_group_ids = [module.security_group_1.security_group_id]

  name = "Instance - VPC 1"
}

module "instance_two" {
  source = "../../modules/EC2"

  ami = "ami-0bdc7d025135d7b49"
  instance_type = "t2.micro"

  subnet_id = module.subnet_2.subnet_id
  security_group_ids = [module.security_group_2.security_group_id]

  name = "Instance - VPC 2"
}



// Cloudwatch log
resource "aws_cloudwatch_log_group" "log_group" {
  name = "vpc-flow-logs"
  retention_in_days = 5

  tags = {
    Name = "VPCFlowLogsGroup"
  }
}

// Flow log
resource "aws_flow_log" "VPC_1" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  vpc_id          = module.vpc_1.vpc_id
  log_destination = aws_cloudwatch_log_group.log_group.arn
  traffic_type    = "ALL"
  max_aggregation_interval = 60
}

// IAM Policy  
resource "aws_iam_policy" "allow_write_send" {
  name        = "VPCFlowLogsPolicy"
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
  name = "Flow_Log_Role"

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