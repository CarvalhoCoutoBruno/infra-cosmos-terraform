locals {
  resource_group_name = "skina-lanches-db-rg"
  location            = "East US2"
  subscription_id     = "dd1b3041-17d1-49c4-854c-696224d72fb5"
  tenant_id           = "39eafb87-49d3-46eb-82b1-867b38750ebe"

  cosmosdb = {
    account_name = "skina-cosmos"
    kind         = "MongoDB" # Outras opções: GlobalDocumentDB (SQL) e Parse
    capabilities = [
      "DisableRateLimitingResponses",
      "EnableAggregationPipeline",
      "EnableServerless",
      "mongoEnableDocLevelTTL",
      "EnableMongo",
      "MongoDBv3.4",
      "EnableMongoRetryableWrites"
    ]
    # Definição dos bancos de dados e suas coleções
    databases = [
      {
        db_name     = "skina-db"
        collections = ["skina-data"]
      }
    ]
  }
  tags = jsondecode(file("./tags.json"))
}