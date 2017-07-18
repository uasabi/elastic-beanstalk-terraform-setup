profile = "default"
application_name = "huginn"
application_description = "Create agents that monitor and act on your behalf. Your agents are standing by!"
application_environment = "test"
region = "eu-west-1"

rds_instance_identifier = "huginn"
rds_allocated_storage = 5
rds_engine_type = "mysql" # All valid engine types: http://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html
rds_engine_version = "5.7.17" # All valid engine versions: http://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html
rds_instance_class = "db.t2.micro" # All valid instance values: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html

database_name = "huginn"
database_user = "admin123"
database_password = "admin123"
database_port = 3306

vpc_cidr = "10.30.0.0/16"
public_subnets = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
