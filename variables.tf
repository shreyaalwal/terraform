# variables.tf
variable "server_host" {
  description = "Remote server hostname or IP"
  type        = string
  sensitive   = true
}

variable "server_user" {
  description = "SSH username for remote server"
  type        = string
  sensitive   = true
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key file"
  type        = string
  sensitive   = true
}

variable "local_file_path" {
  description = "Local directory path to transfer"
  type        = string
  sensitive   = true
}

variable "remote_file_path" {
  description = "Remote destination path (not used in archive method)"
  type        = string
  sensitive   = true
  default     = "/var/www/html"
}