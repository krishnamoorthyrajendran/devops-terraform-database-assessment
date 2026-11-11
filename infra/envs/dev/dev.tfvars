project_name = "hotel-booking"

environment = "dev"

aws_region = "ap-south-1"

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_app_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

private_db_subnet_cidrs = [
  "10.0.21.0/24",
  "10.0.22.0/24"
]

app_port = 80

container_image = "nginx:stable-alpine"

ecs_cpu = 256

ecs_memory = 512

ecs_desired_count = 1

db_name = "hotel_db"

db_username = "hotel_admin"

rds_instance_class = "db.t3.micro"

rds_allocated_storage = 20

rds_backup_retention = 1

rds_deletion_protection = false