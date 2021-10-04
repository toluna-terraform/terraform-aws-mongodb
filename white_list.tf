resource "mongodbatlas_project_ip_whitelist" "ngw-ip" {
  for_each = var.ip_whitelist
  project_id = var.atlasprojectid
  ip_address = [each.key]
  comment    = "VPC NAT Gateway IP"
}
