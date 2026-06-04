terraform {
  backend "s3" {
    bucket       = "dashboard-tfstate-git-2026"
    key          = "cost-dashboard/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
    profile      = "lab6"
  }
}