variable "atlas_region" {
  default     = "US_EAST_1"
  description = "Atlas Region"
}

variable "atlasprojectid" {
  description = "Atlas Project ID"
}

variable "app_name" {
  description = "Application name"
}

variable "environment" {
  description = "Environment name"
}

variable "atlas_num_of_replicas" {
  description = "Number of replicas"
}

variable "backup_on_destroy" {
  default = true
  description = "Create dump on destory"
}

variable "restore_on_create" {
  default = true
  description = "Restore DB from dump file"
}

variable "ip_whitelist" {
  default = []
  description = "White listed IP list"
}