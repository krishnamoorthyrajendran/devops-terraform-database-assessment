project_name = "hotel-booking"

environment = "prod"

aws_region = "ap-south-1"

vpc_cidr = "10.1.0.0/16"

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

public_subnet_cidrs = [
  "10.1.1.0/24",
  "10.1.2.0/24"
]

private_app_subnet_cidrs = [
  "10.1.11.0/24",
  "10.1.12.0/24"
]

private_db_subnet_cidrs = [
  "10.1.21.0/24",
  "10.1.22.0/24"
]

app_port = 80

container_image = "nginx:stable-alpine"

ecs_cpu = 512

ecs_memory = 1024

ecs_desired_count = 2

db_name = "hotel_db"

db_username = "hotel_admin"

rds_instance_class = "db.t3.medium"

rds_allocated_storage = 50

rds_backup_retention = 14

rds_deletion_protection = true