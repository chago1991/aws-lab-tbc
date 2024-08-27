terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
  backend "s3" {
    bucket                  = "tbc-lab-tfstate"
    key                     = "terraform.tfstate"
    region                  = "eu-central-1"
    dynamodb_table          = "dynamodb-tbc-lab-tfstate"

  }

}

provider "aws" {
  region     = "eu-central-1"
  access_key = ""
  secret_key = ""

}


