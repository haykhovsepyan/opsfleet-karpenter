module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.28.0"

  cluster_name                    = local.name
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_version                 = "1.31"
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }



  enable_cluster_creator_admin_permissions = true


  create_iam_role             = true
  create_cloudwatch_log_group = false
  vpc_id                      = module.vpc.vpc_id
  subnet_ids                  = module.vpc.private_subnets

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "node outbound"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "all inbound"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "All outbound"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_group_defaults = {
    ami_type                              = "AL2_x86_64"
    instance_types                        = ["t2.micro", "m5.large", "m5n.large", "m5zn.large"]
    attach_cluster_primary_security_group = true
    vpc_security_group_ids                = []
  }
  cluster_enabled_log_types = []

}

module "node_group_amd64" {
  source                            = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version                           = "20.28.0"
  name                              = "eks-amd64"
  cluster_name                      = module.eks.cluster_name
  cluster_version                   = module.eks.cluster_version
  subnet_ids                        = module.vpc.private_subnets
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids = [
    module.eks.cluster_security_group_id,

  ]
  min_size             = local.node_group["node_min_size"]
  max_size             = local.node_group["node_max_size"]
  desired_size         = local.node_group["node_desired_size"]
  cluster_service_cidr = local.node_group["service_cidr"]

  instance_types = ["t2.small", "t2.large"]
  capacity_type  = "SPOT"

}

module "node_group_arm64" {
  source                            = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version                           = "20.28.0"
  name                              = "eks-arm64"
  cluster_name                      = module.eks.cluster_name
  cluster_version                   = module.eks.cluster_version
  subnet_ids                        = module.vpc.private_subnets
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids = [
    module.eks.cluster_security_group_id,

  ]
  min_size     = local.node_group["node_min_size"]
  max_size     = local.node_group["node_max_size"]
  desired_size = local.node_group["node_desired_size"]

  instance_types       = ["t4g.small", "t4g.large"]
  ami_type             = "AL2_ARM_64"
  capacity_type        = "SPOT"
  cluster_service_cidr = local.node_group["service_cidr"]
}

  
