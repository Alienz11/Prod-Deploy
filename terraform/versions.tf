# versions.tf
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Pin to a major version
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23" # Pin to a major version
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11" # Pin to a major version
    }
  }

  backend "s3" {
    bucket         = "your-terraform-state-bucket-name" # Must be globally unique and created manually first
    key            = "eks-cluster/terraform.tfstate"
    region         = "us-east-1"               # Match your desired AWS region (This is generally the cheapest region, but proximity to target customers matters)
    dynamodb_table = "terraform-state-locking" # Optional, but highly recommended for state locking
    encrypt        = true
  }
}
