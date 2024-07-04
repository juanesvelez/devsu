provider "google" {
  project = var.project_id
  region  = "us-central1"
}

resource "google_container_cluster" "primary" {
  name     = "gke-test"
  location = var.location

  initial_node_count = 3

  node_config {
    machine_type = "e2-medium"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-pool"
  location   = var.location
  cluster    = google_container_cluster.primary.name
  node_count = 3

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

output "kubeconfig" {
  value = google_container_cluster.primary.endpoint
}