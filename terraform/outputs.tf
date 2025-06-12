output "ec2_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/clo835-key ec2-user@${aws_instance.web_server.public_ip}"
}

output "webapp_ecr_url" {
  value = aws_ecr_repository.webapp.repository_url
}

output "mysql_ecr_url" {
  value = aws_ecr_repository.mysql.repository_url
}
