variable "img_display_name" {
  type    = string
  # keep your existing image name
  default = "ubuntu-22.04-20241206-jammy-server-cloudimg-amd64.img"
}

variable "namespace" {
  type    = string
  default = "ucab252-comp0235-ns"
}

variable "network_name" {
  type    = string
  # You used a fully qualified network path; keep it
  default = "ucab252-comp0235-ns/ds4eng"
}

variable "username" {
  type    = string
  default = "ucab252"
}

variable "keyname" {
  description = "Existing Harvester SSH key name to inject"
  type        = string
  default     = "ubuntu-cnc"
}

# SSH info for remote-exec
variable "ssh_user" {
  description = "Default SSH username for the image (ubuntu for Ubuntu cloud)"
  type        = string
  default     = "ubuntu"
}

variable "private_key_path" {
  description = "PRIVATE key path that matches the Harvester SSH key"
  type        = string
  default     = "~/.ssh/id_ed25519"
}
