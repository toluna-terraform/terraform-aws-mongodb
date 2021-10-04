
# module "mongodb-roles" {
#   source                   = "./modules/roles"
#   environment              = var.environment
#   app_name                 = var.app_name
#   atlasprojectid           = var.atlasprojectid
# }

module "mongodb-users" {
  source                   = "./modules/dbuser"
  environment              = var.environment
  app_name                 = var.app_name
  atlasprojectid           = var.atlasprojectid
  # depends_on = [
  #   module.mongodb-roles
  # ]
}

module "mongodb-cluster" {
  source                   = "./modules/cluster"
  environment              = var.environment
  app_name                 = var.app_name
  atlasprojectid           = var.atlasprojectid
  atlas_region             = var.atlas_region
  atlas_num_of_replicas    = var.atlas_num_of_replicas
  backup_on_destroy        = var.backup_on_destroy
  restore_on_create        = var.restore_on_create
}

