locals {
  name           = "opsfleet-task"
  region         = "us-east-1"
  aws_account_id = "AWS_ACCOUNT_ID"
  vpc = {
    cidr            = "10.0.0.0/16"
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets  = ["10.0.4.0/24", "10.0.5.0/24"]
  }
  node_group = {
    node_min_size     = 1
    node_max_size     = 3
    node_desired_size = 2
    service_cidr      = "10.100.0.0/16"
  }

}
