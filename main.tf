
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
}