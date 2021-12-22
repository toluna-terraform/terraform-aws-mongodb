terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "1.1.1"
    }
  }
}
provider "aws" {
  region = "us-east-1"
  profile = "chorus-non-prod"
}

module "mongodb" {
  source                = "../"
  environment           = "test"
  app_name              = "chorus"
  aws_profile           = "my-aws-profile"
  env_type              = "non-prod"
  atlasprojectid        = "1234567890abcdefghijklmno"
  atlas_region          = "US_EAST_1"
  atlas_num_of_replicas = 3
  aws_vpce              = "my-vpce-id"
  backup_on_destroy     = true
  restore_on_create     = true
  allowed_envs          = []
  db_name               = "test-db"
  init_db_environment   = "src-db"
  init_db_aws_profile   = "src-aws-profile"
  atlas_num_of_shards         = 1
  mongo_db_major_version      = "4.2"
  disk_size_gb                = 10
  provider_disk_iops          = 1000
  provider_volume_type        = "STANDARD"
  provider_instance_size_name = "M10"
}
