# EKS Cluster with Karpenter Provisioning

This Terraform configuration sets up an Amazon EKS cluster with support for both AMD64 and ARM64 (Graviton) instance types. The cluster uses Karpenter for provisioning nodes dynamically based on workload requirements

---

## Prerequisites

Before running this Terraform configuration, ensure the following:

1. **AWS CLI**:
   - Install the AWS CLI: [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
   - Configure the AWS CLI with appropriate credentials:
     ```bash
     aws configure
     ```
   - Alternatively, use AWS SSO for authentication if your organization uses SSO: (Recommended)
     ```bash
     aws configure sso
     ```

2. **Terraform**:
   - Install Terraform version `>= 1.9.3`.
   - [Terraform Installation Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

3. **AWS Permissions**:
   - Your AWS user or role must have `AdministratorAccess` or equivalent permissions to manage EKS, IAM, and S3 resources.

4. **S3 Backend for Terraform State**:
   - This project uses an S3 bucket to store the Terraform state. Ensure you have an existing S3 bucket and Replace `bucket-name` and other placeholders in `backend.tf` with your S3 bucket name and region.

5. **AWS Region**:
   - The default region used in this configuration is **`us-east-1`**. Replace this with your desired region if you are using a different AWS region.

6. **AWS ACCOUNT ID**:
   - Define your AWS_ACCOUNT_ID in local.tf


## Usage

To provision the provided configurations you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

```bash
# Get Kubeconfig
aws eks --region $REGION update-kubeconfig --name opsfleet-task
```

---

### Example Deployment on x86 AMD64 Nodes
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: amd64-pod
  labels:
    app: amd64-app
spec:
  nodeSelector:
    kubernetes.io/arch: amd64
  containers:
    - name: amd64-container
      image: nginx:latest
      ports:
        - containerPort: 80
```
This configuration schedules the pod on nodes labeled with kubernetes.io/arch: amd64 (x86 architecture).

### Example Deployment on Graviton Nodes
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: amd64-pod
  labels:
    app: amd64-app
spec:
  nodeSelector:
    kubernetes.io/arch: amd64
  containers:
    - name: amd64-container
      image: nginx:latest
      ports:
        - containerPort: 80
```
This configuration schedules the pod on nodes labeled with kubernetes.io/arch: arm64 (ARM64 architecture)

## File Structure

```plaintext
.
├── README.md                 # This file
├── backend.tf                # Backend configuration for S3 state
├── eks.tf                    # EKS cluster configuration
├── gpu-slicing.md            # Documentation for GPU slicing with Karpenter
├── karpenter-values.yaml     # Values file for Karpenter Helm chart
├── karpenter.tf              # Karpenter configuration
├── locals.tf                 # Local variables for Terraform
├── provider.tf               # AWS and Kubernetes provider configuration
└── vpc.tf                    # VPC configuration
