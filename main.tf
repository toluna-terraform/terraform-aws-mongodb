
module "mongo-cluster" {
    source                = "./modules/mongocluster"
    atlas_public_key      = var.atlas_public_key
    atlas_private_key     = var.atlas_private_key
    atlasprojectid        = var.atlasprojectid
    app_name              = var.app_name
    environment           = var.environment
    atlas_num_of_replicas = var.atlas_num_of_replicas
    atlas_region          = var.atlas_region
}
