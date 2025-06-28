terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5"
    }
  }
  required_version = ">= 1.7"
}

provider "aws" {
  region = "us-east-1"
}

module "s3" {
  source = "../../modules/s3"

  bucket_name = "cloud-front-saf2"
}

module "cloudfront" {
  source             = "../../modules/cloudfront"
  bucket_domain_name = module.s3.s3_bucket_domain_name
}