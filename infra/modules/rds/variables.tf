variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_db_subnet_ids" {
  type = list(string)
}

variable "rds_security_group_id" {
  type = string
}

variable "db_name" {
  type    = string
  default = "hotel_db"
}

variable "db_username" {
  type    = string
  default = "hotel_admin"
}

variable "instance_class" {
  type = string
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "backup_retention_period" {
  type = number
}

variable "deletion_protection" {
  type = bool
}