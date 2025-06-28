terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.5"
    }
  }
  required_version = ">= 1.7"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "cloud-front-saf2"

  tags = {
    Name = "My bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "control" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.bucket.id
  acl = "public-read"

  depends_on = [ 
    aws_s3_bucket_ownership_controls.control,
    aws_s3_bucket_public_access_block.public_access
   ]
}

# Enabling the S3 bucket to host a web page
resource "aws_s3_bucket_website_configuration" "web_conf" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}