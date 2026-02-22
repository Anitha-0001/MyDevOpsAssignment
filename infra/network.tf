resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { 
    Name = "app-vpc" 
    }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "app-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_subnet_assoc_1" {
  subnet_id      = var.public_subnets[0]
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_assoc_2" {
  subnet_id      = var.public_subnets[1]
  route_table_id = aws_route_table.public_rt.id
}


#resource "aws_subnet" "private" {
  #vpc_id            = aws_vpc.main.id
  #cidr_block        = "10.0.2.0/24"
  #availability_zone = "ap-south-1a"

  #tags = {
   # Name = "private-subnet"
  #}
#}

resource "aws_subnet" "private_ecs_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"
  tags = { Name = "private-ecs-1" }
}

resource "aws_subnet" "private_ecs_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-1b"
  tags = { Name = "private-ecs-2" }
}
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.public_subnets[0]   # must be public subnet
  tags = { Name = "app-nat" }
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "private-rt" }
}

resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_ecs_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_ecs_2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group_rule" "ecs_outbound_https" {
  type            = "egress"
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
  security_group_id = aws_security_group.ecs_sg.id
  cidr_blocks     = ["0.0.0.0/0"]
}


resource "aws_iam_role" "ecs_execution_role" {
  name = "ecsExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_ssm" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_role_policy" "ecs_task_exec_cmd" {
  name = "ecs-task-exec-command"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecs:ExecuteCommand",
        "ssm:StartSession",
        "ssm:DescribeSessions",
        "ssm:TerminateSession"
      ]
      Resource = "*"
    }]
  })
}
