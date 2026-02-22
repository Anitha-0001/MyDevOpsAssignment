resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  description = "Subnet group for Redis cluster"
  subnet_ids = [
  aws_subnet.private_ecs_1.id,
  aws_subnet.private_ecs_2.id
  ]

  tags = {
    Name = "redis-subnet-group"
  }
}
