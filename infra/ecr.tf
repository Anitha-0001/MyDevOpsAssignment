resource "aws_ecr_repository" "frontend" {
  name = "frontend"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
    
  }
   tags = {
    Name = "frontend"
  }
}

resource "aws_ecr_repository" "backend" {
  name = "backend"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
    
  }

  tags = {
    Name = "backend"
  }
}

resource "aws_ecr_repository" "celery" {
  name = "celery"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
    
  }
   tags = {
    Name = "celery"
  }
}
