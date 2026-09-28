terraform {
  backend "s3" {
    bucket       = "angelo-hello-devops-tfstate-200359303675"
    key          = "hello-devops/terraform.tfstate"
    region       = "us-west-1"
    encrypt      = true
    use_lockfile = true
  }

  required_version = ">= 1.16.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}