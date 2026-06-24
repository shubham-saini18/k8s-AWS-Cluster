# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch default subnets for the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Fetch latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Security Group for K8s Cluster Nodes
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-cluster-sg"
  description = "Security group for Kubernetes cluster"
  vpc_id      = data.aws_vpc.default.id

  # Allow all internal cross-talk between cluster nodes
  ingress {
    from_port self        = true
    to_port   = 0
    protocol  = "-1"
  }

  # Allow SSH access from anywhere (Narrow down CIDR in production environments)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow external access to Kubernetes API Server
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access to fetch packages, updates, images
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-security-group"
  }
}

# Master Node
resource "aws_instance" "master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_master
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = var.ssh_key_name

  tags = {
    Name = "k8s-master"
    Role = "master"
  }
}

# Worker Nodes
resource "aws_instance" "workers" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_worker
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = var.ssh_key_name

  tags = {
    Name = "k8s-worker-${count.index + 1}"
    Role = "worker"
  }
}
