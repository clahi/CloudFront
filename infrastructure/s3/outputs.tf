output "s3_bucket_domain_name" {
  value = aws_s3_bucket.bucket.bucket_domain_name
  description = "The domain name of the s3 bucket"
}