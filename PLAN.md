# Production-Ready Vue.js Frontend CI/CD on AWS

## Architecture Overview

```
GitHub Repo --> AWS CodePipeline --> CodeBuild --> S3 (Static Hosting) --> CloudFront (CDN + SSL) --> binu.uk
```

## Project Structure

```
.
├── PLAN.md
├── frontend/                    # Vue.js application
│   ├── package.json
│   ├── vite.config.js
│   ├── src/
│   │   ├── main.js
│   │   ├── App.vue
│   │   └── components/
│   └── public/
├── buildspec.yml                # CodeBuild build specification
└── terraform/                   # Infrastructure as Code
    ├── backend.tf               # S3 remote state backend
    ├── providers.tf             # AWS provider config
    ├── variables.tf             # Input variables
    ├── outputs.tf               # Output values
    ├── s3.tf                    # S3 bucket for hosting
    ├── cloudfront.tf            # CloudFront distribution
    ├── acm.tf                   # SSL certificate
    ├── route53.tf               # DNS records (optional - see Step 6)
    ├── codebuild.tf             # CodeBuild project
    ├── codepipeline.tf          # CodePipeline
    ├── iam.tf                   # IAM roles and policies
    └── terraform.tfvars         # Variable values (git-ignored)
```

---

## Step-by-Step Plan

### Step 1: Prerequisites & Initial Setup

- [ ] Install required tools: `terraform`, `aws-cli`, `node` (v18+), `npm`
- [ ] Configure AWS CLI with credentials (`aws configure`)
- [ ] Create an S3 bucket manually for Terraform remote state (e.g., `binu-uk-terraform-state`)
- [ ] Create a DynamoDB table for state locking (e.g., `terraform-lock`, partition key: `LockID`)
- [ ] Create a GitHub repository and push the code
- [ ] Create a GitHub personal access token (classic) with `repo` and `admin:repo_hook` scopes
- [ ] Store the GitHub token in AWS Secrets Manager or SSM Parameter Store

### Step 2: Create the Vue.js Frontend App

- [ ] Scaffold a minimal Vue 3 + Vite app (`npm create vue@latest`)
- [ ] Keep it simple: a landing page with basic routing
- [ ] Verify it builds locally (`npm run build` produces `dist/`)
- [ ] Add `.gitignore` for `node_modules/`, `dist/`

### Step 3: Create the buildspec.yml

- [ ] Define install phase: install Node.js 18, run `npm ci`
- [ ] Define build phase: run `npm run build`
- [ ] Define artifacts: export `dist/` directory
- [ ] Add caching for `node_modules/` to speed up builds
- [ ] Add post-build phase: CloudFront cache invalidation

### Step 4: Terraform - S3 Static Hosting Bucket

- [ ] Create S3 bucket with versioning enabled
- [ ] Block all public access (CloudFront will use OAC)
- [ ] Configure bucket policy to allow CloudFront OAC access only
- [ ] Enable server-side encryption (AES-256)
- [ ] Add lifecycle rules to clean up old versions (optional)

### Step 5: Terraform - ACM SSL Certificate

- [ ] Request ACM certificate in `us-east-1` (required for CloudFront)
- [ ] Request for `binu.uk` and `*.binu.uk` (SAN)
- [ ] **Manual Step**: Add the DNS validation CNAME records in GoDaddy
- [ ] Wait for certificate validation before proceeding

### Step 6: DNS Configuration (GoDaddy)

> Since the domain is on GoDaddy (not Route 53), DNS records must be added manually.
> Optionally, you can transfer DNS to Route 53 for full automation.

- [ ] Add ACM validation CNAME records in GoDaddy DNS
- [ ] After CloudFront is created, add a CNAME record:
  - `www` -> CloudFront distribution domain (e.g., `d1234.cloudfront.net`)
- [ ] For apex domain (`binu.uk`), either:
  - **Option A (Recommended)**: Transfer DNS to Route 53 and use an ALIAS record
  - **Option B**: Use GoDaddy forwarding from `binu.uk` -> `www.binu.uk`
  - **Option C**: Use a CNAME flattening service

### Step 7: Terraform - CloudFront Distribution

- [ ] Create Origin Access Control (OAC) for S3
- [ ] Configure CloudFront distribution with:
  - S3 origin using OAC (not OAI - OAC is the modern approach)
  - SSL certificate from ACM
  - Alternate domain names: `binu.uk`, `www.binu.uk`
  - Default root object: `index.html`
  - Custom error responses: 403/404 -> `/index.html` (SPA routing)
  - Viewer protocol policy: redirect HTTP to HTTPS
  - Minimum TLS version: TLSv1.2_2021
  - Price class: PriceClass_100 (cheapest, NA + EU)
  - Caching policy: CachingOptimized for static assets
  - Response headers policy: SecurityHeadersPolicy
  - Enable compression (gzip + brotli)
  - Logging to a separate S3 bucket (optional but recommended)
- [ ] Enable WAF (optional, adds cost)

