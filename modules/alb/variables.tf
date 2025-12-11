variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "health_check_path" {
  type    = string
  default = "/"
}
variable "name_prefix" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
