terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ECR repository for container images
resource "aws_ecr_repository" "erp" {
  name = "college-erp"
  image_scanning_configuration { scan_on_push = true }
}

# Minimal EKS cluster via module (community module to simplify)
# NOTE: For a production cluster, configure VPC, node groups, IAM, and security groups properly.
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.24.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

  eks_managed_node_groups = {
    default = {
      min_size     = 2
      max_size     = 4
      desired_size = 2
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }
}

output "cluster_name" { value = module.eks.cluster_name }
output "cluster_endpoint" { value = module.eks.cluster_endpoint }
output "oidc_provider_arn" { value = module.eks.oidc_provider_arn }
output "ecr_repo_url" { value = aws_ecr_repository.erp.repository_url }
