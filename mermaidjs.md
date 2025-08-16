---
config:
  layout: elk
---
flowchart TB
  subgraph IAM["🔐 Identity & Access Management"]
    SA["🆔 Service Account<br>sa-vm-webserver-{env}"]
    IAMRole["📋 IAM Role<br>Storage Object Creator"]
  end
  
  subgraph PublicSubnet["🌍 Public Subnet<br>subnet-public-{env}<br>CIDR: 10.0.1.0/24"]
    VM["🖥️ Compute Instance<br>vm-webserver-{env}<br>Ubuntu 22.04 LTS<br>e2-micro<br>Standard Persistent Disk"]
  end
  
  subgraph Network["🌐 VPC Network: vpc-main-{env}<br>CIDR: 10.0.0.0/16"]
    PublicSubnet
    FW["🛡️ Firewall Rules<br>fw-allow-web-ssh<br>Rules: HTTP(80), SSH(22)"]
    StaticIP["🌐 Static External IP<br>ip-webserver-{env}"]
  end
  
  subgraph Storage["💾 Storage Layer"]
    Bucket["🗂️ Cloud Storage Bucket<br>gs-logs-web-{random}<br>Standard Storage<br>Uniform Access"]
  end
  
  subgraph Project["🏢 GCP Project: project-webserver-{env}"]
    IAM
    Network
    Storage
  end
  
  subgraph GCP["☁️ Google Cloud Platform - us-central1"]
    Project
  end
  
  subgraph AppLayer["📱 Application Layer"]
    Apache["🌐 Apache Web Server<br>Port 80"]
    WebContent["📄 Static Web Content<br>/var/www/html/"]
    LogRotation["📋 Log Management<br>Daily Cron Job"]
    GcloudCLI["⚙️ gcloud CLI<br>Service Account Auth"]
  end
  
  subgraph IaC["🏗️ Infrastructure as Code"]
    Terraform["📋 Terraform Configuration<br>- Provider: Google 4.0+<br>- Random Provider<br>- Template Functions"]
    Metadata["⚙️ Startup Script<br>metadata.sh"]
  end
  
  Internet(["Internet/Users"]) -. HTTPS/HTTP Traffic .-> StaticIP
  Developer(["Developer/Admin"]) -. SSH Access<br>Port 22 .-> StaticIP
  StaticIP --> VM
  FW -. Security Rules .-> VM
  VM --> Apache
  Apache --> WebContent
  VM -. Uses .-> SA
  SA -. Has Role .-> IAMRole
  IAMRole -. Access To .-> Bucket
  VM -- Daily Log Upload<br>via Service Account --> Bucket
  LogRotation -. Automated Process .-> GcloudCLI
  GcloudCLI -. Auth via .-> SA
  Terraform -. Provisions .-> Project
  Metadata -. Configures .-> VM
  
  SA:::security
  IAMRole:::security
  VM:::compute
  FW:::security
  StaticIP:::network
  Bucket:::storage
  Apache:::compute
  WebContent:::compute
  LogRotation:::app
  GcloudCLI:::app
  Terraform:::iac
  Metadata:::iac
  Project:::gcp
  
  classDef gcp fill:#4285F4,stroke:#3367D6,stroke-width:2px,color:#fff
  classDef compute fill:#EA4335,stroke:#B31412,stroke-width:2px,color:#fff
  classDef network fill:#34A853,stroke:#227333,stroke-width:2px,color:#fff
  classDef storage fill:#FBBC05,stroke:#F09300,stroke-width:2px,color:#fff
  classDef security fill:#5F6368,stroke:#3C4043,stroke-width:2px,color:#fff
  classDef app fill:#8430CE,stroke:#6B24D3,stroke-width:2px,color:#fff
  classDef iac fill:#1A73E8,stroke:#185ABC,stroke-width:2px,color:#fff