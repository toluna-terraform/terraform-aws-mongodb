resource "mongodbatlas_cluster" "main" {
  project_id                   = var.atlasprojectid
  name                         = "${var.app_name}-${var.environment}"
  num_shards                   = var.atlas_num_of_shards
  replication_factor           = var.atlas_num_of_replicas
  provider_backup_enabled      = true
  auto_scaling_disk_gb_enabled = true
  mongo_db_major_version       = var.mongo_db_major_version

  provider_name               = "AWS"
  disk_size_gb                = var.disk_size_gb
  provider_disk_iops          = var.provider_disk_iops
  provider_volume_type        = var.provider_volume_type
  provider_instance_size_name = var.provider_instance_size_name
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
    mongodbatlas_database_user.main,aws_ssm_parameter.db_username,aws_ssm_parameter.db_password,aws_ssm_parameter.db_hostname
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
    mongodbatlas_database_user.main,aws_ssm_parameter.db_username,aws_ssm_parameter.db_password,aws_ssm_parameter.db_hostname
  ]
}