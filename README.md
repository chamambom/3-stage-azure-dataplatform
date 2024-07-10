## 3 stage dataplatform - dev, uat and prod using github actions.

This project contains resources that deploy the following Azure Data Platform Infrastructure resources 

- Azure Resource Groups
- Azure Datalake
- Azure Data Factory
- Azure Private Endpoints
- Azure Private DNS 
- Azure Virtual Networks and Subnets
- Azure Route tables
- Azure Vnet peering
- Azure SQL Server and DB
- Azure Keyvault
- Azure App Service 

### Background

In 2023, I served as a Senior DevOps Engineer on this project, focusing on deploying the infrastructure for the data resources. The data solution that utilised the infrastructure itself was deployed by another vendor.

**The initial deployment utilized Azure DevOps for CI/CD and Azure with multiple subscriptions. In this repository, I have refactored it to use GitHub Actions workflows targeting an Azure Tenant with a single subscription.**

### Assmptions/Challenges that I experienced while working on the project 

-  I was using a self-hosted agent to run my pipelines and experienced race conditions between deploying a Data Lake and a Data Lake private endpoint, as the pipeline repeatedly attempted to resolve the private endpoint private DNS entry. The Data Lake module's output, specifically the Data Lake ID, was required by the private endpoint module to create a private DNS record.

Solution - used a static endpoint id e.g vnet-id= "/subscriptions/x/resourceGroups/rg-dev-ae-01/providers/Microsoft.Network/virtualNetworks/vnet-dev-ae-01"

- Custom DNS was being used - records were being added manually.
-

### Recommended changes 

- Incoporate an Azure Private DNS resolver if you have a hybrid setup.
- Add DNS records automatically instead of manually.


I will be refactoring this codebase as I go, making it more efficient and extensible by incorporating new learnings and documenting my procedures and thought process.

### Landing Zone Design

![alt text](/img/1_EPvLRwAdrHCxuisbMKYjLw.webp)

I wont dwell much into this but the gist of it is that, The platform Landing Zone existed prior to this deployment. The platform landing zone was based on the Best-Practices of the Cloud Adoption Framework.

There is a distinction between Platform Landing Zones and Applications Landing Zones.

This distinction is made through the two Management Groups: Platform and Applications:

Platform contains the Landing Zones responsible for the infrastructure resources shared between the different applications.
Application, on the other hand, contains the application-specific Landing Zones that will make use of the shared services and resources of the Landing Zones Platform 

- Under Platform we then have Idenity, Management and Connectivity.

For this project I will focus our attention exclusively on the Dataplatform Infrastructure deployment.

Application/workload Landing Zone - Data platform 

- Dev environment - nonprod subscription
- Uat environment - nonprod subscription
- Prod environment - prod subscription

Connectivity Landing Zone 

- Connectivity subscription (shared resources - hub vnet, azure firewall, Azure Private DNS)
- Shared subscription (storage account with containers that store terraform state files)


- Management Subscription (Contains log analytics workspace )


---
### Pre-requisites
- Azure DevOps/Github Actions handles the execution of all deployment code
- Service principals - Service principals define application access and resources the application accesses. A service principal is created in each tenant where the application is used and references the globally unique application object. The tenant secures the service principal sign-in and access to resources

### Service principals used for each environment.

 - *sp-infra-dev* - used by the Dev pipeline to provision resources in the dev environment.
 - *sp-infra-uat* - used by the UAT pipeline to provision resources in the uat environment.
 - *sp-infra-prod* - used by the Prod pipeline to provision resources in the prod environment.
 - *sp-infra-global* - Utilized by the ms-entra-id-sp-pipelines to provision AD Groups/Service principals and to allocate the necessary roles and permissions.

MS Entra ID snippet 

![alt text](/img/image-8.png)


### If Using Azure DevOps 

The above Service principals are managed in the Azure DevOps Library as variable groups, with each environment pipeline assigned its own dedicated service principal.

**Note** - Variable groups store values and secrets that you want to be passed into a YAML pipeline or make available across multiple pipelines. You can share and use variable groups in multiple pipelines in the same project.

- sp-tkr-infra-dev = dev-data-infra-vg
- sp-tkr-infra-uat = uat-data-infra-vg
- sp-tkr-infra-prod = prod-data-infra-vg
- sp-infra-global = ms-entra-id-sp-vg

![alt text](/img/image-6.png)


Azure DevOps Environments have been set up to facilitate approval processes during deployments to UAT and PROD.

![alt text](/img/image-7.png)


### If Using Github Actions  

