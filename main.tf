# Configure the Google Cloud Provider
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = var.credentials
}

# Generate a random suffix for global uniqueness
resource "random_id" "suffix" {
  byte_length = 4
}

# Create a VPC network (equivalent to AWS VPC)
resource "google_compute_network" "main" {
  name                    = "tf-main-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460

  depends_on = [google_project_service.compute_api]
}

# Create a subnet (equivalent to AWS subnet)
resource "google_compute_subnetwork" "public" {
  name          = "tf-public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.main.id

  # Enable private Google access for instances without external IPs
  private_ip_google_access = true
}

# Create firewall rule for HTTP traffic (equivalent to AWS Security Group)
resource "google_compute_firewall" "allow_http" {
  name    = "tf-allow-http"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]

  description = "Allow HTTP traffic"
}

# Create firewall rule for SSH traffic
resource "google_compute_firewall" "allow_ssh" {
  name    = "tf-allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # In production, restrict this to your IP
  target_tags   = ["web-server"]

  description = "Allow SSH traffic"
}

# Reserve a static external IP address (equivalent to AWS Elastic IP)
resource "google_compute_address" "web_static_ip" {
  name   = "tf-web-server-ip"
  region = var.region

  depends_on = [google_project_service.compute_api]
}

# Create a Cloud Storage bucket for logs (equivalent to AWS S3)
resource "google_storage_bucket" "logs" {
  name     = "tf-web-server-logs-${random_id.suffix.hex}"
  location = var.region

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = false
  }

  # Enable uniform bucket-level access
  uniform_bucket_level_access = true

  # Versioning configuration
  versioning {
    enabled = true
  }

  # Lifecycle rule to delete old logs
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  depends_on = [google_project_service.storage_api]
}

# Create a service account for the VM (equivalent to AWS IAM Role)
resource "google_service_account" "vm_service_account" {
  account_id   = "tf-vm-service-account"
  display_name = "VM Service Account"
  description  = "Service account for web server VM"
}

# Grant the service account storage admin access to the bucket
resource "google_storage_bucket_iam_member" "bucket_admin" {
  bucket = google_storage_bucket.logs.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.vm_service_account.email}"
}

# Grant the service account logging write access
resource "google_project_iam_member" "logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}

# Enable required APIs
resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"

  disable_dependent_services = true
}

resource "google_project_service" "storage_api" {
  service = "storage-component.googleapis.com"

  disable_dependent_services = true
}

# Create the Compute Engine instance (equivalent to AWS EC2)
resource "google_compute_instance" "web" {
  name         = "tf-web-server"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["web-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.main.name
    subnetwork = google_compute_subnetwork.public.name

    access_config {
      nat_ip = google_compute_address.web_static_ip.address
    }
  }

  # SSH key configuration
  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key_path)}"
  }

  # Service account configuration
  service_account {
    email  = google_service_account.vm_service_account.email
    scopes = ["cloud-platform"]
  }

  # Startup script (equivalent to AWS user_data)
  metadata_startup_script = templatefile("${path.module}/startup-script.sh", {
    bucket_name = google_storage_bucket.logs.name
    project_id  = var.project_id
  })

  labels = {
    name = "tf-web-server"
  }

  depends_on = [
    google_compute_subnetwork.public,
    google_storage_bucket.logs,
    google_service_account.vm_service_account
  ]
}