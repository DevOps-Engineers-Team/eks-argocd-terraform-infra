variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "type" {
  type = string
  default = "Opaque"
}

variable "data" {
  type = map(string)
}
