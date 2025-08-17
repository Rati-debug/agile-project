variable "region" { type = string  default = "ap-south-1" }
variable "cluster_name" { type = string  default = "college-erp" }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
