resource "mongodbatlas_network_peering" "main" {
  for_each               = toset(var.allowed_envs)
  accepter_region_name   = var.aws_region
  project_id             = var.atlasprojectid
  container_id           = data.mongodbatlas_network_containers.main.results[0].id
  provider_name          = "AWS"
  route_table_cidr_block = data.aws_vpc.main[each.key].cidr_block
  vpc_id                 = each.key
  aws_account_id         = var.aws_account_id.id
  depends_on = [
    mongodbatlas_cluster.main
  ]
}
