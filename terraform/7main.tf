resource "google_compute_network" "devops7-vpc" {
    name = "${var.name}-vpc"
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "devops7-subnet" {
    name = "${var.name}-subnet"
    ip_cidr_range = var.subnet
    region = var.region
    network = google_compute_network.devops7-vpc.self_link
}

resource "google_compute_firewall" "devops7-fw" {
  name    = "${var.name}-fw"
  network = google_compute_network.devops7-vpc.self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8080", "2000", "3000", "3306"]
  }
}

resource "google_compute_instance" "devops7-instance-1" {
  name         = "${var.name}-instance-1"
  machine_type = var.machine_type

  tags = ["vm-mariefm"]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  metadata_startup_script = <<EOT
    #!/bin/bash
    //sudo apt install nginx -y
    //sudo systemctl start nginx
    
    //install k8s
    sudo apt-get update
    sudo apt-get install -y apt transport https curl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
    sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    kubectl completion bash >> .bashrc
    source .bashrc

    //install gcloud
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    sudo apt-get install apt-transport-https ca-certificates gnupg
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt-get update && sudo apt-get install google-cloud-sdk
    sudo apt-get install google-cloud-sdk-app-engine-python
    sudo apt-get install google-cloud-sdk-app-engine-python-extras
    sudo apt-get install kubectl
    
EOT

  network_interface {
    network = google_compute_network.devops7-vpc.self_link
    subnetwork = google_compute_subnetwork.devops7-subnet.self_link    
    access_config {
       network_tier = "STANDARD"
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.PATH_TO_Public_KEY)}"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file(var.PATH_TO_PRIVATE_KEY)
    host = coalesce(self.network_interface[0].access_config[0].nat_ip)
  }
}

# resource "google_compute_instance" "devops7-instance-2" {
#   name         = "${var.name}-instance-2"
#   machine_type = var.machine_type

#   tags = ["nginx-instance"]

#   boot_disk {
#     initialize_params {
#       image = var.image
#     }
#   }

#   metadata_startup_script = <<EOT
#     #!/bin/bash
#     //sudo apt install nginx -y
#     //sudo systemctl start nginx
    
#     //install k8s
#     sudo apt-get update
#     sudo apt-get install -y apt transport https curl
#     curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
#     sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
#     sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl
#     sudo apt-mark hold kubelet kubeadm kubectl
#     kubectl completion bash >> .bashrc
#     source .bashrc

#     //install gcloud
#     echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
#     sudo apt-get install apt-transport-https ca-certificates gnupg
#     curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
#     sudo apt-get update && sudo apt-get install google-cloud-sdk
#     sudo apt-get install google-cloud-sdk-app-engine-python
#     sudo apt-get install google-cloud-sdk-app-engine-python-extras
#     sudo apt-get install kubectl
    
# EOT

#   network_interface {
#     network = google_compute_network.devops7-vpc.self_link
#     subnetwork = google_compute_subnetwork.devops7-subnet.self_link    
#     access_config {
#       network_tier = "STANDARD"
#     }
#   }
# }

resource "google_container_cluster" "devops7-cluster" {
  name               = var.name
  location           = var.zone
  initial_node_count = 2
  network = google_compute_network.devops7-vpc.self_link
  subnetwork = google_compute_subnetwork.devops7-subnet.self_link 

  //activate IP aliases
  ip_allocation_policy {
    //cluster_secondary_range_name  = var.cluster_secondary_range_name
    //services_secondary_range_name = var.services_secondary_range_name
  }

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block = "172.16.0.0/28"
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.subnet
      display_name = "devops7-authorized-network"
    }
  }
  node_config {
    service_account = var.service_account
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  //  labels = {
  //    foo = "bar"
  //  }
  //  tags = ["foo", "bar"]
  }
  timeouts {
    create = "30m"
    update = "40m"
  }
}