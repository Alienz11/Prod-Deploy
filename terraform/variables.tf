variable "aws_region" {
  description = "The AWS region where resources will be deployed."
  type        = string
  default     = "us-east-1" # Change to your desired region
}

variable "project_name" {
  description = "A unique name for your project, used as a prefix for resources."
  type        = string
  default     = "item-server-eks"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"] # Example: adjust for more AZs/subnets
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "item-server-cluster"
}

variable "eks_node_instance_type" {
  description = "The EC2 instance type for EKS worker nodes."
  type        = string
  default     = "t3.medium" # Choose an appropriate instance type
}

variable "eks_node_desired_size" {
  description = "Desired number of worker nodes in the EKS cluster."
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum number of worker nodes in the EKS cluster."
  type        = number
  default     = 3
}

variable "eks_node_min_size" {
  description = "Minimum number of worker nodes in the EKS cluster."
  type        = number
  default     = 1
}

variable "eks_kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.29" # Ensure this version is supported by EKS in your region
}
