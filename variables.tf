variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-south1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "asia-south1-a"
}

variable "machine_type" {
  description = "GCP machine type (equivalent to AWS t2.micro)"
  type        = string
  default     = "e2-micro"
}

variable "ssh_username" {
  description = "SSH username for the VM"
  type        = string
  default     = "gcp-user"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "credentials" {
  description = "Path to GCP service account credential json file"
  type        = string
  default     = "projectID-36456-4646d3545ecd.json"
}