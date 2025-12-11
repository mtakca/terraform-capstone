variable "vpc_cidr" {
  type = string
}

variable "public_subnets_cidr" {
  type = list(string)
}

variable "private_app_subnets_cidr" {
  type = list(string)
}

variable "private_data_subnets_cidr" {
  type = list(string)
}

variable "name_prefix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
