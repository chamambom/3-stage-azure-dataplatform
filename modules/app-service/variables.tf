variable "resource-group-name" {
  description = "A container that holds related resources for an Azure solution"
}
variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
}
variable "service-plan-name" {
  description = "Specifies the name of the App Service Plan component"
}
variable "app-service-name" {
  description = "Specifies the name of the App Service."
}
variable "site-config" {
  description = "Site configuration for Application Service"
  type        = any
  default     = {}
}
variable "os-type" {
  type = string
}
variable "app-service-skuname" {
  type = string
}
