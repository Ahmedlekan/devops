# Minikube Kubernetes Setup (Step-by-Step Guide)

### 🔧 Step 1: Install System Requirements

✅ Prerequisites

    OS: Windows 10/11, macOS, or Linux

    Virtualization enabled (BIOS/UEFI setting)

    Hypervisor: Docker, VirtualBox

Required Tools

Minikube 
```bash
choco install minikube
```
Kubectl
```bash
choco install kubernetes-cli
```	

🔧 Step 2: Start Minikube

```bash
minikube start --driver=docker
```
This:

Starts a single-node Kubernetes cluster locally

Uses Docker as the VM driver (you can use virtualbox, hyperv, etc.)

🧪 Step 3: Verify Installation

```bash
kubectl version --client
kubectl get nodes
```

You should see the minikube node in a Ready state.


📋 Step 4: Enable Useful Minikube Addons (Optional but Recommended)

```bash
minikube addons enable dashboard
minikube addons enable ingress
minikube addons enable metrics-server
```

dashboard – Web UI to manage Kubernetes

ingress – Ingress controller for routing

metrics-server – For HPA and resource metrics


🌐 Step 5: Access Kubernetes Dashboard

```bash
minikube dashboard
```

This will open a browser to view the live Kubernetes dashboard.


🧪 Step 6: Deploy a Sample App

```bash
kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0
kubectl expose deployment hello-minikube --type=NodePort --port=8080
```

Get the app URL:

```bash
minikube service hello-minikube --url
```


🧹 Step 7: Clean Up

```bash
kubectl delete service hello-minikube
kubectl delete deployment hello-minikube
```


🛑 Step 8: Stop or Delete Cluster

```bash
minikube stop          # Stops cluster
minikube delete        # Deletes all cluster data
```




