variable "profile" {
  description = "Name of your profile inside ~/.aws/credentials"
}

variable "application_name" {
  description = "Name of your application"
}

variable "application_description" {
  description = "Sample application based on Elastic Beanstalk & Docker"
}

variable "application_environment" {
  description = "Deployment stage e.g. 'staging', 'production', 'test', 'integration'"
}

variable "region" {
  default     = "eu-west-1"
  description = "Defines where your app should be deployed"
}

# RDS
variable "rds_instance_identifier" {
  description = "RDS instance name"
}

variable "rds_storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)."
  default     = "gp2"
}

variable "rds_allocated_storage" {
  description = "The allocated storage in GBs"
}

variable "rds_engine_type" {
  description = "Database engine type"
}

variable "rds_engine_version" {
  description = "Database engine version, depends on engine type"
}

variable "rds_instance_class" {
  description = "Class of RDS instance"
}

variable "database_name" {
  description = "The name of the database to create"
}

variable "database_user" {
  description = "Database user"
}

variable "database_password" {
  description = "Database password"
}

variable "database_port" {
  description = "Database port"
}

variable "vpc_cidr" {
  description = "VPC CIDR block that will be used"
}

variable "public_subnets" {
  description = "List of CIDR blocks to create public subnets"
  type        = "list"
}
