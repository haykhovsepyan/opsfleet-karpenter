# GPU Slicing on Amazon EKS

## Overview

GPU slicing allows multiple workloads to share a single GPU, enabling cost-effective resource utilization for GPU-intensive AI workloads. This guide explains how to enable GPU slicing on EKS clusters and integrate it with the Karpenter autoscaler.


## Prerequisites

- **EKS Cluster**: An EKS cluster with nodes equipped with NVIDIA GPUs.
- **NVIDIA Software**: NVIDIA drivers and CUDA toolkit installed on GPU nodes.
- **Kubernetes Version**: 1.18 or higher.
- **Karpenter**: Installed if you intend to use it for GPU node autoscaling.

---

## Step 1: Deploy NVIDIA Device Plugin

The NVIDIA device plugin for Kubernetes exposes GPU resources to the Kubernetes scheduler.

```bash
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/main/nvidia-device-plugin.yml
```

## Step2: Configure GPU Time-Slicing

Create a ConfigMap to enable GPU time-slicing by defining the desired number of GPU replicas.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: time-slicing-config
data:
  any: |-
    version: v1
    flags:
      migStrategy: none
    sharing:
      timeSlicing:
        renameByDefault: false
        resources:
          - name: nvidia.com/gpu
            replicas: 4
```

## Step3: Integrate with Karpenter

Ensure your Karpenter NodePool is configured to recognize GPU resources. To provision GPU-enabled nodes in your EKS cluster, create a `NodePool` resource with the following configuration:

```yaml
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: gpu-nodepool
spec:
  constraints:
    labels:
      karpenter.sh/capacity-type: spot
    taints:
      - key: nvidia.com/gpu
        effect: NoSchedule
    requirements:
      - key: node.kubernetes.io/instance-type
        operator: In
        values: ["g4dn.xlarge", "g4dn.2xlarge"]
  limits:
    resources:
      cpu: 1000
  nodeClassRef:
        apiVersion: karpenter.k8s.aws/v1beta1
        kind: EC2NodeClass
        name: opsfleetnodeclass # Replace with your EC2NodeClass name
```

Ensure that you have `EC2NodeClass` with following key configurations:

1. **GPU-Compatible AMI**: Use an AMI optimized for GPU workloads, such as:
   - NVIDIA-optimized AMIs from the AWS Marketplace.
   - AMIs that include pre-installed NVIDIA drivers and CUDA toolkit.

2. **Instance Profile**: Specify an instance profile with the required permissions to manage EC2 instances.

3. **Subnet and Security Group Selectors**: Define the subnet and security group selectors to ensure nodes are provisioned in the correct network environment.


## Step4: Deploy workloads to request GPU slices instead of full GPUs. Here an example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-workload
spec:
  tolerations:
    - key: "nvidia.com/gpu"
      operator: "Equal"
      effect: "NoSchedule"
  containers:
    - name: ai-container
      image: your-ai-workload-image
      resources:
        limits:
          nvidia.com/gpu: 1
```
