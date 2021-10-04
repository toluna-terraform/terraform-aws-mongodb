terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "0.9.0"
    }
  }
}

provider "mongodbatlas" {
  public_key = var.atlas_public_key
  private_key  = var.atlas_private_key
}

resource "mongodbatlas_cluster" "main" {
  project_id                   = var.atlasprojectid
  name                         = "${local.app_name}-${local.environment}"
  num_shards                   = 1
  replication_factor           = local.env_vars.atlas_num_of_replicas
  provider_backup_enabled      = true
  auto_scaling_disk_gb_enabled = true
  mongo_db_major_version       = "4.2"

  provider_name               = "AWS"
  disk_size_gb                = 10
  provider_disk_iops          = 1000
  provider_volume_type        = "STANDARD"
  provider_instance_size_name = "M10"
  provider_region_name        = var.atlas_region
  
}

resource "null_resource" "db_persist" {
  triggers = {
    address = "${mongodbatlas_cluster.main.srv_address}"
  }
  provisioner "local-exec" {
    when    = destroy
    on_failure = fail
      command = <<-EOT
        ${path.module}/mongo_actions.sh chorus mongo_backup ${self.triggers.address}
      EOT
  }
  provisioner "local-exec" {
      command = <<-EOT
        ${path.module}/mongo_actions.sh chorus mongo_restore ${self.triggers.address}
      EOT
  }
}

