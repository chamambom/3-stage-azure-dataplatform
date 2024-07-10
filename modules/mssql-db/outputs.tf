output "sqldb-sku-name" {
  description = "The primary Microsoft SQL Server ID"
  value       = azurerm_mssql_server.primary.name
}

output "primary_sql_server_id" {
  description = "The primary Microsoft SQL Server ID"
  value       = azurerm_mssql_server.primary.id
}

output "primary_sql_server_fqdn" {
  description = "The fully qualified domain name of the primary Azure SQL Server"
  value       = azurerm_mssql_server.primary.fully_qualified_domain_name
}

output "sql_server_admin_user" {
  description = "SQL database administrator login id"
  value       = azurerm_mssql_server.primary.administrator_login
  sensitive   = true
}

output "sql_server_admin_password" {
  description = "SQL database administrator login password"
  value       = azurerm_mssql_server.primary.administrator_login_password
  sensitive   = true
}

output "sql_database_id" {
  description = "The SQL Database ID"
  value       = azurerm_mssql_database.db.id
}

output "sql_database_name" {
  description = "The SQL Database Name"
  value       = azurerm_mssql_database.db.name
}

output "sql_server_id" {
  description = "The SQL Database Name"
  value       = azurerm_mssql_server.primary.id
}
