
terraform {

  backend "s3" {

    bucket         = "lab6-terraform-state-ACCOUNT_ID_REMOVED"

    key            = "cost-dashboard/terraform.tfstate"

    region         = "us-east-1"

    encrypt        = true

    dynamodb_table = "lab6-terraform-locks"

    profile        = "lab6"

  }

}

