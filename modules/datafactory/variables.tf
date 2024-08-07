variable "name" {
  type        = string
  description = "The name to assign to the new Azure Data Factory."
}

variable "rg-location" {
  type        = string
  description = "The Azure Region where the Data Factory is to be deployed."
}

variable "rg-name" {
  type        = string
  description = "The name of the Resource group where the Data Factory will be deployed."
}

variable "public_network_enabled" {
  type        = bool
  description = "(Optional) Is the Data Factory visible to the public network? Defaults to true"
  default     = false
}

variable "managed_virtual_network_enabled" {
  type        = bool
  description = "Is Managed Virtual Network enabled?"
  default     = true
}

variable "customer_managed_key_id" {
  type        = string
  description = "Specifies the Azure Key Vault Key ID to be used as the Customer Managed Key (CMK) for double encryption. Required with user assigned identity."
  default     = null
}

variable "customer_managed_key_identity_id" {
  type        = string
  description = "Specifies the ID of the user assigned identity associated with the Customer Managed Key. Must be supplied if customer_managed_key_id is set."
  default     = null
}

variable "ado_git_configuration" {
  description = "Azure DevOps Git configuration for ADF"
  type = object({
    account_name         = string
    project_name         = string
    repository_name      = string
    collaboration_branch = string
    root_folder          = string
    # tenant_id            = string
  })
  nullable = true
  default  = null
}

variable "managed_private_endpoint" {
  type = set(object({
    name               = string
    target_resource_id = string
    subresource_name   = string
  }))
  description = "The ID  and sub resource name of the Private Link Enabled Remote Resource which this Data Factory Private Endpoint should be connected to"
  # default     = []
}

variable "global_parameters" {
  type = list(object({
    name  = string
    type  = optional(string, "String")
    value = string
  }))
  default     = []
  description = "Configuration of data factory global parameters"
}

variable "env" {
  type        = string
  description = "Environment name"
}


# variable "global_parameters" {
#   type        = any
#   description = "An input object to define a global parameter. Accepts multiple entries."
#   default     = {}
# }

variable "azure_integration_runtime" {
  type = map(object({
    description             = optional(string, "Azure Integrated Runtime")
    compute_type            = optional(string, "General")
    virtual_network_enabled = optional(string, true)
    core_count              = optional(number, 8)
    time_to_live_min        = optional(number, 0)
    cleanup_enabled         = optional(bool, true)
  }))
  description = <<EOF
  Map Object to define any Azure Integration Runtime nodes that required.
  key of each object is the name of a new node.
  configuration parameters within the object allow customisation.
  EXAMPLE:
  azure_integration_runtime = {
    az-ir-co-01 {
      "compute_type" .  = "ComputeOptimized"
      "cleanup_enabled" = true
      core_count        = 16
    },
    az-ir-gen-01 {},
    az-ir-gen-02 {},
  }

EOF
  default     = {}
}

# variable "log_analytics_workspace_id" {
#   type = string
# }

variable "adf_diag_name" {
  type = string
}

