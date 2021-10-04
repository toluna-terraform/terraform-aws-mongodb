resource "mongodbatlas_cluster" "main" {
  project_id                   = var.atlasprojectid
  name                         = "${var.app_name}-${var.environment}"
  num_shards                   = 1
  replication_factor           = var.atlas_num_of_replicas
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

resource "aws_ssm_parameter" "db_hostname" {
  name        = "/infra/${var.app_name}/${var.environment}-db-host"
  description = "terraform_db_username"
  type        = "SecureString"
  value       = "${mongodbatlas_cluster.main.srv_address}"
  depends_on = [
    mongodbatlas_cluster.main
  ]
}

resource "null_resource" "db_backup" {
  count = var.backup_on_destroy ? 1 : 0
  triggers = {
    address = "${mongodbatlas_cluster.main.srv_address}"
  }
  provisioner "local-exec" {
    when    = destroy
    on_failure = fail
      command = <<-EOT
        ${path.module}/files/mongo_actions.sh chorus mongo_backup ${self.triggers.address}
      EOT
  }
  depends_on = [
    mongodbatlas_database_user.main
  ]
}

resource "null_resource" "db_restore" {
  count = var.restore_on_create ? 1 : 0
  triggers = {
    address = "${mongodbatlas_cluster.main.srv_address}"
  }
  provisioner "local-exec" {
      command = <<-EOT
        ${path.module}/files/mongo_actions.sh chorus mongo_restore ${self.triggers.address}
      EOT
  }
  depends_on = [
    mongodbatlas_database_user.main
  ]
}