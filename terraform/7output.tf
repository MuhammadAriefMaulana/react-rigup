output "kube_cluster" {
    description = "Kubernetes Cluster Name"  
    value       = google_container_cluster.devops7-cluster.name
}

output "kube_zone" {
    description = "Kubernetes Cluster Name"  
    value       = google_container_cluster.devops7-cluster.location
}

output "project_id" {
    description = "Kubernetes Cluster Name"  
    value       = google_container_cluster.devops7-cluster.project
}
