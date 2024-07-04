output "cluster_name" {
  description = "The name of the Kubernetes cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "The endpoint of the Kubernetes cluster"
  value       = google_container_cluster.primary.endpoint
}

output "client_certificate" {
  description = "The client certificate used to authenticate to the cluster"
  value       = google_container_cluster.primary.master_auth.0.client_certificate
}

output "client_key" {
  description = "The client key used to authenticate to the cluster"
  value       = google_container_cluster.primary.master_auth.0.client_key
}

output "cluster_ca_certificate" {
  description = "The cluster CA certificate"
  value       = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
}