resource "google_compute_route" "kube-node-0-ext-us-west1-a-route" {
  name        = "kube-node-0-ext-us-west1-a-route"
  dest_range  = google_compute_instance.kube-node-0-ext-us-west1-a.metadata.pod-cidr
  network     = google_compute_network.demo.name
  next_hop_ip = google_compute_instance.kube-node-0-ext-us-west1-a.network_interface[0].network_ip
  priority    = 100
}

resource "google_compute_route" "kube-node-1-ext-us-west1-b-route" {
  name        = "kube-node-1-ext-us-west1-b-route"
  dest_range  = google_compute_instance.kube-node-1-ext-us-west1-b.metadata.pod-cidr
  network     = google_compute_network.demo.name
  next_hop_ip = google_compute_instance.kube-node-1-ext-us-west1-b.network_interface[0].network_ip
  priority    = 100
}

