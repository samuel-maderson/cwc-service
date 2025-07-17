terraform {
  backend "s3" {
    bucket         = "cwc-service-terraform-state-fxlulqh1"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "cwc-service-terraform-locks"
    encrypt        = true
  }
}
