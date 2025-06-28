output "cloudfront_domain_name" {
  description = "The cloudfront domain name"
  value       = module.cloudfront.domain_name
}