The above Service principals are managed in the Azure DevOps Library as variable groups, with each environment pipeline assigned its own dedicated service principal.

**Note** - Variable groups store values and secrets that you want to be passed into a YAML pipeline or make available across multiple pipelines. You can share and use variable groups in multiple pipelines in the same project.

- sp-infra-dev = dev-data-infra-vg
- sp-infra-uat = uat-data-infra-vg
- sp-infra-prod = prod-data-infra-vg
- sp-infra-global = ms-entra-id-sp-vg

![alt text](/img/image-6.png)


Azure DevOps Environments have been set up to facilitate approval processes during deployments to UAT and PROD.

![alt text](/img/image-7.png)


---

### Repo Structure 

```
infrastructure/
├── envs/
│   ├── dev/
│   │   └── dev.tfvars
│   ├── uat/
│   │   └── uat.tfvars
│   └── prod/
│       └── prod.tfvars
├── modules/
│   └── my_module/
│       ├── main.tf
│       ├── outputs.tf
│       ├── variables.tf
├── main.tf
├── provider.tf
├── sharedresources.tf
└── backend.tf

```

The repository structure is designed to facilitate a three-stage automated deployment while maintaining a modular architecture. Each module is defined once and parameterized against environment-specific tfvars files that target the development (dev), user acceptance testing (uat), and production (prod) environments.

The `sharedresources.tf` file contains resources shared across all three environments, such as Azure Private DNS, the Connectivity Resource Group, and VNet peering. The decision to separate shared resources from environment-specific ones is based on how Terraform manages and targets different subscriptions.

When extending the codebase, please consider the structure and methodology. This approach ensures that new DevOps engineers can easily comprehend the code and maintain it effectively.

---

## Modules and why a modular achitecture

A modular architecture ensures the extensibility of your codebase without impacting the core structure. It abstracts details within the child modules, hiding complexities and making the codebase easier to maintain.

Hashicorp has a very good article on why they recommend modules - https://developer.hashicorp.com/terraform/tutorials/modules/module 

The provided code is a Terraform configuration used to deploy various Azure services and resources. Each code block is responsible for provisioning a specific component or setting up infrastructure, following a modular approach. Here is a summary of each section:

---

### 1. **Deploy Resource Groups**
```hcl
module "dp-resourcegroup" {
  source      = "./modules/resourcegroups"
  rg-name     = var.rg-name
  rg-location = var.rg-location
  tags        = var.tags
}
```
- **Purpose**: Creates an Azure Resource Group.
- **Details**: Uses variables for the resource group name, location, and tags to manage and organize other resources.

---

### 2. **Deploy Virtual Networks and Subnets**
```hcl
module "dp-vnet" {
  source = "./modules/vnet"
  virtual_network_name          = var.vnet-name
  resource_group_name           = module.dp-resourcegroup.rg-name
  location                      = module.dp-resourcegroup.rg-location
  virtual_network_address_space = var.vnet-address-prefixes
  subnets = {
    "snet-01" = { /* subnet configuration */ },
    "snet-02" = { /* subnet configuration */ },
    "snet-03" = { /* subnet configuration */ }
  }
  depends_on = [module.dp-resourcegroup]
}
```
- **Purpose**: Sets up an Azure Virtual Network (VNet) with multiple subnets.
- **Details**: Uses variables for VNet and subnet names and address prefixes, linking to the resource group.

----

### 3. **Deploy Route Tables**
```hcl
module "route_table_gateway_subnet" {
  source              = "./modules/routetables"
  name                = var.rt-name
  resource_group_name = var.rg-name
  location            = var.rg-location
  routes = [
    { name = "Fw-dg", address_prefix = "0.0.0.0/0", next_hop_type = "VirtualAppliance", next_hop_in_ip_address = "10.210.0.4" }
  ]
  disable_bgp_route_propagation = false
  subnet_ids                    = [module.dp-vnet.vnet_subnet_id[0], module.dp-vnet.vnet_subnet_id[1], module.dp-vnet.vnet_subnet_id[2]]
  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}
```
- **Purpose**: Configures route tables and associates them with subnets.
- **Details**: Defines custom routes to direct network traffic, linking to subnets in the VNet.
---

### 4. **Deploy Azure SQL Database**
```hcl
module "mssql-server" {
  source = "./modules/mssql-db"
  rg-name                              = var.rg-name
  rg-location                          = var.rg-location
  sqlserver_name                       = var.sqlserver-name
  database_name                        = var.sqldb
  sqldb-sku-name                       = var.sqldb-sku-name
  log_analytics_workspace_id           = data.azurerm_log_analytics_workspace.tpk-logging.id
  azuread_administrator_login_username = var.azuread_administrator_login_username
  object_id                            = var.object_id
  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}
```
- **Purpose**: Provisions an Azure SQL Database.
- **Details**: Sets up a SQL server with specified parameters and links it to a Log Analytics workspace for monitoring.

