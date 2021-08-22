variable "name" {
  default = "mariefm-3" //kalau mau test2 rubah disini default=devops-telkomsel-7
}

variable "subnet" {
  type = string
  default = "10.8.0.0/16"
}

variable "region" {
  type = string
  default = "us-west2"
}

variable "zone" {
  type = string
  default = "us-west2-a"
}

variable "image" {
  type = string
  default = "ubuntu-2004-focal-v20210720"
}

variable "machine_type" {
  type = string
  default = "e2-medium"
}

variable "service_account" {
  type = string
  default = "devops-telkomsel-7@group7-322208.iam.gserviceaccount.com"
}

variable "cluster_secondary_range_name" {
  type = string
  default = "pod"
}

variable "services_secondary_range_name" {
  type = string
  default = "service"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "/home/muhammadmal/mariefm1.pem"
}

variable "PATH_TO_Public_KEY" {
  default = "/home/muhammadmal/mariefm1.pub"
}