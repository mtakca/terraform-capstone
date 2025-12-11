variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "allowed_security_groups" { type = list(string) }
variable "name_prefix" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
