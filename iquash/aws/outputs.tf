output "instance_id" {
  value = aws_instance.coolify.id
}

output "public_ip" {
  value = aws_eip.coolify.public_ip
}

output "ssm_start_session" {
  value = "aws ssm start-session --target ${aws_instance.coolify.id} --region ${var.aws_region}"
}

output "coolify_local_tunnel" {
  value = "aws ssm start-session --target ${aws_instance.coolify.id} --region ${var.aws_region} --document-name AWS-StartPortForwardingSession --parameters '{\"portNumber\":[\"8000\"],\"localPortNumber\":[\"8000\"]}'"
}
