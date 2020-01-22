resource "google_compute_instance" "kube-controller-0-ext-us-west1-a" {
  name           = "kube-controller-0-ext-us-west1-a"
  machine_type   = "n1-standard-1"
  zone           = "us-west1-a"
  can_ip_forward = true
  allow_stopping_for_update = true

  tags = ["kubernetes", "controller"]

  boot_disk {
    initialize_params {
      image = "kube-controller"
      size = "30"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.ext-us-west1-a.self_link
    network_ip = "10.5.2.10"
    access_config {
      // Ephemeral IP
    }
  }
}

resource "google_compute_instance" "kube-controller-1-ext-us-west1-b" {
  name           = "kube-controller-1-ext-us-west1-b"
  machine_type   = "n1-standard-1"
  zone           = "us-west1-b"
  can_ip_forward = true
  allow_stopping_for_update = true

  tags = ["kubernetes", "controller"]

  boot_disk {
    initialize_params {
      image = "kube-controller"
      size = "30"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.ext-us-west1-b.self_link
    network_ip = "10.5.3.10"
    access_config {
      // Ephemeral IP
    }
  }
}

resource "google_compute_instance" "kube-node-0-ext-us-west1-a" {
  name           = "kube-node-0-ext-us-west1-a"
  machine_type   = "n1-standard-1"
  zone           = "us-west1-a"
  can_ip_forward = true
  allow_stopping_for_update = true

  tags = ["kubernetes", "controller"]

  boot_disk {
    initialize_params {
      image = "kube-node"
      size = "20"
    }
  }

  metadata = {
    pod-cidr = "10.6.0.0/24"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.ext-us-west1-a.self_link
    network_ip = "10.5.2.11"
    access_config {
      // Ephemeral IP
    }
  }
}

resource "google_compute_instance" "kube-node-1-ext-us-west1-b" {
  name           = "kube-node-1-ext-us-west1-b"
  machine_type   = "n1-standard-1"
  zone           = "us-west1-b"
  can_ip_forward = true
  allow_stopping_for_update = true

  tags = ["kubernetes", "controller"]

  boot_disk {
    initialize_params {
      image = "kube-node"
      size = "20"
    }
  }

  metadata = {
    pod-cidr = "10.6.1.0/24"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.ext-us-west1-b.self_link
    network_ip = "10.5.3.11"
    access_config {
      // Ephemeral IP
    }
  }
}