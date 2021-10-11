data "aws_s3_bucket_objects" "get_dump_list" {
  bucket = "${var.app_name}-${var.env_type}-mongodb-dumps"
  prefix = "${var.environment}/${var.db_name}.tar"
}

data "aws_s3_bucket_object" "get_dump_data" {
  count  = length(data.aws_s3_bucket_objects.get_dump_list.keys)
  bucket = data.aws_s3_bucket_objects.get_dump_list.bucket
  key    = data.aws_s3_bucket_objects.get_dump_list.keys[0]
    depends_on = [
    data.aws_s3_bucket_objects.get_dump_list
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

data "template_file" "mongo_backup" {
  template = "${file("${path.module}/files/mongo_backup.tpl")}"
  vars = {
    PATH_MODULE="${path.module}"
    SERVICE_NAME="${var.app_name}"
    WORKSPACE="${var.environment}"
    ENV_TYPE="${var.env_type}"
    AWS_PROFILE="${var.aws_profile}"
    DBHOST="${mongodbatlas_cluster.main.srv_address}"
  }
  depends_on = [
    mongodbatlas_database_user.main, aws_ssm_parameter.db_username, aws_ssm_parameter.db_password, aws_ssm_parameter.db_hostname, aws_ssm_parameter.db_name
  ]
}