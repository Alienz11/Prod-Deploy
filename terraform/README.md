# Terraform EKS Infrastructure

This repository provisions a complete AWS EKS infrastructure using Terraform. It includes:

- S3 remote backend for Terraform state
- VPC and networking (subnets, IGW, route tables)
- EKS Cluster with managed node groups
- Security groups and IAM roles

## 🚀 Getting Started

### Create Terraform Backend (S3 + DynamoDB)

#### Prerequisites Before terraform init (Manual Steps):

- **Download And Install The Neccessary Tools**:

  You need certain commandline tools installed on your local machine before starting anything. They include
  - **`AWS CLI`**
  - **`Terraform`** >= version 1.0.0
  - **`IAM credentials with admin-level AWS access`** (For Access Key ID and Access Secret Key, for AWS CLI auth)
  - **`Kubectl`** (Optional for Terraform Deployment, but needed to update kubeconfig to the EKS Cluster after it has been provisioned, so that you can communicate to the cluster from your system.)

- **Manually Create S3 Bucket for Terraform State**:

  You cannot define the S3 backend bucket within the same Terraform configuration that will use it for state storage. You must manually create this S3 bucket first (e.g., via AWS Console or AWS CLI).
  - **Bucket Name**: Must be globally unique (e.g., my-project-prod-terraform-state-12345).
  - **Versioning**: Enable bucket versioning for state recovery.
  - **Encryption**: Enable default encryption (SSE-S3).

- **Manually Create DynamoDB Table for State Locking (Highly Recommended)**:

  To prevent concurrent Terraform runs from corrupting your state, create a DynamoDB table for state locking.
  - Table Name: (e.g., terraform-state-locking).
  - Primary Key: A single primary partition key named LockID of type String.
  - Provisioned Capacity: Set to a low value (e.g., 1 Read/Write capacity unit each) as it's for locking, not high throughput.

After creating the above resources copy the [versios.tf](versions.tf) into a new terraform directory/folder. And run:

```bash
terraform init
```

This would create the `terraform.tfstate` file in the s3 bucket and configure state-locking in the dynamoDB

### Create Deployment Files

- Copy the remaining files from the [terraform](./) to the new terraform directory.
- Check if the terraform files are properly fommated:

    ```bash
    terraform fmt
    ```

- See what is to be deployed by running the following:

    ```bash
    terraform plan
    ```

- Deploy the infrastructure:

    ```bash
    terraform apply
    ```

- After the deployment, a command would be displayed, this is to run and configure the EKS CLuster on your local kubeconfig, to have direct access to the EKS from your local machine. It should look like this:

    ```txt
    aws eks update-kubeconfig --name item-server-cluster --region us-east-1
    ```

## RECOMMENDATIONS

- You can use terraform modules to get default template for each Cloud Provider resource (i.e seperate modules for VPC, EKS, EC2 e.t.c).
- You can use GitOps for deployment, when a PR to the main branch runs `terraform plan` for the Lead Engineer to review updates on the terraform files, and a push (i.e a PR merge) to the main branch, would run `terraform apply`.

Cheers.
