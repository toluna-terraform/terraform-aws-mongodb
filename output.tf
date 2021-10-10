output "cluster_connection_sting" {
    value = split("//", mongodbatlas_cluster.main.connection_strings.0.standard_srv)[1]
}

output "s3_dump_file" {
    value = jsondecode("${data.external.get_dump_data.result.object}")
}