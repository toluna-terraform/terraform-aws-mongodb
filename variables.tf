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

variable "atlas_num_of_shards" {
  default = 1
  description = "Number of shards"
}

variable "mongo_db_major_version" {
  default = "4.2"
  description = "MongoDB version"
}

variable "disk_size_gb" {
  default = 10
  description = "MongoDB disk size in GB"
}

variable "provider_disk_iops" {
  default = 1000
  description = "MongoDB disk iops"
}
  
variable "provider_volume_type" {
  default = "STANDARD"
  description = "MongoDB volume type"
}
  
variable "provider_instance_size_name" {
  default = "M10"
  description = "MongoDB instance type"
} 
