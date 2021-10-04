# MongoDB with AWS

Configuration in this directory creates a MongoDB cluster with a db user .

The db user details (credentials) are stored in AWS SSM parameter store

If set to True upon destruction and creation of the cluster a db dump is stored/restored from/to a s3 bucket.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS AtlasMongoDB, for example). Run `terraform destroy` when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.59 |
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | >= 0.9.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="mongodb"></a> [mongodb](#module\_mongodb) | ../../ |  |

## Resources

No resources.

## Inputs

No inputs.

## Outputs
No Outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->