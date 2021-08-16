terraform {
 required_providers {
   google = {
     source = "hashicorp/google"
	} 
 }
 backend "gcs" {
    credentials = "/home/muhammadmal/group7-322208-75e354f7f7a2.json"
    bucket = "devops_telkomsel_7"
    prefix = "terraform/mariefm"
  }
}

provider "google" {
 credentials = file("/home/muhammadmal/group7-322208-75e354f7f7a2.json")
 project = "group7-322208"
 region = var.region
 zone = var.zone
}