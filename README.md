# Terraform IaC for Setting Up a GCP Virtual Machine

## Overview
This repository contains Terraform Infrastructure as Code (IaC) to automate the provisioning of a virtual machine (VM) instance on Google Cloud Platform (GCP). The setup includes creating a VM instance, configuring SSH access, and defining a firewall rule to allow SSH connections.

## Prerequisites
Ensure you have the following installed and configured before using this Terraform script:
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- An active Google Cloud account
- A service account with necessary permissions (Compute Admin, Storage Admin, and Service Account User)
- SSH key pair generated for authentication

## Setup and Configuration

### 1. Clone the Repository
```sh
 git clone <repository_url>
 cd <repository_directory>
```

### 2. Update Terraform Variables
Modify the `terraform.tfvars` file or set the required variables before applying the configuration:

#### Example `terraform.tfvars`:
```hcl
project_id    = "your-gcp-project-id"
region        = "us-central1"
zone          = "us-central1-a"
instance_name = "terraform-gcp-vm"
ssh_user      = "your-ssh-username"
ssh_public_key = "your-ssh-public-key"
```

Ensure that the service account key JSON file is available in the project directory.

### 3. Initialize Terraform
Run the following command to initialize the Terraform project and install necessary providers:
```sh
terraform init
```

### 4. Plan and Apply Configuration

#### Preview the Changes:
```sh
terraform plan
```

#### Apply the Configuration:
```sh
terraform apply -auto-approve
```

### 5. Retrieve VM Details
Once the configuration is applied, Terraform will output relevant details:
```sh
terraform output
```
This will display the public IP and SSH metadata.

### 6. Connect to the VM via SSH
Use the outputted public IP to connect:
```sh
ssh -i /path/to/private_key your-ssh-username@<public-ip>
```

## Cleanup
To destroy the resources and clean up:
```sh
terraform destroy -auto-approve
```

## Terraform Code Breakdown
### Google Cloud Provider Configuration
```hcl
provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file("./your-service-account-key.json")
}
```
### VM Instance Creation
```hcl
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
    access_config {}
  }
  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
  metadata_startup_script = "echo '${var.ssh_user}:${var.ssh_public_key}' > /tmp/debug_ssh.txt"
  tags = ["allow-ssh"]
}
```
### Firewall Rule for SSH Access
```hcl
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
```
### Output Variables
```hcl
output "public_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}
```

## License
This project is licensed under the MIT License.

## Contributing
Feel free to submit issues or pull requests for improvements.

## Author
[Jennifer Cheng]

