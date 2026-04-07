# Project Progress Log

## Project: Production-Ready Vue.js Frontend CI/CD on AWS

---

## Step 1: Prerequisites & Initial Setup

### Status: COMPLETED

### 1.1 — Verify Installed Tools

```bash
# Check Terraform
terraform --version
# Result: Not installed

# Check AWS CLI
aws --version
# Result: aws-cli/2.33.22 Python/3.13.11 Darwin/25.3.0 exe/arm64

# Check Node.js
node --version
# Result: v22.22.0

# Check npm
npm --version
# Result: 10.9.4
```

### 1.2 — Install Terraform (was missing)

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

- Installed version: **1.14.8**

### 1.3 — Verify AWS Identity & Region

```bash
# Check which AWS account/user is configured
aws sts get-caller-identity
# Result:
# {
#     "UserId": "AIDAZPHZVKB6W64GX3PYE",
#     "Account": "651211133053",
#     "Arn": "arn:aws:iam::651211133053:user/binu"
# }

# Check default region
aws configure get region
# Result: eu-west-2
```

### 1.4 — Create S3 Bucket for Terraform Remote State

```bash
aws s3api create-bucket \
  --bucket binu-uk-terraform-state \
  --region eu-west-2 \
  --create-bucket-configuration LocationConstraint=eu-west-2
```

- Bucket ARN: `arn:aws:s3:::binu-uk-terraform-state`

### 1.5 — Enable Versioning on State Bucket

```bash
aws s3api put-bucket-versioning \
  --bucket binu-uk-terraform-state \
  --versioning-configuration Status=Enabled
```

### 1.6 — Enable Server-Side Encryption (AES-256)

```bash
aws s3api put-bucket-encryption \
  --bucket binu-uk-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}, "BucketKeyEnabled": true}]
  }'
```

### 1.7 — Block All Public Access on State Bucket

```bash
aws s3api put-public-access-block \
  --bucket binu-uk-terraform-state \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

### 1.8 — Create DynamoDB Table for State Locking

```bash
aws dynamodb create-table \
  --table-name terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region eu-west-2
