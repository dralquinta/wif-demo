# Sample Code that creates a vpc based on registry here: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network


resource "google_compute_network" "vpc_network" {
  project                 = "dryruns"
  name                    = "vpc-wif-github-test"
  auto_create_subnetworks = false
  mtu                     = 1460
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

provider "google" {
  project = "dryruns"
}