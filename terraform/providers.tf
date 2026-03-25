terraform {

  backend "s3" {
    bucket = "fruits-webapp-terraform-state"
    key = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "fruits-webapp-terraform-locks"
    encrypt = true
  }
  
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = var.region

    default_tags {
      tags = {
        Project = var.project_name
        ManagedBy = "terraform"
      }
    }
}