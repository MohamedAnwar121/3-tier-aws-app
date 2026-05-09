# 3-Tier AWS Application

Minimal 3-tier app on AWS — Terraform infrastructure + Ansible configuration.

```
Internet
   │
   ▼
[Public ALB]          ← public subnets (AZ-a, AZ-b)
   │
   ▼
[Frontend ASG]        ← private subnets (nginx, 2–4 instances)
   │ /api/*
   ▼
[Internal ALB]        ← private subnets (AZ-a, AZ-b)
   │
   ▼
[Backend ASG]         ← private subnets (Python/Flask, 2–4 instances)
   │
   ▼
[RDS PostgreSQL]      ← db subnets (Multi-AZ, primary + standby)
```

All secrets (DB password) are sourced from **HashiCorp Vault** — never in state files.

---

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | >= 1.5 |
| Ansible | >= 2.14 |
| AWS CLI | configured with appropriate IAM permissions |
| Vault | running and accessible |
| Python collection | `pip install boto3 botocore` |
| Ansible collection | `ansible-galaxy collection install amazon.aws community.general` |

---

## Vault Setup (one-time)

```bash
# Store DB password in Vault
vault kv put secret/prod/database \
  password="YourStrongPassword" \
  host="<rds-endpoint>"        \
  port="5432"                  \
  dbname="appdb"               \
  username="dbadmin"

# Enable AWS IAM auth in Vault
vault auth enable aws
vault write auth/aws/role/myapp-prod-ec2 \
  auth_type=iam \
  bound_iam_instance_profile_arn="arn:aws:iam::<ACCOUNT_ID>:instance-profile/myapp-prod-ec2-profile" \
  policies=app-policy \
  ttl=1h

# Create a policy granting read on the secret
vault policy write app-policy - <<EOF
path "secret/data/prod/database" {
  capabilities = ["read"]
}
EOF
```

---

## Deploy Infrastructure (Terraform)

```bash
cd terraform/

cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — set your AMI, key name, vault address

export VAULT_ADDR="https://vault.example.com:8200"
export VAULT_TOKEN="<your-vault-token>"

terraform init
terraform plan
terraform apply

# Capture the internal ALB DNS for Ansible
export INTERNAL_ALB_DNS=$(terraform output -raw internal_alb_dns)
```

---

## Docker Build & Push

Before running Ansible, you must build and push the Docker images so that the EC2 instances can pull them.

```bash
# Build and push the Backend
cd app/backend
docker build -t mohamedanwar121/backend:latest .
docker push mohamedanwar121/backend:latest
cd ../..

# Build and push the Frontend
cd app/frontend
docker build -t mohamedanwar121/frontend:latest .
docker push mohamedanwar121/frontend:latest
cd ../..
```

---

## Configure Servers (Ansible)

```bash
cd ../ansible/

# Verify dynamic inventory picks up instances
ansible-inventory --list --graph

# Run everything at once
INTERNAL_ALB_DNS=$INTERNAL_ALB_DNS \
  ansible-playbook playbooks/site.yml

# Or run tiers separately
ansible-playbook playbooks/frontend.yml
ansible-playbook playbooks/backend.yml
```

---

## Project Structure

```
3tier-aws/
├── terraform/
│   ├── main.tf                   # Root — wires all modules together
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── modules/
│       ├── vpc/                  # VPC, subnets, NAT GWs, route tables
│       ├── security_groups/      # Least-privilege SGs per tier
│       ├── alb/                  # Public + internal ALBs, target groups
│       ├── asg/                  # Launch templates + ASGs (frontend & backend)
│       └── rds/                  # Multi-AZ RDS PostgreSQL
└── ansible/
    ├── ansible.cfg
    ├── inventory/
    │   └── aws_ec2.yml           # Dynamic EC2 inventory (filters by tags)
    ├── playbooks/
    │   ├── site.yml              # Run all tiers
    │   ├── frontend.yml
    │   └── backend.yml
    └── roles/
        ├── common/               # Base OS packages
        ├── vault_agent/          # Installs Vault agent, writes credentials to file
        ├── frontend/             # Nginx + static app, proxies /api to backend
        └── backend/              # Gunicorn/Flask app, reads DB creds from Vault
```

---

## Key Design Decisions

- **Vault over SSM Parameter Store** — secrets never touch Terraform state or env vars
- **Vault Agent** runs as a systemd service on each EC2; writes rendered credentials to `/etc/app/db.env` — the app reads env vars, not Vault directly
- **IAM auth** — EC2 instance profile authenticates to Vault without any static token
- **One NAT per AZ** — avoids cross-AZ traffic charges and single-AZ failure
- **ELB health checks** on ASGs — unhealthy instances are replaced automatically
- **Tags drive inventory** — Ansible uses `tag:Role` (frontend / backend) to target the right hosts
