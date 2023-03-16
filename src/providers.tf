terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.49"
    }
  }
}

provider "aws" {
  region = var.region


  default_tags {
    tags = {
      Project = "SD"
      Owner : var.owner
    }
  }
}
