terraform {
  backend "s3" {
    bucket         = "cwc-service-terraform-state-6trh7922"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "cwc-service-terraform-locks"
    encrypt        = true
  }
}
