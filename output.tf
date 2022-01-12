output "cluster_connection_sting" {
    value = split("//", mongodbatlas_cluster.main.connection_strings.0.standard_srv)[1]
}

output "s3_dump_file" {
    value = data.aws_s3_bucket_object.get_dump_data
}

output "mongo_endpoint_connection_sting" {
    value = trimprefix(lookup(mongodbatlas_cluster.main.connection_strings[0].aws_private_link_srv,var.aws_vpce[each.key].outputs.vpce.id,mongodbatlas_cluster.main.srv_address),"mongodb+srv://")
}