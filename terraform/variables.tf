variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "location" {
  description = "The zone in which to deploy the cluster"
  type        = string
  default     = "us-central1-a"
}