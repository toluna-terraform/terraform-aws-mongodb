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
