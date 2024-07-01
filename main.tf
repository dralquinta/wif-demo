# Sample Code that creates a vpc based on registry here: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network


resource "google_compute_network" "vpc_network" {
  name = "vpc-network"
}

terraform {
  backend "gcs" {
    bucket = "dralquinta-tf-states"
    prefix = "terraform/state"
  }

required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

resource "null_resource" "wait_30_seconds" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
    depends_on = [
    google_compute_network.vpc_network
  ]
}

provider "google" {
  project = "dryruns"
  region = "southamerica-west1"
}