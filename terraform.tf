terraform {
backend "s3" {
    region  = "eu-west-3"
    key     = "terraform.tfstate"
    bucket  = "codica-tf"
  }
}