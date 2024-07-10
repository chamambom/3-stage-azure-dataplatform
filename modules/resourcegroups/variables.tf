variable "rg-name" {
  description = "The Name of the Resource Group"
  type        = string
}

variable "rg-location" {
  description = "The Azure Region where the Resource Group should exist"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
