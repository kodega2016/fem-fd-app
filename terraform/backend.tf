terraform {

  backend "s3" {
    bucket = "fem-fd-app-tfstate"
    key    = "fem-fd.tfstate"
    region = "us-east-1"
  }
}
