resource "mongodbatlas_privatelink_endpoint" "main" {
  project_id    = var.atlasprojectid
  provider_name = "AWS"
  region        = var.atlas_region
}

resource "aws_vpc_endpoint" "main" {
  for_each           = toset(var.allowed_envs)
  vpc_id             = split("=",each.key)[1]
  service_name       = mongodbatlas_privatelink_endpoint.main.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = data.aws_subnet_ids.main[each.key].ids
  security_group_ids = data.aws_security_groups.main[each.key].ids
}

resource "mongodbatlas_privatelink_endpoint_service" "main" {
  for_each           = toset(var.allowed_envs)
  project_id          = mongodbatlas_privatelink_endpoint.main.project_id
  private_link_id     = mongodbatlas_privatelink_endpoint.main.private_link_id
  endpoint_service_id = aws_vpc_endpoint.main[each.key].id
  provider_name       = "AWS"
}
