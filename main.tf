# Configure AWS Credentials & Region
provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}

# Beanstalk Application
resource "aws_elastic_beanstalk_application" "application" {
  name        = "${var.application_name}"
  description = "${var.application_description}"
}

# Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "beanstalk_application_environment" {
  name                = "${var.application_name}-${var.application_environment}"
  application         = "${aws_elastic_beanstalk_application.application.name}"
  solution_stack_name = "64bit Amazon Linux 2017.03 v2.7.1 running Multi-container Docker 17.03.1-ce (Generic)"
  tier                = "WebServer"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t2.micro"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "EnvironmentType"
    value = "SingleInstance"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.beanstalk_ec2.name}"
  }


  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${module.vpc.vpc_id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${join(",", module.public_subnet.subnet_ids)}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_NAME"
    value     = "${aws_db_instance.db.name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_HOST"
    value     = "${aws_db_instance.db.address}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_USERNAME"
    value     = "${aws_db_instance.db.username}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_PASSWORD"
    value     = "${aws_db_instance.db.password}"
  }
}

# Beanstalk instance profile
resource "aws_iam_instance_profile" "beanstalk_ec2" {
  name  = "${var.application_name}-beanstalk-ec2-user"
  role = "${aws_iam_role.beanstalk_ec2.name}"
}

resource "aws_iam_role" "beanstalk_ec2" {
  name = "${var.application_name}-beanstalk-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eb-web-tier-attach" {
  role = "${aws_iam_role.beanstalk_ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "eb-ecs-attach" {
  role = "${aws_iam_role.beanstalk_ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

# RDS
resource "aws_db_instance" "db" {
  allocated_storage = "${var.rds_allocated_storage}"
  engine            = "${var.rds_engine_type}"
  engine_version    = "${var.rds_engine_version}"
  identifier        = "${var.rds_instance_identifier}"
  instance_class    = "${var.rds_instance_class}"

  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.db.name}"

  name     = "${var.database_name}"
  username = "${var.database_user}"
  password = "${var.database_password}"
  port     = "${var.database_port}"
  skip_final_snapshot = true

  storage_type        = "${var.rds_storage_type}"

  tags = {
    Name = "${var.rds_instance_identifier}"
  }
}

resource "aws_db_subnet_group" "db" {
  name        = "${var.rds_instance_identifier}"
  description = "RDS subnet group"
  subnet_ids  = ["${module.public_subnet.subnet_ids}"]

  tags = {
    Name = "${var.rds_instance_identifier}"
  }
}

# Security groups
resource "aws_security_group" "db" {
  name        = "${var.rds_instance_identifier}"
  description = "RDS database access"
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Name = "${var.rds_instance_identifier}"
  }
}

resource "aws_security_group_rule" "allow_internal_db_access" {
  security_group_id = "${aws_security_group.db.id}"

  type = "ingress"

  from_port   = "${var.database_port}"
  to_port     = "${var.database_port}"
  protocol    = "tcp"
  cidr_blocks = ["${module.vpc.vpc_cidr}"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  security_group_id = "${aws_security_group.db.id}"

  type = "egress"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

# VPC networking
data "aws_availability_zones" "az" {}

######
# VPC
######

module "vpc" {
  source = "github.com/terraform-community-modules/tf_aws_vpc_only?ref=v1.0.1"

  name                 = "${var.application_name}"
  cidr                 = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

###################
# Internet gateway
###################

module "igw" {
  source = "github.com/terraform-community-modules/tf_aws_igw?ref=v1.0.0"

  name   = "${var.application_name}"
  vpc_id = "${module.vpc.vpc_id}"
}

#################
# Public subnets
#################

module "public_subnet" {
  source = "github.com/terraform-community-modules/tf_aws_public_subnet?ref=v1.0.0"

  name  = "${var.application_name}-public"
  cidrs = "${var.public_subnets}"
  azs   = "${data.aws_availability_zones.az.names}"

  vpc_id = "${module.vpc.vpc_id}"

  igw_id = "${module.igw.igw_id}"
}
