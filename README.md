# terraform-gcp-vm-webserver
webserver creation on GCP using terraform

# GCP Web Server Infrastructure

This Terraform configuration creates a web server infrastructure in Google Cloud Platform, equivalent to the AWS EC2 webserver setup.

## Architecture

- **VPC Network**: Network isolation (equivalent to AWS VPC)
- **Subnet**: Public subnet for the web server
- **Firewall Rules**: Traffic control (equivalent to AWS Security Groups)
- **Compute Instance**: Ubuntu web server with Apache (equivalent to AWS EC2)
- **Static External IP**: Reserved IP address (equivalent to AWS Elastic IP)
- **Cloud Storage Bucket**: Log storage (equivalent to AWS S3)
- **Service Account**: VM permissions (equivalent to AWS IAM Role)

## Prerequisites

1. Google Cloud SDK installed and authenticated: `gcloud auth login`
2. GCP Project created with billing enabled
3. Terraform installed
4. SSH key pair generated: `ssh-keygen -t rsa -b 4096`

## Setup

1. Enable required APIs in your GCP project:
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable storage-component.googleapis.com
   ```

2. Set your default project:
   ```bash
   gcloud config set project YOUR_PROJECT_ID
   ```

## Deployment

1. Clone this repository
2. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
3. Edit `terraform.tfvars` with your project details
4. Initialize Terraform:
   ```bash
   terraform init
   ```
5. Plan the deployment:
   ```bash
   terraform plan
   ```
6. Apply the configuration:
   ```bash
   terraform apply
   ```

## Accessing the Web Server

After deployment:
- **Web Server**: `http://<external_ip>`
- **SSH**: Use gcloud command from outputs or SSH with your key

## Service Equivalents

| AWS Service | GCP Equivalent |
|-------------|----------------|
| VPC | VPC Network |
| EC2 | Compute Engine |
| Security Group | Firewall Rules |
| Elastic IP | Static External IP |
| S3 Bucket | Cloud Storage |
| IAM Role | Service Account |
| Amazon Linux | Ubuntu |

## Cost Considerations

- e2-micro instance: ~$5.50/month (always free tier eligible)
- Static IP: ~$1.46/month
- Cloud Storage: ~$0.02/GB/month
- **Total estimated cost**: ~$7/month (or free with always free tier)

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

## Security Notes

- SSH access is open to 0.0.0.0/0 - restrict to your IP in production
- Service account has minimal required permissions
- Cloud Storage bucket has uniform access control enabled