
provider "aws" {
  alias = "peer"
  region = var.aws_region
}

resource "mongodbatlas_network_peering" "main" {
  for_each               = toset(var.allowed_envs)
  accepter_region_name   = var.aws_region
  project_id             = var.atlasprojectid
  container_id           = data.mongodbatlas_network_containers.main.results[0].id
  provider_name          = "AWS"
  route_table_cidr_block = data.aws_vpc.main[each.key].cidr_block 
  vpc_id                 = data.aws_vpc.main[each.key].id
  aws_account_id         = var.aws_account_id.id
  depends_on = [
    mongodbatlas_cluster.main
  ]
}

resource "aws_vpc_peering_connection_accepter" "main" {
  for_each                  = toset(var.allowed_envs)
  provider                  = aws.peer
  vpc_peering_connection_id = mongodbatlas_network_peering.main[each.key].connection_id
  auto_accept = true
  depends_on = [
    mongodbatlas_network_peering.main
  ]
}

