# Step-by-Step Guide: Kubernetes Cluster with kops on AWS

kops stands for Kubernetes Operations and is ideal for creating, upgrading, and managing highly available clusters in AWS.

### 📌 Prerequisites

✅ Domian for Kubernetes Records e.g Lekan.xyx from Gadaddy

✅ Create a EC2 instance and setup

- Kobs, Kubectl, ssh keys, awscli

✅ Login into AWS Account and setup

- s3 bucket, IAM User for AWS-Cli, Route53 Hosted Zone


Step One

Create an EC2 instance

![Image](https://github.com/user-attachments/assets/1edc23df-ff14-47e4-8b0e-41b4feac39c1)

Step Two

Create an S3 bucket (make sure to create the bucket in the same region where you have launched the ec2 instance).
To create an S3 bucket for kops.

```bash
aws s3api create-bucket \
  --bucket kuberneteskops001 \
  --region us-east-1
```

Step Two

Create an IAM user (name the user as kopsadmin with administrator access and create an access key).

Step-by-Step: Create kopsadmin IAM User via AWS CLI

```bash
aws iam create-user --user-name kopsadmin
```

```bash
aws iam attach-user-policy \
  --user-name kopsadmin \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

```bash
aws iam create-access-key --user-name kopsadmin
```

This will return a JSON response like:

 ```bash
{
    "AccessKey": {
        "UserName": "kopsadmin",
        "AccessKeyId": "AKIAIOSFODNN7EXAMPLE",
        "Status": "Active",
        "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        "CreateDate": "2025-05-19T00:00:00Z"
    }
}
 ```

Step Four

Create hosted zone from the route 53.

If you have purchased the domain from Route53 then by default there will be a hosted zone has been created with NS record

![Image](https://github.com/user-attachments/assets/b45daf11-9d7e-4625-93cc-f278a4425970)

![Image](https://github.com/user-attachments/assets/1b512038-974e-45c4-9b89-72749233c71e)

If you have a domain in GoDaddy then create a hosted zone and update the NS record in the domain

![Image](https://github.com/user-attachments/assets/dd53b06f-b1a7-40f2-8c50-bba3a7378f8f)



Step 5

Connect the EC2 instance using SSH-Client and generate an SSH key

```bash
ssh-keygen
```

Use this command to install AWS CLI

```bash
sudo apt update
```
```bash
sudo apt install awscli -y
```

Use AWS configure command to log in to CLI and paste the access key and secret key we created for the Kops user. Also, enter the region where we have created the instance and s3 bucket.

```bash
aws configure
```
![Image](https://github.com/user-attachments/assets/1c000ad7-b674-4013-a744-1abf40bd38a7)


Next, we need to install Kubectl

Download kubectl manager

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

Install kubectl

```bash
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

Test to ensure the version you installed is up-to-date

```bash
kubectl version --client
```

Next, we need to install Kops

```bash
curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops
sudo mv kops /usr/local/bin/kops
```

Set Environment Variables

```bash
export KOPS_CLUSTER_NAME=lekanmi.xyz
export KOPS_STATE_STORE=s3://kuberneteskops001
```

Create the Kubernetes Cluster

```bash
kops create cluster \
  --name=${KOPS_CLUSTER_NAME} \
  --state=${KOPS_STATE_STORE} \
  --zones=us-east-1a,us-east-1b \
  --node-count=2 \
  --node-size=t3.small \
  --control-plane-size=t3.medium \
  --node-volume-size=12 \
  --control-plane-volume-size=12 \
  --dns-zone=${KOPS_CLUSTER_NAME} \
  --ssh-public-key ~/.ssh/id_rsa.pub
```

Build the Cluster Infrastructure

```bash
kops update cluster --name=${KOPS_CLUSTER_NAME} --state=${KOPS_STATE_STORE} --yes
```

Wait and Validate the Cluster

```bash
kops validate cluster --state=${KOPS_STATE_STORE}
```

Use the Cluster

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```


### ☁️ AWS Resources Created by kops Cluster

📦 1. EC2 Instances

    Control Plane (Master) Nodes

        Manages cluster state, scheduling, control loops, and etcd

        Example: t3.medium

    Worker Nodes

        Run your applications (pods/containers)

        Example: t3.small

🌐 2. Elastic Load Balancers (ELBs)

    Public ELB for Kubernetes API Server (api.<cluster-name>)

    Internal ELBs may be created if you use internal services (like internal ingress)

🛰️ 3. Route 53 Hosted Zone Records

    DNS entries for:

        api.<cluster-name> (for accessing K8s API)

        Internal service discovery (*.internal.<cluster-name>)

    Uses your public or private hosted zone

🗂️ 4. S3 Bucket (Your Kops State Store)

    Stores cluster configuration and state

    Must be created manually beforehand

    Example: s3://kuberneteskops001

🧱 5. IAM Resources

    IAM Roles & Instance Profiles for:

        Master nodes (e.g., masters.lekanmi.xyz)

        Node instances (e.g., nodes.lekanmi.xyz)

    Policies attached to grant necessary EC2, S3, Route 53, etc. permissions

🔐 6. Security Groups

    Created for:

        Master instances

        Node instances

        Load balancers

    Manages inbound/outbound traffic like SSH, API server access, kubelet traffic

📶 7. Auto Scaling Groups (ASGs)

    For control plane and worker nodes

    Supports dynamic scaling (if configured)

📊 8. CloudWatch Logs & Metrics (optional)

    If configured, can be used for:

        Logging cluster components

        Monitoring node health and metrics

📡 9. VPC and Networking

If not reusing an existing VPC, kops creates:

    A VPC with CIDR block

    Subnets (public/private depending on your setup)

    Internet Gateway

    Route Tables

    NAT Gateway (if private subnets are used)

    DHCP Options Set
    


Delete the Cluster (Cleanup)

```bash
kops delete cluster --name=${KOPS_CLUSTER_NAME} --state=${KOPS_STATE_STORE} --yes
```


Do not try to delete it manually by going to the AWS management console because there will be a lot of resources have been created while creating the cluster so it is really hard to delete manually.