---

### 5. **Deploy Azure Data Lake Storage**
```hcl
module "data-lake-gen2" {
  source = "./modules/datalake"
  region                           = var.rg-location
  resource_group_name              = var.rg-name
  storage_account_name             = var.data-lake-storage-name
  storage_account_replication_type = var.storage_account_replication_type
  blob_soft_delete_retention_days  = var.blob_soft_delete_retention_days
  datalake-diag-name               = var.datalake-diag-name
  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}
```
- **Purpose**: Creates an Azure Data Lake Storage account.
- **Details**: Configures storage account parameters and sets retention policies for deleted blobs.

---

### 6. **Deploy Azure Data Factory**
```hcl
module "tpk-adf" {
  source = "./modules/datafactory"
  name        = var.adf-name
  rg-name     = var.rg-name
  rg-location = var.rg-location
  adf_diag_name         = var.adf_diag_name
  ado_git_configuration = var.ado_git_configuration
  env                   = var.env
  managed_private_endpoint = [
    { name = "datalake", target_resource_id = module.data-lake-gen2.storage_account_id, subresource_name = "blob" },
    { name = "sqlserver", target_resource_id = module.mssql-server.sql_server_id, subresource_name = "sqlServer" },
    { name = "kvvault", target_resource_id = module.key-vault.key_vault_id, subresource_name = "vault" }
  ]
  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}
```
- **Purpose**: Sets up an Azure Data Factory.
- **Details**: Configures Data Factory and creates managed private endpoints to connect securely to other services like Data Lake and SQL Server.

---

### 7. **Deploy Private Endpoints and Private DNS**
```hcl
module "sql-server-private-endpoint" {
  source = "./modules/private-endpoint"
  pe_resource_group_name = var.rg-name
  private_endpoint_name  = var.sql-server-private-endpoint
  subresource_names      = ["sqlServer"]
  endpoint_resource_id   = module.mssql-server.primary_sql_server_id
  pe_subnet_id           = module.dp-vnet.vnet_subnet_id[0]
  location               = var.rg-location
  private_ip_address     = var.sql_server_private_ip_address
  member_name            = var.sql_server_member_name
  subresource_name       = var.sql_server_subresource_name
  dns = {
    zone_ids  = [module.dns.dns_zone_ids[2]]
    zone_name = var.dns_zone_names[2]
  }
  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}

module "datalake-private-endpoint" {
  source = "./modules/private-endpoint"
  pe_resource_group_name = var.rg-name
  private_endpoint_name  = var.datalake-private-endpoint
  subresource_names      = ["blob"]
  endpoint_resource_id   = var.datalake-endpoint-id
  pe_subnet_id           = module.dp-vnet.vnet_subnet_id[0]
  location               = var.rg-location
  private_ip_address     = var.datalake_private_ip_address
  member_name            = var.datalake_member_name
  subresource_name       = var.datalake_subresource_name
  dns = {
    zone_ids  = [module.dns.dns_zone_ids[1]]
    zone_name = var.dns_zone_names[1]
  }
  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}

module "datafactory-private-endpoint" {
  source = "./modules/private-endpoint"
  pe_resource_group_name = var.rg-name
  private_endpoint_name  = var.datafactory-private-endpoint
  subresource_names      = ["dataFactory"]
  endpoint_resource_id   = module.tpk-adf.data_factory_id
  pe_subnet_id           = module.dp-vnet.vnet_subnet_id[0]
  location               = var.rg-location
  private_ip_address     = var.datafactory_private_ip_address
  member_name            = var.datafactory_member_name
  subresource_name       = var.datafactory_subresource_name
  dns = {
    zone_ids  = [module.dns.dns_zone_ids[3]]
    zone_name = var.dns_zone_names[3]
  }
  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}

module "datafactory-portal-private-endpoint" {
  source = "./modules/private-endpoint"
  pe_resource_group_name = var.rg-name
  private_endpoint_name  = var.datafactory-portal-private-endpoint
  subresource_names      = ["portal"]
  endpoint_resource_id   = module.tpk-adf.data_factory_id
  pe_subnet_id           = module.dp-vnet.vnet_subnet_id[0]
  location               = var.rg-location
  private_ip_address     = var.datafactory_portal_private_ip_address
  member_name            = var.datafactory-portal_member_name
  subresource_name       = var.datafactory-portal_subresource_name
  dns = {
    zone_ids  = [module.dns.dns_zone_ids[4]]
    zone_name = var.dns_zone_names[4]
  }
  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}

module "webapp-private-endpoint" {
  source = "./modules/private-endpoint"
  pe_resource_group_name = var.rg-name
  private_endpoint_name  = var.webapp-private-endpoint
  subresource_names      = ["sites"]
  endpoint_resource_id   = module.appservices.app_service_id
  pe_subnet_id           = module.dp-vnet.vnet_subnet_id[2]
  location               = var.rg-location
  private_ip_address     = var.webapp_private_ip_address
  member_name            = var.webapp_member_name
  subresource_name       = var.webapp_subresource_name
  dns = {
    zone_ids  = [module.dns.dns_zone

_ids[0]]
    zone_name = var.dns_zone_names[0]
  }
  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}

module "dns" {
  source = "./modules/private-dns-zone"
  dns_zone_name   = var.dns_zone_name
  resource_group_name = var.rg-name
  location        = var.rg-location
  depends_on      = [module.dp-resourcegroup]
}
```
- **Purpose**: Creates private endpoints for secure communication and associates them with private DNS zones.
- **Details**: Configures private connectivity for services like SQL Server, Data Lake, Data Factory, and Web Apps, enabling them to be accessed privately within the VNet.

