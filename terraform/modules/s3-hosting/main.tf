resource "aws_s3_bucket" "hosting" {
  bucket        = "${var.project_name}-${var.environment}"
  force_destroy = var.force_destroy

  tags = {
    Name = "${var.project_name}-${var.environment}"
  }
}

resource "aws_s3_bucket_versioning" "hosting" {
  bucket = aws_s3_bucket.hosting.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "hosting" {
  bucket = aws_s3_bucket.hosting.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "hosting" {
  bucket = aws_s3_bucket.hosting.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "hosting" {
  bucket = aws_s3_bucket.hosting.id

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
