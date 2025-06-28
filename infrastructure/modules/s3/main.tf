resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

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

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "public-read"

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

resource "aws_s3_bucket_policy" "my-static-website-policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PublicReadGetObject",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
  depends_on = [
    aws_s3_bucket_ownership_controls.control,
    aws_s3_bucket_public_access_block.public_access,
  ]
}

module "template_files" {
  source = "hashicorp/dir/template"

  base_dir = "${path.module}/webapp"
}

resource "aws_s3_object" "FrontEndFolder" {
  bucket = aws_s3_bucket.bucket.id

  for_each     = module.template_files.files
  key          = each.key
  content_type = each.value.content_type
  source       = each.value.source_path
  content      = each.value.content
  etag         = each.value.digests.md5
}