### Step 8: Terraform - IAM Roles & Policies

- [ ] **CodeBuild Service Role**:
  - S3 read/write to hosting bucket
  - CloudWatch Logs (create/put)
  - CloudFront invalidation
  - S3 read for pipeline artifact bucket
- [ ] **CodePipeline Service Role**:
  - S3 read/write to artifact bucket
  - CodeBuild start/batch builds
  - Secrets Manager / SSM read (for GitHub token)
- [ ] Follow least-privilege principle — no wildcard `*` resources where possible
- [ ] Add explicit deny for sensitive actions

### Step 9: Terraform - CodeBuild Project

- [ ] Create CodeBuild project with:
  - Environment: `aws/codebuild/amazonlinux2-x86_64-standard:5.0`
  - Compute type: BUILD_GENERAL1_SMALL (sufficient for frontend)
  - Privileged mode: false (not needed for frontend builds)
  - Build timeout: 10 minutes
  - Environment variables: S3 bucket name, CloudFront distribution ID
  - Artifact type: CODEPIPELINE
  - Cache: S3 caching for `node_modules/`
  - CloudWatch log group for build logs

### Step 10: Terraform - CodePipeline

- [ ] Create pipeline artifact S3 bucket (encrypted, versioned)
- [ ] Configure pipeline stages:
  1. **Source Stage**: GitHub v2 connection (CodeStar)
    - Create CodeStar connection to GitHub
    - **Manual Step**: Approve the pending connection in AWS Console
    - Branch: `main`
    - Trigger on push
  2. **Build Stage**: CodeBuild
    - Input: source artifact
    - Output: build artifact
  3. *(Optional) Manual Approval Stage* for production
- [ ] Enable pipeline execution notifications via SNS (optional)

### Step 11: Terraform - Apply Infrastructure

- [ ] Run `terraform init` to initialize backend and providers
- [ ] Run `terraform plan` and review the execution plan
- [ ] Run `terraform apply` for ACM certificate first (needs DNS validation)
- [ ] Complete DNS validation in GoDaddy
- [ ] Run `terraform apply` for remaining resources
- [ ] Note: Use `terraform apply -target` if needed for staged deployment

### Step 12: Post-Deployment Verification

- [ ] Approve the CodeStar GitHub connection in AWS Console
- [ ] Push code to trigger the pipeline
- [ ] Verify CodePipeline execution succeeds
- [ ] Verify S3 bucket contains built files
- [ ] Verify CloudFront serves the site over HTTPS
- [ ] Test custom domain `https://www.binu.uk`
- [ ] Test SPA routing (refresh on a sub-route should work)
- [ ] Verify security headers (use securityheaders.com)
- [ ] Verify cache invalidation works on new deployments

### Step 13: Production Hardening Checklist

- [ ] Terraform state is encrypted and locked (S3 + DynamoDB)
- [ ] No secrets in code (GitHub token in Secrets Manager/SSM)
- [ ] S3 bucket is not publicly accessible
- [ ] CloudFront uses OAC (not legacy OAI)
- [ ] TLS 1.2+ enforced
- [ ] HTTP redirects to HTTPS
- [ ] Security headers configured (CSP, HSTS, X-Frame-Options, etc.)
- [ ] Build logs retained in CloudWatch
- [ ] Pipeline notifications configured
- [ ] Tagging strategy applied to all resources
- [ ] Cost monitoring: set up billing alerts

---

## Estimated AWS Resources & Costs (Monthly)

| Resource         | Estimated Cost |
|-----------------|---------------|
| S3 (hosting)    | ~$0.50        |
| CloudFront      | ~$1-5 (depending on traffic) |
| CodeBuild       | ~$0 (100 min/month free tier) |
| CodePipeline    | $1/pipeline   |
| ACM Certificate | Free          |
| Route 53 (if used) | $0.50/zone |
| **Total**       | **~$3-8/month** |

---

## Execution Order

```
1. Prerequisites (Step 1)
2. Vue App + Buildspec (Steps 2-3)
3. Terraform: S3 + ACM (Steps 4-5)
4. DNS Validation in GoDaddy (Step 6 - partial)
5. Terraform: CloudFront + IAM + CodeBuild + CodePipeline (Steps 7-10)
6. Terraform Apply (Step 11)
7. DNS CNAME for domain in GoDaddy (Step 6 - remaining)
8. Verify & Harden (Steps 12-13)
```

---

## Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Framework | Vue 3 + Vite | Modern, fast builds, small bundle |
| IaC | Terraform | Declarative, state management, widely adopted |
| CI/CD | CodePipeline + CodeBuild | Native AWS, no extra vendor, cost-effective |
| CDN | CloudFront | AWS-native, tight S3 integration, global edge |
| S3 Access | OAC (not OAI) | AWS recommended, more secure, supports SSE-KMS |
| Source | GitHub v2 (CodeStar) | Webhook-based, no polling, recommended over v1 |
| DNS | GoDaddy (manual) | Domain already there; Route 53 optional upgrade |
