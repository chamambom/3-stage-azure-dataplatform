variable "virtual_network_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "virtual_network_address_space" {
  description = "name of the virtual network"
  type        = list(string)
}

variable "subnets" {
  description = "A map of subnet configurations"
  type = map(object({
    name             = string
    address_prefixes = list(string)
    delegations = list(object({
      name = string
    }))
  }))
}



