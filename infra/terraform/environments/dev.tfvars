# Dev environment values for the live demo.
# Replace <placeholders> before running. App Service names must be globally unique.

location              = "westeurope"
resource_group_name   = "rg-brasov-sunset-dev"
app_service_plan_name = "asp-brasov-sunset-dev"
app_service_name      = "app-brasov-sunset-dev-<unique-suffix>"
environment           = "dev"
owner                 = "platform-team"
project               = "brasov-sunset-api"
node_version          = "20-lts"
sku_name              = "B1"
