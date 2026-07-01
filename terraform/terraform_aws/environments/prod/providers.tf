terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "eu"
}

provider "aws" {
  region  = "eu-west-1"
  profile = "eu"
  alias   = "eu"
}

provider "aws" {
  alias   = "us"
  profile = "us"
  region  = "us-west-1"
}
