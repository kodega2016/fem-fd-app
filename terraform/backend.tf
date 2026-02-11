terraform {
  required_version = ">= 1.3.0"

  backend "s3" {
    bucket = "fem-fd-app-tfstate"
    key    = "fem-fd.tfstate"
    region = "us-east-1"
  }
}
