terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "0.9.0"
    }
  }
}

provider "mongodbatlas" {
  public_key = "abcdefgh"
  private_key  = "abcdefgh-abcd-1234-5678-abcdefghijkl"
}

module "mongodb" {
  source                = "../../"
  version               = "~>0.0.1" // Change to the required version.
  environment           = "test-environment"
  app_name              = "test-app"
  atlasprojectid        = "1234567890abcdefghijklmno"
  atlas_region          = "US_EAST_1"
  atlas_num_of_replicas = 3
  backup_on_destroy     = true
  restore_on_create     = true
  ip_whitelist          = ["127.0.0.1","127.0.0.2","127.0.0.3"]
}