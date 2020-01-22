resource "google_compute_firewall" "kube-int-us-west1" {
  name    = "kube-int-us-west1"
  network = google_compute_network.demo.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = ["10.5.0.0/24", "10.5.1.0/24", "10.5.2.0/24", "10.5.3.0/24"]

}

resource "google_compute_firewall" "kube-ext-us-west1" {
  name    = "kube-ext-us-west1"
  network = google_compute_network.demo.name

  allow {
    protocol = "tcp"
    ports = ["22", "6443", "80", "31356"]
  }

  source_ranges = ["0.0.0.0/0"]

}
