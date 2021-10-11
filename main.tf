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
  name        = "/infra/${var.environment}/db-host"
  description = "terraform_db_hostname"
  type        = "SecureString"
  value       = "${mongodbatlas_cluster.main.srv_address}"
  overwrite   = true
  depends_on = [
    mongodbatlas_cluster.main
  ]
}

resource "local_file" "mongo_backup" {
  filename = "${path.module}/files/${var.environment}/mongo_backup.sh"
  content = templatefile("${path.module}/files/${var.environment}/mongo_backup.tpl",
  {
    PATH_MODULE = "${path.module}",
    SERVICE_NAME = "${var.app_name}",
    WORKSPACE = "${var.environment}",
    ENV_TYPE = "${var.env_type}",
    AWS_PROFILE = "${var.aws_profile}",
    DBHOST = "${mongodbatlas_cluster.main.srv_address}",
    INIT_DB_WORKSPACE = "${var.init_db}"
  })
  depends_on = [
    mongodbatlas_database_user.main, aws_ssm_parameter.db_username, aws_ssm_parameter.db_password, aws_ssm_parameter.db_hostname, aws_ssm_parameter.db_name
  ]
}

resource "local_file" "mongo_restore" {
  filename = "${path.module}/files/${var.environment}/mongo_restore.sh"
  content = templatefile("${path.module}/files/mongo_restore.tpl",
  {
    PATH_MODULE="${path.module}",
    SERVICE_NAME="${var.app_name}",
    WORKSPACE="${var.environment}",
    ENV_TYPE="${var.env_type}",
    AWS_PROFILE="${var.aws_profile}",
    DBHOST="${mongodbatlas_cluster.main.srv_address}",
    INIT_DB_WORKSPACE="${var.init_db}"
  })
  depends_on = [
    mongodbatlas_database_user.main, aws_ssm_parameter.db_username, aws_ssm_parameter.db_password, aws_ssm_parameter.db_hostname, aws_ssm_parameter.db_name
  ]
}

resource "null_resource" "db_backup" {
  count = var.backup_on_destroy ? 1 : 0
  triggers = {
    address = "${mongodbatlas_cluster.main.srv_address}",
  }
  provisioner "local-exec" {
    when       = destroy
    on_failure = fail
    command    = "${path.module}/files/${terraform.workspace}/mongo_backup.sh"
  }
  depends_on = [
    mongodbatlas_database_user.main, aws_ssm_parameter.db_username, aws_ssm_parameter.db_password, aws_ssm_parameter.db_hostname, aws_ssm_parameter.db_name,local_file.mongo_backup
  ]
}

resource "null_resource" "db_restore" {
  count = var.restore_on_create ? 1 : 0
  triggers = {
    address = "${mongodbatlas_cluster.main.srv_address}",
  }
  provisioner "local-exec" {
    command = "${path.module}/files/${terraform.workspace}/mongo_restore.sh"
  }
  depends_on = [
    mongodbatlas_database_user.main, aws_ssm_parameter.db_username, aws_ssm_parameter.db_password, aws_ssm_parameter.db_hostname, aws_ssm_parameter.db_name,local_file.mongo_restore
  ]
}
