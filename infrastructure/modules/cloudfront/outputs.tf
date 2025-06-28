output "domain_name" {
  description = "the domain name of the cloudfront"
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}