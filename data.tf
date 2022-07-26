data "aws_s3_objects" "get_dump_list" {
  bucket = "${var.app_name}-${var.env_type}-mongodb-dumps"
  prefix = "${var.environment}/${var.db_name}.tar"
}

data "aws_s3_object" "get_dump_data" {
  count  = length(data.aws_s3_objects.get_dump_list.keys)
  bucket = data.aws_s3_objects.get_dump_list.bucket
  key    = data.aws_s3_objects.get_dump_list.keys[0]
    depends_on = [
    data.aws_s3_objects.get_dump_list
  ]
}

data "aws_ssm_parameter" "sdb_host" {
  count = var.init_db_environment != "NULL" ? 1 : 0
  name = "/infra/${var.init_db_environment}/sdb-host"
  depends_on = [
  mongodbatlas_database_user.main, aws_ssm_parameter.db_username, aws_ssm_parameter.db_password
]
}

data "aws_ssm_parameter" "sdb_username" {
  count = var.init_db_environment != "NULL" ? 1 : 0
  name = "/infra/${var.init_db_environment}/db-username"
  depends_on = [
  mongodbatlas_database_user.main, aws_ssm_parameter.db_username, aws_ssm_parameter.db_password
]
}

data "aws_ssm_parameter" "sdb_password" {
  count = var.init_db_environment != "NULL" ? 1 : 0
  name = "/infra/${var.init_db_environment}/db-password"
  depends_on = [
  mongodbatlas_database_user.main, aws_ssm_parameter.db_username, aws_ssm_parameter.db_password
]
}

data "template_file" "mongo_restore" {
  template = file("${path.module}/files/mongo_restore.tpl")
  vars = {
    SERVICE_NAME=var.app_name
    WORKSPACE=var.environment
    ENV_TYPE=var.env_type
    AWS_PROFILE=var.aws_profile
    DBHOST=trimprefix(mongodbatlas_cluster.main.srv_address,"mongodb+srv://")
    DBUSER=mongodbatlas_database_user.main.username
    DBPASSWORD=random_password.password.result
    INIT_DB_ENVIRONMENT=var.init_db_environment
    INIT_DB_AWS_PROFILE=var.init_db_aws_profile
    SDBHOST=try(data.aws_ssm_parameter.sdb_host[0].value,"NULL")
    SDBUSER=try(data.aws_ssm_parameter.sdb_username[0].value,"NULL")
    SDBPASSWORD=try(data.aws_ssm_parameter.sdb_password[0].value,"NULL")
  }
  depends_on = [
    mongodbatlas_database_user.main, aws_ssm_parameter.db_username, aws_ssm_parameter.db_password
  ]
}

data "template_file" "mongo_backup" {
  template = file("${path.module}/files/mongo_backup.tpl")
  vars = {
    SERVICE_NAME=var.app_name
    WORKSPACE=var.environment
    ENV_TYPE=var.env_type
    AWS_PROFILE=var.aws_profile
    DBHOST=trimprefix(mongodbatlas_cluster.main.srv_address,"mongodb+srv://")
    DBUSER=mongodbatlas_database_user.main.username
    DBPASSWORD=random_password.password.result
  }
  depends_on = [
    mongodbatlas_database_user.main, aws_ssm_parameter.db_username, aws_ssm_parameter.db_password
  ]
}


