output "master_public_ip" {
  value       = aws_instance.master.public_ip
  description = "Public IP address of the Master Node"
}

output "worker_public_ips" {
  value       = aws_instance.workers[*].public_ip
  description = "Public IP addresses of the Worker Nodes"
}
