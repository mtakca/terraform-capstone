variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "target_group_arn" { type = string }
variable "alb_security_group_id" { type = string }
variable "user_data" { type = string }
variable "secret_arn" { type = string }
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "key_name" { type = string }
variable "asg_min_size" {
  type    = number
  default = 2
}
variable "asg_max_size" {
  type    = number
  default = 4
}
variable "asg_desired_capacity" {
  type    = number
  default = 2
}
variable "name_prefix" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
