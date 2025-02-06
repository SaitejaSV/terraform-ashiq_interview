terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "5.84.0"
        }
    }
}

provider "aws"{
    #parameters to create a resource
    region = "us-east-1"
    
}