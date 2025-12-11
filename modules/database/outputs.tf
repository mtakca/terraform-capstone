output "cluster_endpoint" {
  value = aws_db_instance.primary.address
}
output "reader_endpoint" {
  value = aws_db_instance.replica[0].address
}
output "security_group_id" {
  value = aws_security_group.db.id
}
output "secret_arn" {
  value = aws_secretsmanager_secret.db_pass.arn
}
