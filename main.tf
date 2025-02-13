# Configure the Google Cloud provider
provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file("./sixth-hawk-448521-c1-f8703e460105.json")
}

# Create a VM instance
resource "google_compute_instance" "vm_instance" {
  name         = var.instance_name
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2410-oracular-amd64-v20250123"
      size  = 50
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  tags = ["allow-ssh"]
}

# Create a firewall rule to allow SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}

# Output the public IP
output "public_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
} 