```

- Table ARN: `arn:aws:dynamodb:eu-west-2:651211133053:table/terraform-lock`

### 1.9 — Create Terraform Backend Configuration File

Created file: `terraform/backend.tf`

```hcl
terraform {
  backend "s3" {
    bucket         = "binu-uk-terraform-state"
    key            = "frontend-cicd/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
```

---

## Step 2: Create Vue.js Frontend App

### Status: COMPLETED

### 2.1 — Scaffold Vue 3 + Vite App

```bash
npm create vue@latest frontend -- --default
```

- Scaffolded Vue 3 project with Vite in `frontend/` directory
- Package: `create-vue@3.22.2`

### 2.2 — Install Dependencies

```bash
cd frontend
npm install
```

- Installed 117 packages, 0 vulnerabilities

### 2.3 — Verify Production Build

```bash
npm run build
```

- Build output:
  - `dist/index.html` — 0.42 kB
  - `dist/assets/index-DIjQh30N.css` — 3.56 kB
  - `dist/assets/index-DlCoYbAs.js` — 69.98 kB
- Built in 274ms

---

## Step 3: Create buildspec.yml

### Status: COMPLETED

### 3.1 — Create Build Specification File

Created file: `buildspec.yml` (at project root)

**Key features:**
- **Install phase**: Node.js 18 runtime, `npm ci` for deterministic installs
- **Build phase**: `npm run build` for production build
- **Post-build phase**:
  - `aws s3 sync` with `--delete` to deploy built files
  - Static assets cached for 1 year (`max-age=31536000, immutable`)
  - `index.html` served with `no-cache` (ensures users always get latest version)
  - CloudFront cache invalidation after deploy
- **Cache**: `node_modules/` cached in S3 to speed up subsequent builds
- **Environment variables** (injected by CodeBuild):
  - `S3_BUCKET_NAME` — target S3 hosting bucket
  - `CLOUDFRONT_DISTRIBUTION_ID` — for cache invalidation

---

## Steps 4-5, 7: Terraform Modules (S3, ACM, CloudFront)

### Status: COMPLETED

### Approach: Module-based architecture

Used a modular Terraform structure with separate modules for each concern.

### Commands Used

```bash
# Create module directories
mkdir -p terraform/modules/{s3-hosting,acm,cloudfront}

# Initialize Terraform (backend + modules + providers)
cd terraform
terraform init

# Validate configuration
terraform validate
# Result: Success! The configuration is valid.
```

### Module Structure

```
terraform/
├── backend.tf               # S3 remote state (already existed)
├── providers.tf              # AWS providers (eu-west-2 + us-east-1)
├── variables.tf              # Root input variables
├── outputs.tf                # Root outputs (bucket name, CF ID, DNS records)
├── main.tf                   # Module composition + S3 bucket policy
├── terraform.tfvars          # Variable values
├── modules/
│   ├── s3-hosting/           # S3 bucket with versioning, encryption, public block
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── acm/                  # SSL cert in us-east-1 with DNS validation
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── cloudfront/           # CDN with OAC, TLS 1.2, security headers, SPA routing
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
```

### Best Practices Applied

- **Modular design**: Each resource group is a reusable module
- **Provider aliasing**: ACM in us-east-1 (CloudFront requirement), everything else in eu-west-2
- **OAC over OAI**: Modern Origin Access Control for S3 access
- **Security headers**: AWS managed SecurityHeadersPolicy on CloudFront
- **TLS 1.2_2021**: Minimum protocol version enforced
- **HTTP/2 + HTTP/3**: Enabled for performance
- **SPA routing**: Custom error responses for 403/404 → index.html
- **S3 hardening**: Versioning, encryption, public access blocked, lifecycle rules
- **Default tags**: All resources tagged via provider default_tags
- **Variable validation**: Environment restricted to valid values
- **Least privilege**: S3 bucket policy scoped to CloudFront distribution ARN

---

## Step 6: Route 53 Hosted Zone & DNS Setup

### Status: COMPLETED

### 6.1 — Create Route 53 Hosted Zone (via CLI)

```bash
aws route53 create-hosted-zone \
  --name binu.uk \
  --caller-reference "binu-uk-$(date +%s)" \
  --hosted-zone-config Comment="Production hosted zone for binu.uk"
```

- Hosted Zone ID: `Z03233472I7CYFANJLA2X`

### 6.2 — Update Nameservers in GoDaddy (manual)

Set these nameservers in GoDaddy → DNS → Nameservers:
- `ns-144.awsdns-18.com`
- `ns-1164.awsdns-17.org`
- `ns-520.awsdns-01.net`
- `ns-1781.awsdns-30.co.uk`

### 6.3 — Validate DNS Propagation

```bash
# Verify hosted zone
aws route53 get-hosted-zone --id Z03233472I7CYFANJLA2X

# Verify nameservers are pointing to AWS
dig binu.uk NS +short
# Result: all 4 AWS nameservers confirmed
```

### 6.4 — Create Route 53 Terraform Module

Created `terraform/modules/route53/` with:
- ACM DNS validation records (auto-created)
- ACM certificate validation waiter (waits until cert is valid)
- CloudFront ALIAS records for `binu.uk` and `www.binu.uk`
- Provider config for us-east-1 (ACM validation)

### 6.5 — Update Root Terraform to Wire Route 53

- Added `hosted_zone_id` variable
- Updated `main.tf` to use Route 53 module
- CloudFront now uses **validated** certificate ARN
- Root outputs updated with site URLs

### Commands Used

```bash
# Re-initialize Terraform with new module
cd terraform
terraform init -upgrade

# Validate
terraform validate
# Result: Success! The configuration is valid.
```

---

## Step 11: Terraform Apply (Hosting Infrastructure)

### Status: COMPLETED

### 11.1 — Terraform Plan

```bash
cd terraform
terraform plan
# Result: 14 to add, 0 to change, 0 to destroy
```

### 11.2 — Terraform Apply

```bash
terraform apply -auto-approve
```

**Resources created (in order):**
1. CloudFront OAC (`E3C40QZHDHVVYF`) — 1s
2. S3 Bucket (`binu-uk-frontend-production`) — 2s
3. S3 Bucket configs (public block, versioning, encryption, lifecycle) — ~56s
4. ACM Certificate (`4a8bb09f-c964-4c7d-834a-bc9c79fb6a81`) — 5s
5. Route 53 ACM validation CNAME records — 32s
6. ACM Certificate validation — instant (cert was already validated)
7. CloudFront Distribution (`E1XRHT36A0CR6B`) — 3m7s
8. S3 Bucket Policy (CloudFront OAC access) — 1s
9. Route 53 ALIAS records (`binu.uk` + `www.binu.uk`) — 32s

**Outputs:**
```
acm_certificate_arn            = "arn:aws:acm:us-east-1:651211133053:certificate/4a8bb09f-c964-4c7d-834a-bc9c79fb6a81"
cloudfront_distribution_domain = "d213wv9nt46m6w.cloudfront.net"
cloudfront_distribution_id     = "E1XRHT36A0CR6B"
s3_bucket_arn                  = "arn:aws:s3:::binu-uk-frontend-production"
s3_bucket_name                 = "binu-uk-frontend-production"
site_urls                      = { apex = "https://binu.uk", www = "https://www.binu.uk" }
```

---

## Step 12: Deploy & Verify

### Status: COMPLETED

### 12.1 — Deploy Vue App to S3

```bash
cd frontend

# Sync static assets with long-term caching
aws s3 sync dist/ s3://binu-uk-frontend-production --delete \
  --cache-control "public, max-age=31536000, immutable" \
  --exclude "index.html"

# Upload index.html with no-cache
aws s3 cp dist/index.html s3://binu-uk-frontend-production/index.html \
  --cache-control "no-cache, no-store, must-revalidate"
```

### 12.2 — Verify HTTPS on Both Domains

```bash
# Test apex domain
curl -sI https://binu.uk
# Result: HTTP/2 200, SSL valid, CloudFront edge LHR50-P5

# Test www subdomain
curl -sI https://www.binu.uk
# Result: HTTP/2 200, SSL valid, CloudFront edge LHR50-P5
```

**Verification results:**
- HTTPS with valid SSL — working
- `cache-control: no-cache` on index.html — working
- AES256 server-side encryption — working
- HTTP/3 available (`alt-svc: h3`) — working
- Served from London edge (`LHR50-P5`) — working

---

## Step 8-10: Terraform CI/CD Infrastructure (Separate Folder)

### Status: COMPLETED (Terraform config ready, not yet applied)

### Design Decision

Created a **separate `terraform-cicd/` folder** so the CI/CD infra is:
- Decoupled from hosting infra (separate state files)
- Reusable across other projects (just change `terraform.tfvars`)
- Independently deployable

### Commands Used

```bash
# Create directory structure
mkdir -p terraform-cicd/modules/{codebuild,iam}

# Initialize
cd terraform-cicd
terraform init

# Validate
terraform validate
# Result: Success! The configuration is valid.
```

### Structure

```
terraform-cicd/
├── backend.tf               # Separate state: frontend-cicd/cicd.tfstate
├── providers.tf              # AWS provider (eu-west-2)
├── variables.tf              # Inputs: hosting refs + GitHub config
├── outputs.tf                # Pipeline name, CodeStar connection status
├── main.tf                   # CodeStar connection, artifact bucket, pipeline
├── terraform.tfvars          # Project-specific values
├── modules/
│   ├── iam/                  # Least-privilege roles for CodeBuild + CodePipeline
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── codebuild/            # Build project with env vars
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
```

### How to Reuse for Other Projects

1. Copy `terraform-cicd/` to your new project
2. Update `terraform.tfvars` with:
   - New `project_name`
   - New `s3_bucket_name`, `s3_bucket_arn`, `cloudfront_distribution_id`, `cloudfront_distribution_arn`
   - New `github_owner`, `github_repo`
3. Update `backend.tf` with a unique state key
4. Run `terraform init && terraform apply`

### Before Applying — Action Required

1. ~~Update `terraform.tfvars` with your GitHub username and repo name~~ — Done
2. After `terraform apply`, approve the CodeStar connection in AWS Console:
   **AWS Console → Developer Tools → Settings → Connections → Approve**

### CI/CD Terraform Apply

```bash
cd terraform-cicd
terraform plan
# Result: 11 to add, 0 to change, 0 to destroy

terraform apply -auto-approve
```

**Resources created:**
1. CodeStar Connection (`baf553eb-ec4d-47da-b081-61cbccb2a213`) — PENDING approval
2. IAM Roles (codebuild + codepipeline) — 1s
3. S3 Artifact Bucket (`binu-uk-frontend-production-artifacts`) — 2s
4. IAM Policies (codebuild + codepipeline) — instant
5. CodeBuild Project (`binu-uk-frontend-production`) — 17s
6. CodePipeline (`binu-uk-frontend-production`) — instant
7. S3 Lifecycle (artifact cleanup after 30 days) — 56s

**Outputs:**
```
artifact_bucket_name       = "binu-uk-frontend-production-artifacts"
codebuild_project_name     = "binu-uk-frontend-production"
codestar_connection_arn    = "arn:aws:codestar-connections:eu-west-2:651211133053:connection/baf553eb-ec4d-47da-b081-61cbccb2a213"
codestar_connection_status = "PENDING"
pipeline_name              = "binu-uk-frontend-production"
```

---

## Step: Push Code to GitHub

### Status: COMPLETED

### Push to `webapp` repo (source code — triggers pipeline)

```bash
cd /Users/binujacob/Documents/interview/infra-works/1
git init
git remote add origin git@github.com:binujacobc/webapp.git
git add frontend/ buildspec.yml .gitignore
git commit -m "Initial commit: Vue 3 app with buildspec"
git branch -M main
git push -u origin main
```

### Push to `webappcicd` repo (infrastructure — Terraform)

```bash
cd /Users/binujacob/Documents/interview/infra-works/1
git init
git remote add cicd git@github.com:binujacobc/webappcicd.git
git add terraform/ terraform-cicd/ PLAN.md PROGRESS.md
git commit -m "Initial commit: Terraform hosting + CI/CD infra"
git branch -M main
git push cicd main
```

---

## Summary of Completed Steps

| Step | Description | Status |
|------|-------------|--------|
| 1.1 | Verify installed tools | Done |
| 1.2 | Install Terraform | Done |
| 1.3 | Verify AWS identity & region | Done |
| 1.4 | Create S3 state bucket | Done |
| 1.5 | Enable versioning | Done |
| 1.6 | Enable encryption | Done |
| 1.7 | Block public access | Done |
| 1.8 | Create DynamoDB lock table | Done |
| 1.9 | Create backend.tf | Done |
| 2.1 | Scaffold Vue 3 + Vite app | Done |
| 2.2 | Install dependencies | Done |
| 2.3 | Verify production build | Done |
| 3.1 | Create buildspec.yml | Done |
| 4.1 | Terraform module — S3 hosting | Done |
| 5.1 | Terraform module — ACM certificate | Done |
| 6.1 | Create Route 53 hosted zone (CLI) | Done |
| 6.2 | Update nameservers in GoDaddy | Done |
| 6.3 | Validate DNS propagation | Done |
| 6.4 | Terraform module — Route 53 | Done |
| 6.5 | Wire Route 53 into root Terraform | Done |
| 7.1 | Terraform module — CloudFront distribution | Done |
| 8.1 | Terraform module — IAM (least privilege) | Done |
| 9.1 | Terraform module — CodeBuild | Done |
| 10.1 | Terraform — CodePipeline + CodeStar + artifacts | Done |
| 11.1 | Terraform plan (hosting) | Done |
| 11.2 | Terraform apply — hosting (14 resources) | Done |
| 11.3 | Terraform apply — CI/CD (11 resources) | Done |
| 12.1 | Deploy Vue app to S3 | Done |
| 12.2 | Verify HTTPS on both domains | Done |
| 12.3 | Push code to GitHub | Done |

---

## AWS Resources Created

### Via CLI (one-time setup)

| Resource | Name / ID | Region |
|----------|-----------|--------|
| S3 Bucket | `binu-uk-terraform-state` | eu-west-2 |
| DynamoDB Table | `terraform-lock` | eu-west-2 |
| Route 53 Hosted Zone | `Z03233472I7CYFANJLA2X` (binu.uk) | Global |

### Via Terraform — Hosting (`terraform/`)

| Resource | Name / ID | Region |
|----------|-----------|--------|
| S3 Bucket | `binu-uk-frontend-production` | eu-west-2 |
| S3 Bucket Policy | CloudFront OAC access | eu-west-2 |
| ACM Certificate | `4a8bb09f-c964-4c7d-834a-bc9c79fb6a81` | us-east-1 |
| Route 53 Records | ACM CNAME + ALIAS (binu.uk, www.binu.uk) | Global |
| CloudFront Distribution | `E1XRHT36A0CR6B` (`d213wv9nt46m6w.cloudfront.net`) | Global |
| CloudFront OAC | `E3C40QZHDHVVYF` | Global |

### Via Terraform — CI/CD (`terraform-cicd/`)

| Resource | Name / ID | Region |
|----------|-----------|--------|
| CodeStar Connection | `baf553eb-ec4d-47da-b081-61cbccb2a213` (PENDING) | eu-west-2 |
| S3 Bucket (artifacts) | `binu-uk-frontend-production-artifacts` | eu-west-2 |
| IAM Role | `binu-uk-frontend-production-codebuild` | Global |
| IAM Role | `binu-uk-frontend-production-codepipeline` | Global |
| CodeBuild Project | `binu-uk-frontend-production` | eu-west-2 |
| CodePipeline | `binu-uk-frontend-production` | eu-west-2 |

---

## GitHub Repositories

| Repo | Purpose | Contents |
|------|---------|----------|
| `binujacobc/webapp` | Source code (triggers pipeline) | `frontend/`, `buildspec.yml` |
| `binujacobc/webappcicd` | Infrastructure (Terraform) | `terraform/`, `terraform-cicd/`, `PLAN.md`, `PROGRESS.md` |

---

## Files Created

| File | Purpose |
|------|---------|
| `PLAN.md` | Full step-by-step implementation plan |
| `PROGRESS.md` | This file — tracks completed steps and commands used |
| `buildspec.yml` | CodeBuild build specification |
| `frontend/` | Vue 3 + Vite application |
| `terraform/` | Hosting infra (S3, ACM, CloudFront, Route 53) |
| `terraform-cicd/` | CI/CD infra (CodeBuild, CodePipeline, IAM) — reusable |

---

## Remaining Steps

- [x] All infrastructure created and deployed
- [x] Push code to GitHub
- [ ] **Approve CodeStar connection in AWS Console** (manual)
- [ ] Trigger first pipeline run (push to `webapp` main branch)
- [ ] Step 13: Production hardening
