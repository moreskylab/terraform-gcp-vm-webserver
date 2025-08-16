output "web_server_external_ip" {
  description = "External IP address of the web server"
  value       = google_compute_address.web_static_ip.address
}

output "web_server_internal_ip" {
  description = "Internal IP address of the web server"
  value       = google_compute_instance.web.network_interface[0].network_ip
}

output "logs_bucket_name" {
  description = "Name of the Cloud Storage bucket for logs"
  value       = google_storage_bucket.logs.name
}

output "logs_bucket_url" {
  description = "URL of the Cloud Storage bucket"
  value       = google_storage_bucket.logs.url
}

output "ssh_connection_command" {
  description = "SSH command to connect to the web server"
  value       = "gcloud compute ssh ${google_compute_instance.web.name} --zone=${var.zone} --project=${var.project_id}"
}

output "web_server_url" {
  description = "URL of the web server"
  value       = "http://${google_compute_address.web_static_ip.address}"
}

output "service_account_email" {
  description = "Email of the service account"
  value       = google_service_account.vm_service_account.email
}