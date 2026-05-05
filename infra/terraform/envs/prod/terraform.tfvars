project_name       = "sunsetapi"
environment        = "prod"
location           = "westeurope"
app_service_sku    = "P1v3"
log_retention_days = 90
# app_version is required and injected by CI as TF_VAR_app_version=<git-tag>
