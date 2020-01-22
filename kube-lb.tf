resource "google_compute_address" "ext-us-west1-ip-0" {
  name   = "ext-us-west1-ip-0"
  region = google_compute_subnetwork.ext-us-west1-a.region
}

resource "google_compute_http_health_check" "kube-controller-healthcheck" {
  name         = "kube-controller-healthcheck"
  request_path = "/healthz"
  host         = "kubernetes.default.svc.cluster.local"
  timeout_sec        = 5
  check_interval_sec = 5
  unhealthy_threshold = 5
}

resource "google_compute_target_pool" "kube-controller" {
  name = "kube-controller"

  instances = [
    "us-west1-a/kube-controller-0-ext-us-west1-a",
    "us-west1-b/kube-controller-1-ext-us-west1-b",
  ]

  health_checks = [
    google_compute_http_health_check.kube-controller-healthcheck.name
  ]
}

resource "google_compute_forwarding_rule" "kube-controller-lb" {
  name = "kube-controller-lb"
  target = google_compute_target_pool.kube-controller.self_link
  ip_address = google_compute_address.ext-us-west1-ip-0.address
  port_range = "6443"
}
