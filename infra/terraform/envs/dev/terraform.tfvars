project_name       = "sunsetapi"
environment        = "dev"
location           = "westeurope"
app_service_sku    = "B1"
log_retention_days = 30
# app_version is normally injected by CI as TF_VAR_app_version=<git-sha>
# deployer_principal_ids is set by CI with the GitHub OIDC SP object id.
