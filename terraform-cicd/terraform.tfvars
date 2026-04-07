aws_region   = "eu-west-2"
project_name = "binu-uk-frontend"
environment  = "production"

# Hosting infra references (from terraform/ outputs)
s3_bucket_name             = "binu-uk-frontend-production"
s3_bucket_arn              = "arn:aws:s3:::binu-uk-frontend-production"
cloudfront_distribution_id  = "E1XRHT36A0CR6B"
cloudfront_distribution_arn = "arn:aws:cloudfront::651211133053:distribution/E1XRHT36A0CR6B"

# GitHub source
github_owner  = "binujacobc"
github_repo   = "webapp"
github_branch = "main"
