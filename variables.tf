variable "name" {}
variable "image" {}

variable "essential" {
  default = true
}

variable "command" {
  type = "list"
}

variable "links" {
  type = "list"
  default = []
}

variable "cpu" {
  default = ""
}

variable "memory" {
  default = ""
}

variable "port_mappings" {
  type = "list"
  default = []
}

variable "environment" {
  type = "list"
  default = []
}
