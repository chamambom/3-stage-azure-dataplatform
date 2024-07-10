variable "workspace_name" {
  description = "The name of this Log Analytics workspace."
  type        = string
  default     = "workspacename"
}

variable "resource_group_name" {
  description = "The name of the resource group to create the resources in."
  type        = string
  default     = "rgname"
}

variable "location" {
  description = "The location to create the resources in."
  type        = string
  default     = "northeurope"
}

variable "sku" {
  description = "value"
  type        = string
  default     = "PerGB2018"
}

variable "local_authentication_disabled" {
  description = "Specifies if the Log Analytics Workspace should enforce authentication using Azure AD."
  type        = bool
  default     = true
}

variable "retention_in_days" {
  description = "The number of days that logs should be retained."
  type        = number
}

variable "log_analytics_destination_type" {
  description = "The type of log analytics destination to use for this Log Analytics Workspace."
  type        = string
  default     = null
}

variable "diagnostic_setting_enabled_log_categories" {
  description = "A list of log categories to be enabled for this diagnostic setting."
  type        = list(string)
  default     = ["Audit"]
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "name" {
  type        = string
  description = "A string value to describe prefix of all the resources"
  default     = ""
}

variable "default_tags" {
  type        = map(string)
  description = "A map to add common tags to all the resources"
  default = {
    "Scope" : "ACI"
    "CreatedBy" : "Terraform"
  }
}

variable "common_tags" {
  type        = map(string)
  description = "A map to add common tags to all the resources"
  default     = {}
}

variable "diagnostic_setting_name" {
  description = "The name of this azurerm monitor diagnostic setting."
  type        = string
  default     = "diagnostic-setting-name"
}

variable "diagnostic_setting_enabled_metrics" {
  description = "A map of metrics categories and their settings to be enabled for this diagnostic setting."
  type = map(object({
    enabled           = bool
    retention_days    = number
    retention_enabled = bool
  }))
  default = {
    "AllMetrics" = {
      enabled           = true
      retention_days    = 0
      retention_enabled = false
    }
  }
}
