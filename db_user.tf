terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.1.1"
    }
  }
}
resource "random_password" "password" {
  length  = 14
  special = false
  upper   = false
}

resource "aws_ssm_parameter" "db_password" {
  for_each =  toset(var.allowed_envs)
  name        = "/infra/${each.key}/db-password"
  description = "terraform_db_password"
  type        = "SecureString"
  value       = "This is an env0 test"#random_password.password.result
  overwrite   = true
}

resource "aws_ssm_parameter" "db_username" {
  for_each =  toset(var.allowed_envs)
  name        = "/infra/${each.key}/db-username"
  description = "terraform_db_username"
  type        = "SecureString"
  value       = "${var.app_name}-${var.environment}-dbuser"
  overwrite   = true
}

resource "mongodbatlas_database_user" "main" {
  username           = "${var.app_name}-${var.environment}-dbuser"
  password           = random_password.password.result
  project_id         = var.atlasprojectid
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "${var.db_name}"
  }
}
