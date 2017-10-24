variable "name" {}
variable "image" {}

variable "region" {
  default = ""
}

variable "logs_group" {
  default = ""
}

variable "logs_prefix" {
  default = ""
}

variable "essential" {
  default = true
}

variable "command" {
  type = "list"
  default = []
}

variable "entry_point" {
  type = "list"
  default = []
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

variable "environment_extra" {
  description = "A string that will be appended to the environment. Allows for computed values to be passed in."
  default = ""
}
