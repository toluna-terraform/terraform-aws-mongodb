data "template_file" "mongo_backup" {
  template = "${file("${path.module}/files/mongo_backup.tpl")}"
  vars = {
    PATH_MODULE="${path.module}"
    SERVICE_NAME="${var.app_name}"
    WORKSPACE="${var.environment}"
    ENV_TYPE="${var.env_type}"
    AWS_PROFILE="${var.aws_profile}"
    DBHOST="${mongodbatlas_cluster.main.srv_address}"
    INIT_DB_WORKSPACE="${var.init_db}"
  }
  depends_on = [
    mongodbatlas_database_user.main, aws_ssm_parameter.db_username, aws_ssm_parameter.db_password, aws_ssm_parameter.db_hostname, aws_ssm_parameter.db_name
  ]
}

data "template_file" "mongo_restore" {
  template = "${file("${path.module}/files/mongo_restore.tpl")}"
  vars = {
    PATH_MODULE="${path.module}"
    SERVICE_NAME="${var.app_name}"
    WORKSPACE="${var.environment}"
    ENV_TYPE="${var.env_type}"
    AWS_PROFILE="${var.aws_profile}"
    DBHOST="${mongodbatlas_cluster.main.srv_address}"
    INIT_DB_WORKSPACE="${var.init_db}"
  }
  depends_on = [
    mongodbatlas_database_user.main, aws_ssm_parameter.db_username, aws_ssm_parameter.db_password, aws_ssm_parameter.db_hostname, aws_ssm_parameter.db_name
  ]
}