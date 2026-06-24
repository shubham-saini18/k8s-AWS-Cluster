# AWS Multi-Node Kubernetes Cluster (Terraform + Ansible)

A reproducible, infrastructure-as-code (IaC) pipeline to provision and configure a production-ready multi-node Kubernetes cluster on AWS using Terraform (infrastructure) and Ansible (configuration).

This repository boots a small cluster (1 control-plane, 2 workers) using containerd and Weave Net as the CNI plugin.

---

## Highlights

- Infrastructure: Terraform for VPCs, subnets, EC2 instances, security groups, and outputs.
- Configuration: Ansible to install containerd, Kubernetes components, initialize the control-plane, install Weave Net, and join workers.
- Reproducible: Minimal manual steps — everything is automated and idempotent.

---

## Table of contents

- Overview
- Project structure
- Prerequisites
- Quickstart
- Ansible inventory example
- Verify the cluster
- Tear down
- Contributing
- License

---

## Overview

Manually bootstrapping Kubernetes is error-prone and time-consuming. This project automates those steps so you can:

- Provision EC2 infrastructure with Terraform
- Configure OS-level settings and Kubernetes components with Ansible
- Initialize a control-plane and join worker nodes

Use this repo as a learning environment, CI/CD sandbox, or a migration validation cluster.

---

## Project structure

```
k8s-aws-cluster/
├── terraform/                  # Terraform configuration (VPC, subnets, EC2, security groups, outputs)
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── outputs.tf
└── ansible/                    # Ansible playbooks and inventory
    ├── inventory.ini           # Populate with Terraform outputs
    └── playbook.yml            # Installs containerd, kubeadm, kubelet, kubectl, configures and joins nodes
```

---

## Prerequisites

- Terraform >= 1.5.0
- Ansible (2.9+ recommended)
- AWS CLI configured (~/.aws/credentials) with permissions to create EC2, VPC, Subnets, Security Groups, IAM as needed
- An existing AWS EC2 Key Pair (PEM file) available locally
- Git and a local terminal

---

## Quickstart

1) Clone the repository and change to terraform directory:

```bash
git clone https://github.com/shubham-saini18/k8s-AWS-Cluster.git
cd k8s-AWS-Cluster/terraform
```

2) Initialize Terraform:

```bash
terraform init
```

3) Preview the plan (replace ssh_key_name with your key pair name):

```bash
terraform plan -var="ssh_key_name=your-aws-ssh-key"
```

4) Apply to provision resources:

```bash
terraform apply -var="ssh_key_name=your-aws-ssh-key"
```

When complete, note the outputted public IP(s) for the master and worker nodes. Terraform prints these values as outputs.

5) Populate the Ansible inventory

```bash
cd ../ansible
# Edit inventory.ini and place the Terraform outputs (public IPs) here
```

Example inventory (replace IPs and key path):

```ini
[master]
master ansible_host=54.210.XX.XX ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-aws-key.pem

[workers]
worker1 ansible_host=3.85.XX.XX ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-aws-key.pem
worker2 ansible_host=54.89.XX.XX ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-aws-key.pem

[k8s_cluster:children]
master
workers
```

6) Test connectivity with Ansible ping module:

```bash
ansible k8s_cluster -m ping -i inventory.ini
```

7) Run the playbook to configure the cluster:

```bash
ansible-playbook -i inventory.ini playbook.yml
```

This will:
- Install and configure containerd
- Install kubeadm, kubelet, kubectl
- Initialize the control-plane on the master
- Install Weave Net CNI
- Join workers to the cluster

---

## Verify the cluster

SSH into the master node and verify nodes:

```bash
ssh -i ~/.ssh/your-aws-key.pem ubuntu@<MASTER_PUBLIC_IP>
# on master
kubectl get nodes -o wide
kubectl get pods -n kube-system
```

A healthy cluster should show Ready nodes and running kube-system pods (coredns, kube-proxy, weave-net, etc.).

---

## Tear down

To destroy the infrastructure and avoid AWS costs:

```bash
cd ../terraform
terraform destroy -var="ssh_key_name=your-aws-ssh-key"
```

---

## Notes & Recommendations

- This repo is intended for learning, testing, and CI/CD sandboxing. For production clusters consider managed services (EKS) or hardened, production-grade automation.
- Use Terraform workspaces or separate AWS accounts for isolation across environments.
- Lock Terraform provider versions in provider.tf to avoid accidental upgrades.

---


