provider "google" {
  project = "i-enterprise-264400"
  region  = "us-west1"
  zone    = "us-west1-a"
}

resource "google_compute_subnetwork" "int-us-west1-a" {
  name = "int-us-west1-a"
  ip_cidr_range = "10.5.0.0/24"
  region = "us-west1"
  network = google_compute_network.demo.self_link
}

resource "google_compute_subnetwork" "int-us-west1-b" {
  name = "int-us-west1-b"
  ip_cidr_range = "10.5.1.0/24"
  region = "us-west1"
  network = google_compute_network.demo.self_link
}

resource "google_compute_subnetwork" "ext-us-west1-a" {
  name = "ext-us-west1-a"
  ip_cidr_range = "10.5.2.0/24"
  region = "us-west1"
  network = google_compute_network.demo.self_link
}

resource "google_compute_subnetwork" "ext-us-west1-b" {
  name = "ext-us-west1-b"
  ip_cidr_range = "10.5.3.0/24"
  region = "us-west1"
  network = google_compute_network.demo.self_link
}

resource "google_compute_network" "demo" {
  name                    = "demo"
  auto_create_subnetworks = "false"
}
