# Example values for the `dev` environment.
# Replace placeholder names with values that are valid in your Azure
# subscription. Do NOT commit subscription IDs, tenant IDs, client IDs,
# or any secrets.

location              = "westeurope"
resource_group_name   = "rg-brasov-sunset-dev"
app_service_plan_name = "asp-brasov-sunset-dev"
app_service_name      = "app-brasov-sunset-dev-REPLACE"
environment           = "dev"
owner                 = "platform-team"
project               = "brasov-sunset-api"
node_version          = "20-lts"
sku_name              = "B1"
