#######variables block##########

variable "ubuntu_version" {
  description = "Version of Ubuntu AMI"
  default     = "focal-20.04"
}

variable ssh_key {
  default     = "/home/timur/.ssh/id_rsa.pub"
  description = "Default pub key"
}

variable ssh_priv_key {
  default     = "/home/timur/.ssh/id_rsa"
  description = "Default private key"
}

variable "az" {
  description = "AZs in this region to use"
  default = ["eu-north-1a", "eu-north-1b"]
  type = list
}

variable "subnet_cidrs" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
  type = list
}

variable "private_subnet_cidrs" {
  description = "Subnet CIDRs for private subnets (length must match configured availability_zones)"
  default = ["10.0.3.0/24", "10.0.4.0/24"]
  type = list
}

variable username {
  description = "DB username"
  default = "admin"
}

variable password {
  description = "DB password"
  default  = "adminqwerty"
}

variable dbname {
  description = "db name"
  default = "timurdb"
}

