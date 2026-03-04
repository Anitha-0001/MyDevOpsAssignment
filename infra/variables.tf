variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "project_name" {
  description = "DevOps Assignment Project"
  default     = "devops-assignment"
}

variable "environment" {
  description = "Environment name"
  default     = "dev"
}

variable "redis_port" {
  default = 6379
}

variable "backend_port" {
  default = 8000
}

variable "frontend_port" {
  default = 3000
}

variable "frontend_image" {
  description = "ECR image for frontend"
  type        = string
  default     = "758604744414.dkr.ecr.ap-south-1.amazonaws.com/frontend:latest"
}
variable "celery_image" {
  description = "ECR image for celery"
  type        = string
  default     = "758604744414.dkr.ecr.ap-south-1.amazonaws.com/celery:latest"
}
variable "backend_image" {
  description = "ECR image for backend"
  type        = string
  default     = "758604744414.dkr.ecr.ap-south-1.amazonaws.com/backend:latest"
}


variable "public_subnets" {
  default = [
    "subnet-0e3d3ea4e86352538",  # existing subnet
    "subnet-0f13ec7bf778a1d6e"   # new subnet in a different AZ
  ]
}


