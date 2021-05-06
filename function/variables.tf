variable "name" {}
variable "role" {}
variable "code" {}

variable "tag" {
  default = "1.0"
}

variable "memory_size" {
  type = number
  default = 128
}
variable "timeout" {
  type = number
  default = 30
}

variable "environment_variables" {
  type = any
  default = {}
}