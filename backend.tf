terraform {
  backend "s3" {
    bucket  = "terraform-opsfleet-task"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true

  }
}


terraform {
  required_version = ">= 1.9.3"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.14.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}
