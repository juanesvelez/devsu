terraform {
  backend "gcs" {
    bucket  = "terraform"
    prefix  = "terraform/state"
  }
}