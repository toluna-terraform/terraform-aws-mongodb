# terraform-aws-mongodb
Integrating MongoDB Atlas with AWS infra

## Requirements
The module requires some configurations for Atlas MongoDB
#### Minimum requirements:
- required_providers:
  - source = "mongodb/mongodbatlas"
  - version = "0.9.0"
- mongodbatlas public_key (api key for allowing Terraform to perform actions)
- mongodbatlas private_key (api key for allowing Terraform to perform actions)
- mongodbatlas atlasprojectid

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