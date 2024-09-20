# Criando a conta do Cosmos DB com a API do MongoDB
resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                 = local.cosmosdb.account_name
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  offer_type           = "Standard"
  kind                 = local.cosmosdb.kind # Especifica o uso da API do MongoDB
  mongo_server_version = "4.2"

  free_tier_enabled = true

  consistency_policy {
    consistency_level = "Session"
    # Valores: BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix.
  }

  # Configuração de GEO Localização
  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }

  automatic_failover_enabled = true

  dynamic "capabilities" {
    for_each = local.cosmosdb.capabilities
    content {
      name = capabilities.value
    }
  }

  tags = local.tags
}

# Criando os bancos de dados dentro da conta CosmosDB com API do MongoDB
resource "azurerm_cosmosdb_mongo_database" "mongo_db" {
  for_each            = { for db in local.cosmosdb.databases : db.db_name => db }
  name                = each.value.db_name
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
}

# Criando coleções para cada banco de dados com base no nome
resource "azurerm_cosmosdb_mongo_collection" "collection" {
  for_each = {
    for item in
    flatten([for db in local.cosmosdb.databases :
      [for collection in db.collections :
        {
          db_name         = db.db_name
          collection_name = collection
        }
      ]
    ])
  : "${item.db_name}_${item.collection_name}" => item }

  name                = each.value.collection_name
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  database_name       = azurerm_cosmosdb_mongo_database.mongo_db[each.value.db_name].name

  throughput = 500 # Ajuste de throughput conforme necessidade
}

output "cosmosdb" {
  value     = azurerm_cosmosdb_account.cosmosdb.primary_mongodb_connection_string
  sensitive = true
}