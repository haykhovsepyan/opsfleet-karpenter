module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = local.name
  cidr                 = local.vpc["cidr"]
  azs                  = ["${local.region}a", "${local.region}b"]
  private_subnets      = local.vpc["private_subnets"]
  public_subnets       = local.vpc["public_subnets"]
  enable_nat_gateway   = true
  enable_dns_hostnames = true
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }
}
