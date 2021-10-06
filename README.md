# terraform-aws-mongodb
Integrating MongoDB Atlas with AWS infra [Terraform module](https://registry.terraform.io/modules/toluna-terraform/mongodb/aws/latest)

## Requirements
The module requires some configurations for Atlas MongoDB
#### Minimum requirements:
- required_providers:
  - source = "mongodb/mongodbatlas"
  - version = "0.9.0"
- mongodbatlas public_key (api key for allowing Terraform to perform actions)
- mongodbatlas private_key (api key for allowing Terraform to perform actions)
- mongodbatlas atlasprojectid

## Usage
```hcl
module "mongodb" {
  source                = "toluna-terraform/terraform-aws-mongodb"
  version               = "~>0.0.1" // Change to the required version.
  environment           = local.environment
  app_name              = local.app_name
  atlasprojectid        = var.atlasprojectid
  atlas_region          = var.atlas_region
  atlas_num_of_replicas = local.env_vars.atlas_num_of_replicas
  backup_on_destroy     = true
  restore_on_create     = true
  ip_whitelist          = local.ip_whitelist
  atlas_num_of_shards         = 1
  mongo_db_major_version      = "4.2"
  disk_size_gb                = 10
  provider_disk_iops          = 1000
  provider_volume_type        = "STANDARD"
  provider_instance_size_name = "M10"
}
```
To run the mongorestore/mongodump script mnually (mongo_actions.sh): 
- cd to the path containing your environment.json (see examples)
- ../../../toluna-terraform/terraform-aws-mongodb/files/mongo_actions.sh [service_name] [action] [uri]
  - To backup run : ../../../toluna-terraform/terraform-aws-mongodb/files/mongo_actions.sh myService mongo_backup mongodb+srv://myService.test.mongodb.net
  - To restore run : ../../../toluna-terraform/terraform-aws-mongodb/files/mongo_actions.sh myService mongo_restore mongodb+srv://myService.test.mongodb.net

## Toggles
#### Backup and Restore flags:
```yaml
backup_on_destroy     = true
restore_on_create     = true
```
The following resources will be created:
- MongoDB cluster
- MongoDB User with read/write permissions (including password)
- MongoDB Whitelist including Ip's of allowed environments
- The following SSM Params will be created:
  - db_username
  - db_password
  - db_hostname (MongoDB connection string)
- Upon destroy if MongoDB dumps bucket does not exist it will be created

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.59 |
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | >= 0.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.59 |
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | >= 0.9.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="mongodb"></a> [mongodb](#module\_mongodb) | ../../ |  |

## Resources

| Name | Type |
|------|------|
| [mongodbatlas_cluster](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cluster) | resource |
| [aws_ssm_parameter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [mongodbatlas_project_ip_whitelist](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/guides/1.0.0-upgrade-guide) | resource |
| [mongodbatlas_database_user](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user) | resource |
| [random_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

No inputs.

## Outputs
| Name | Value |
|------|-------|
| cluster_connection_sting| cluster connection string( Stripped without "mongodb+srv://" ) |

