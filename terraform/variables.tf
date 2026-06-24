variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region to deploy the Kubernetes cluster"
}

variable "instance_type_master" {
  type        = string
  default     = "t2.medium" # K8s control plane requires a minimum of 2 vCPUs
}

variable "instance_type_worker" {
  type        = string
  default     = "t2.micro"
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the existing AWS SSH key pair to inject into instances"
}
