variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "allowed_security_groups" { type = list(string) }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "instance_count" {
  type    = number
  default = 2
}
variable "instance_class" {
  type    = string
  default = "db.t3.medium"
}
variable "name_prefix" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
