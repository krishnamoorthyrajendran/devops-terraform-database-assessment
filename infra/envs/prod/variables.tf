variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_app_subnet_cidrs" {
  type = list(string)
}

variable "private_db_subnet_cidrs" {
  type = list(string)
}

variable "app_port" {
  type    = number
  default = 80
}

variable "container_image" {
  type    = string
  default = "nginx:stable-alpine"
}

variable "ecs_cpu" {
  type = number
}

variable "ecs_memory" {
  type = number
}

variable "ecs_desired_count" {
  type = number
}

variable "db_name" {
  type    = string
  default = "hotel_db"
}

variable "db_username" {
  type    = string
  default = "hotel_admin"
}

variable "rds_instance_class" {
  type = string
}

variable "rds_allocated_storage" {
  type = number
}

variable "rds_backup_retention" {
  type = number
}

variable "rds_deletion_protection" {
  type = bool
}