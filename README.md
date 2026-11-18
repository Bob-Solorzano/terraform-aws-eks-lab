# AWS EKS Kubernetes Deployment Lab

## Overview

A hands-on AWS and Kubernetes project focused on deploying and operating a containerized application on Amazon EKS, integrating Kubernetes Ingress with AWS Application Load Balancing.

The project uses Terraform to provision AWS infrastructure, Helm to deploy Kubernetes components, and Kubernetes manifests to configure application routing.

The goal is to build practical experience with AWS infrastructure, Kubernetes application deployment, networking, and cross-layer troubleshooting.

## Architecture

**Request flow:**

Browser → AWS Application Load Balancer → Kubernetes Ingress → Kubernetes Service → Nginx Pods

**Infrastructure and platform components:**

- Amazon VPC with public and private subnets across two Availability Zones
- Amazon EKS cluster and managed worker nodes
- NAT Gateway for private subnet outbound connectivity
- EKS OIDC identity provider and IAM Roles for Service Accounts (IRSA)
- AWS Load Balancer Controller
- Helm-managed Nginx deployment with two replicas
- Kubernetes ClusterIP Service and ALB Ingress

## Technologies

- **AWS:** EKS, EC2, VPC, IAM, Elastic Load Balancing, NAT Gateway
- **Infrastructure as Code:** Terraform
- **Containers and orchestration:** Kubernetes, kubectl
- **Package management:** Helm
- **Automation and scripting:** PowerShell, AWS CLI
- **Networking:** Kubernetes Services, EndpointSlices, Ingress, ALB target groups

## Implementation Highlights

- Provisioned the EKS environment and supporting AWS networking infrastructure using Terraform.
- Configured IAM OIDC federation and IRSA for AWS Load Balancer Controller permissions.
- Installed and configured the AWS Load Balancer Controller using Helm.
- Created a Helm chart to deploy a two-replica Nginx application and ClusterIP Service.
- Defined a Kubernetes Ingress resource to expose the application through an internet-facing AWS Application Load Balancer.
- Verified the end-to-end HTTP request path from a browser through the ALB to the Kubernetes application.
- Inspected Kubernetes Deployments, Pods, Services, and EndpointSlices to understand workload and network relationships.

## Validation

Successfully verified:

- EKS worker nodes reach the Kubernetes Ready state.
- Nginx Deployment maintains two available replicas.
- Kubernetes Service endpoints resolve to the running Pods.
- AWS Load Balancer Controller provisions an ALB from the Kubernetes Ingress resource.
- HTTP requests through the ALB reach the Nginx application.

---

# Environment Setup and Teardown

This section documents how to recreate the development environment from a clean state and safely remove its AWS resources when finished.

## Prerequisites

Install and configure:

- AWS CLI with credentials for the target AWS account
- Terraform
- kubectl
- Helm
- Git

## Environment Configuration

| Setting | Value |
|---|---|
| AWS Region | `us-west-2` |
| EKS Cluster | `dev-eks` |
| Kubernetes Namespace for controller | `kube-system` |
| Nginx Helm release | `nginx-helm` |
| ALB Controller Helm release | `aws-load-balancer-controller` |
| ALB Controller chart version | `3.6.3` |

## Create the Environment

### 1. Provision AWS Infrastructure

From the project root:

```powershell
cd environments/dev
Copy-Item dev.tfvars.example dev.tfvars
# Edit dev.tfvars: replace YOUR_PUBLIC_IP with your public IP address.

terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

Terraform provisions the VPC, networking, EKS cluster, worker nodes, OIDC provider, and IAM resources required by the AWS Load Balancer Controller.

### 2. Configure kubectl Access

```powershell
aws eks update-kubeconfig --region us-west-2 --name dev-eks
kubectl get nodes
```

Verify that the worker nodes report `Ready`.

### 3. Create the AWS Load Balancer Controller ServiceAccount

```powershell
kubectl create serviceaccount aws-load-balancer-controller -n kube-system
```

Annotate the ServiceAccount with the IAM role ARN returned by Terraform:

```powershell
$albRoleArn = terraform output -raw alb_controller_role_arn
kubectl annotate serviceaccount aws-load-balancer-controller -n kube-system eks.amazonaws.com/role-arn=$albRoleArn
```


### 4. Install AWS Load Balancer Controller

Add and update the AWS EKS Helm repository:

```powershell
helm repo add eks https://aws.github.io/eks-charts
helm repo update
```

Install the controller:

```powershell
$vpcId = terraform output -raw vpc_id

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller --namespace kube-system --version 3.6.3 --set clusterName=dev-eks --set region=us-west-2 --set vpcId=$vpcId --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set defaultTargetType=ip
```

Verify the controller deployment:

```powershell
kubectl get deployment aws-load-balancer-controller -n kube-system
```

Expected result: two available replicas.

### 5. Deploy Nginx Application

Return to the project root:

```powershell
cd ..\..
```

Install the Nginx Helm chart:

```powershell
helm upgrade --install nginx-helm .\helm\nginx
```

Verify the Deployment, Service, and Pods:

```powershell
kubectl get deploy,svc,pods
```

Expected result: two available Nginx replicas.

### 6. Create the ALB Ingress

```powershell
kubectl apply -f .\environments\dev\nginx-ingress.yaml
```

The AWS Load Balancer Controller detects the Ingress and provisions an internet-facing Application Load Balancer.

Verify the Ingress:

```powershell
kubectl get ingress
```

Wait for the ALB DNS name to appear in the `ADDRESS` column.

Test application connectivity:

```powershell
# Replace <ALB-DNS-NAME> with the DNS name displayed in the Ingress ADDRESS column.
curl.exe http://<ALB-DNS-NAME>
```

The current Ingress configuration exposes HTTP on port 80. HTTPS/TLS is not yet configured.

### 7. Verify the Environment

Useful commands:

```powershell
kubectl get nodes
kubectl get pods -A
kubectl get deploy,svc
kubectl get ingress
kubectl get endpointslices
helm list -A
```

Confirm:

- EKS worker nodes are Ready.
- AWS Load Balancer Controller replicas are Running.
- Both Nginx replicas are Running.
- The Nginx Service has healthy endpoints.
- The Ingress has an ALB DNS address.
- HTTP requests through the ALB reach Nginx.

---

## Destroy the Environment

AWS resources continue to incur charges while running. EKS, NAT Gateway, and Application Load Balancers have ongoing costs.

**Important:** Delete the Ingress first and allow the controller to remove the ALB before destroying the EKS infrastructure.

### 1. Delete the Ingress

From the project root:

```powershell
kubectl delete -f .\environments\dev\nginx-ingress.yaml
```

Wait for the associated ALB to be deleted. Verify in the AWS EC2 Load Balancers console.

### 2. Uninstall Nginx

```powershell
helm uninstall nginx-helm
```

### 3. Uninstall AWS Load Balancer Controller

```powershell
helm uninstall aws-load-balancer-controller -n kube-system
```

### 4. Destroy AWS Infrastructure

Return to the Terraform environment directory:

```powershell
cd environments/dev
terraform destroy -var-file="dev.tfvars"
```

Review the proposed changes and confirm destruction.

### 5. Verify Cleanup

Check the AWS console to confirm that the EKS cluster, NAT Gateway, and associated load balancer resources have been removed.

The local kubeconfig entry may remain after cluster destruction. It can be removed separately or left in place.

**Note:** Terraform state and separately provisioned bootstrap resources supporting the Terraform backend may not be part of this environment's destruction. Do not destroy shared backend infrastructure as part of this procedure.

---

## Future Enhancements

- Extend Python/Boto3 diagnostic tooling with Kubernetes API integration.
- Trace relationships between AWS load balancer target groups, Kubernetes Ingress, Services, EndpointSlices, Pods, Nodes, and EC2 instances.
- Explore Kubernetes monitoring and resource health reporting.
- Expand troubleshooting capabilities across AWS and Kubernetes infrastructure.

## Cost Considerations

This is a development and learning environment. Destroy the environment when it is not in use to avoid ongoing AWS charges.