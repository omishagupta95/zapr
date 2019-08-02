// Networking module


//Create VPC

resource "google_compute_network" "zapr-vpc" {
  name    = "${var.network_vpc_name}"
  auto_create_subnetworks = false
}

//Create Public & Private Subnets

resource "google_compute_subnetwork" "public-subnet" {
  name          = "${var.network_vpc_name}-public-${var.network_region}"
  ip_cidr_range = "10.180.216.0/21"
  network       = "${google_compute_network.zapr-vpc.self_link}"
  region        = "${var.network_region}"
  private_ip_google_access = "true"
}

resource "google_compute_subnetwork" "private-subnet" {
  name          = "${var.network_vpc_name}-private-${var.network_region}"
  ip_cidr_range = "10.180.0.0/18"
  network       = "${google_compute_network.zapr-vpc.self_link}"
  region        = "${var.network_region}"
  private_ip_google_access = "true"
}


// Create Firewall rules for VPC

resource "google_compute_firewall" "icmp" {
  name    = "zapr-firewall-icmp"
  network = "${google_compute_network.zapr-vpc.name}"

  allow {
    protocol = "icmp"
  }

   source_ranges = ["0.0.0.0/0"]
}


resource "google_compute_firewall" "ssh" {
  name    = "zapr-firewall-ssh"
  network = "${google_compute_network.zapr-vpc.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["allow-ssh"]
}


resource "google_compute_firewall" "mongo" {
  name    = "zapr-firewall-mongo"
  network = "${google_compute_network.zapr-vpc.name}"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

}
provisioner "local-exec" {
    command = "bash ./path-to-file"
  }


/*
resource "google_compute_firewall" "http" {
  name    = "zapr-firewall-http"
  network = "${google_compute_network.zapr-vpc.name}"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

   source_ranges = ["0.0.0.0/0"]
   source_tags = ["http-server"]
}

resource "google_compute_firewall" "https" {
  name    = "zapr-firewall-https"
  network = "${google_compute_network.zapr-vpc.name}"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

   source_ranges = ["0.0.0.0/0"]

   source_tags = ["https-server"]
}
*/
