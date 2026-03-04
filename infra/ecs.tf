# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "app-cluster"
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


#################################### FRONTEND ##################################################

# ECS Task Definition (Backend)
resource "aws_ecs_task_definition" "backend" {
  family                   = "backend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "backend"
      image = var.backend_image   # from ECR

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
      environment = [
        {
          name  = "REDIS_URL"
          value = "redis://task-redis.bzjzq4.0001.aps1.cache.amazonaws.com:6379/0"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/backend"
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "backend_logs" {
  name              = "/ecs/backend"
  retention_in_days = 7
}

# ECS Service
resource "aws_ecs_service" "backend" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
  subnets         = [
    aws_subnet.private_ecs_1.id,
    aws_subnet.private_ecs_2.id
  ]
  security_groups = [aws_security_group.ecs_sg.id]
  assign_public_ip = false  
}
  enable_execute_command = true
  
  load_balancer {
    target_group_arn = aws_lb_target_group.backend_tg.arn
    container_name   = "backend"
    container_port   = 8000
  }
  
    depends_on = [
      aws_lb_listener.alb_listener,
      aws_lb_listener_rule.api_rule,
      aws_lb_target_group.backend_tg
    ]
  
}
#Backend Target Group
resource "aws_lb_target_group" "backend_tg" {
  name     = "backend-tg-ip"
  port     = 8000
  protocol = "HTTP"
  target_type = "ip"    
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"   # FastAPI health check endpoint
    interval            = 30
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }
}
#################################### FRONTEND ##################################################


# ECS Task Definition (Frontend)
resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name  = "frontend"
    image = var.frontend_image   # from ECR

    portMappings = [
      {
        containerPort = 3000   # your frontend HTTP port
        protocol      = "TCP"
        
      }
    ]

    environment = [
      {
        name  = "API_BASE"
        value = "http://${aws_lb.app_alb.dns_name}"

      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/frontend"
        awslogs-region        = "ap-south-1"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

# CloudWatch Log Group for frontend
resource "aws_cloudwatch_log_group" "frontend_logs" {
  name              = "/ecs/frontend"
  retention_in_days = 7
}
# ECS Service (Frontend)
resource "aws_ecs_service" "frontend" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
  subnets         = [
    aws_subnet.private_ecs_1.id,
    aws_subnet.private_ecs_2.id
  ]
  security_groups = [aws_security_group.ecs_sg.id]
  assign_public_ip = false   
}
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = "frontend"
    container_port   = 3000
  }

  enable_execute_command = true
  
  
  depends_on = [
    aws_lb_listener.alb_listener
  ]
}

# Target Group for frontend 
resource "aws_lb_target_group" "frontend_tg" {
  name        = "frontend-tg-ip"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

################################################## CELERY ##################################################


# ECS Task Definition (Celery)
resource "aws_ecs_task_definition" "celery" {
  family                   = "celery-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  

  container_definitions = jsonencode([{
    name  = "celery"
    image = var.celery_image

  environment = [
  {
    name  = "REDIS_URL"
    value = "redis://task-redis.bzjzq4.0001.aps1.cache.amazonaws.com:6379/0"
  }
]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/celery"
        awslogs-region        = "ap-south-1"
        awslogs-stream-prefix = "ecs"
      }
    }
  }]) 
}

# CloudWatch Log Group for Celery
resource "aws_cloudwatch_log_group" "celery_logs" {
  name              = "/ecs/celery"
  retention_in_days = 7
}
# ECS Service (Celery)
resource "aws_ecs_service" "celery" {
  name            = "celery-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.celery.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
  subnets         = [
    aws_subnet.private_ecs_1.id,
    aws_subnet.private_ecs_2.id
  ]
  security_groups = [aws_security_group.ecs_sg.id]
  assign_public_ip = false   
}

  enable_execute_command = true 
  
}

resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  subnets         = var.public_subnets
  security_groups    = [aws_security_group.alb_sg.id] # allow HTTP 80
}



resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}


resource "aws_lb_listener_rule" "api_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/*", "/docs*", "/notify*","/task_status/*", "/health"]
    }
  }
}