---

### 8. **Deploy Log Analytics Workspace**
```hcl
module "log_analytics" {
  source                        = "./modules/log-analytics"
  workspace_name                = var.log-analytics-wspace-name
  resource_group_name           = var.rg-name
  location                      = var.rg-location
  sku                           = "PerGB2018"
  local_authentication_disabled = true
  retention_in_days             = var.retention_in_days
  depends_on = [module.mssql-server]
}
```
- **Purpose**: Sets up an Azure Log Analytics workspace.
- **Details**: Configures a workspace for collecting and analyzing telemetry data, essential for monitoring and diagnostics.

---

### 9. **Deploy Azure Key Vault**
```hcl
module "key-vault" {
  source = "./modules/keyvault"
  key_vault_name             = var.kv-name
  key_vault_sku_pricing_tier = var.kv-sku
  location                   = var.rg-location
  resource_group_name        = var.rg-name
  enable_purge_protection = false
  keyvault_reader_group_names             = var.keyvault_reader_group_names
  keyvault_reader_service_principal_names = var.keyvault_reader_service_principal_names
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Allow"
    ip_rules = []
    virtual_network_subnet_ids = []
  }
  depends_on = [module.dp-resourcegroup]
}
```
- **Purpose**: Deploys an Azure Key Vault.
- **Details**: Creates a vault for securely storing and managing sensitive information such as secrets, keys, and certificates.

---

### 10. **Deploy Azure App Service**
```hcl
module "appservices" {
  source              = "./modules/app-service"
  app-service-name    = var.app-service-name
  service-plan-name   = var.app-service-plan-name
  os-type             = var.os-type
  app-service-skuname = var.app-service-skuname
  resource-group-name = var.rg-name
  location            = var.rg-location
  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}
```
- **Purpose**: Sets up an Azure App Service.
- **Details**: Configures a web app with the specified service plan, facilitating web application deployment and management.

---

## Git branching strategy

In this project, we used the trunk-based development strategy as it works well with CI/CD pipelines to ensure frequent integration and deployment. 

### Integration and Deployment Practices

- **Continuous Integration/Continuous Deployment (CI/CD):** Strategies like trunk-based development work well with CI/CD to ensure frequent integration and deployment.
- **Manual vs. Automated Deployment:** With automated systems, it is prudent to maintain fewer branches to simplify and streamline the deployment process.

Other factors that can be used to determine the best branching strategy.

- https://dev.to/angelotheman/git-branching-strategies-for-devops-best-practices-for-collaboration-35l8 



### Common Git Branching Strategies that can be used**

  - Trunk-Based Development: Simplifies workflow with fewer branches and frequent commits to the main branch.

  - GitFlow: Provides a robust structure with separate branches for features, releases, and hotfixes.

  - GitHub Flow: A lightweight approach with a focus on continuous integration and deployment.

  - Feature Branch Workflow: Encourages the use of feature branches for individual features and bug fixes.

### Conclusion

Selecting a Git branching strategy involves balancing various factors such as team size, project complexity, release cadence, and integration practices. The chosen strategy should align with your development and deployment goals, facilitate collaboration, and maintain code integrity.

---

## Testing Terraform Code - Strategies and Tools

