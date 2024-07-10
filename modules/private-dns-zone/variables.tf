variable "dns_zone_names" {
  description = "List of DNS zone names"
  type        = list(string)
}


variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "private_dns_a_records" {
  type = list(object({
    name    = string
    ttl     = optional(number, 300)
    records = list(string)
  }))
  description = "List of objects with parameters to create A Record in Private DNS Zone"
  default     = []
}

variable "vnet_map" {
  type        = map(string)
  description = "Map of Virtual Network Name to Id, used to create VNet Link to Private DNS"
  default     = {}
}

variable "create_resource" {
  description = "Set to true to create the DNS zone and links, false to skip."
  type        = bool
  default     = false # You can set it to false to skip resource creation by default
}