As with any code, there are different testing strategies that can be used to help validate code and ensure that changes do not cause any unexpected issues or break existing functionality.

In this project, these are the tests that were done on the infrastructure.


**Integration testing**  - Integration testing involves testing your entire infrastructure configuration, including any dependencies on other resources, to ensure that they work together correctly. Terraform has built-in dependency mapping and management that can be utilized to make sure the changes being made are as expected.

The following tools have been used in the pipeline CI workflow, and collectively they form Integration Testing:

Terraform fmt — to format the code correctly.
Terraform validate — to verify the syntax.
Terraform plan — to verify the config file will work as expected.

**Unit testing** - Unit testing involves testing individual modules or resources in isolation to ensure that they work as expected. This done using Terraform’s built-in testing functionality.


**End-to-end (E2E) testing** - End-to-end testing involves testing your infrastructure configuration in a production-like environment to ensure that it works as expected in a real-world scenario. This test was perfomed manually in all 3 environments.


**Linting** - In the Terraform context, linting refers to the process of analyzing code to detect syntax errors, enforce style guidelines, and identify potential issues before doing an actual terraform plan. This step is crucial for maintaining code quality and consistency, and it enhances collaboration. 

Terraform fmt: This is a built-in Terraform command that was used in the CI pipelines. The command formats your Terraform code based on a set of standard formatting rules.

Command Usage - #terraform fmt -check and terraform validate to format and validate the correctness of your Terraform configuration.

NB - Different tests can be applied using 3rd party tools depending on use case. 

---

## Continous Intergration, Development & Deployment Pipelines (CI/CD) & Pipeline Structure

**Note: The Dev-infra-tf-init-plan-deploy pipeline is the ONLY pipeline configured to detect changes and automatically execute the pipeline. The UAT and PROD pipelines are executed manually.**

![alt text](/img/image-5.png)

**Note: Approvals are required to deploy to UAT and PROD.**

![alt text](/img/image-4.png)

### Pipelines Sources - Folders have been created to isolate different pipelines. 

---

### Dev-infra-pipelines-ONLY:
- **DEV-infra-tf-destroy**: This pipeline is primarily used during the development phase to tear down and iterate on the modules and resource deployments. It allows developers to make rapid changes and test different configurations without long-term consequences.
  
- **Dev-infra-tf-ini-plan-deploy**: The primary pipeline for setting up and deploying the DEV environment. It handles initialization, planning, and deployment of infrastructure in the development stage. Essential for testing new configurations before they are pushed to higher environments.

![alt text](/img/image.png)

---

### Uat-infra-pipelines-ONLY:
- **UAT-infra-tf-destroy**: Used for dismantling the UAT environment infrastructure. This is helpful for cleaning up resources after testing or before new test cycles to ensure a fresh environment.

- **UAT-infra-tf-ini-plan-deploy**: The core pipeline for UAT environment deployment. It initiates, plans, and deploys infrastructure changes specifically for the User Acceptance Testing phase. Crucial for validating the functionality and performance of configurations in a controlled setting.

![alt text](/img/image-1.png)

---
### Prod-infra-pipelines-ONLY:
- **PROD-infra-tf-destroy**: Designed for use in exceptional cases where production infrastructure needs to be safely dismantled. It should be used with caution as it impacts live environments.

- **PROD-infra-tf-ini-plan-deploy**: The main pipeline for deploying and updating production environment infrastructure. This pipeline ensures that changes are planned and applied systematically to avoid disruptions in live environments. It is used for deploying final, thoroughly tested configurations.

![alt text](/img/image-2.png)
---
### MS-Entra-ID-sp-ONLY:
- **ms-entra-sp-tf-plan**: This pipeline is responsible for planning the changes to the Azure Entra ID (formerly known as Azure AD) service principal configurations. It helps in previewing changes and ensuring they are correct before any modifications are applied.

- **ms-entra-sp-tf-apply**: Used to apply the planned changes to Azure Entra ID service principals. It deploys the configurations that have been reviewed and approved, ensuring proper management and access control for services.

- **ms-entra-sp-tf-destroy**: This pipeline handles the deletion of Azure Entra ID service principals, Azure AD groups and role assignments configurations. It is used for cleaning up or removing outdated or unnecessary service principals, helping maintain a clean and secure identity environment.

![alt text](/img/image-3.png)



## Note - The pipelines in the "MS-Entra-ID-sp-ONLY" folder depend on the dev, uat, and prod infrastructure pipelines. This is because the role assignments for Service Principals, Groups, and Azure Resources have to be applied for existing resources.

---