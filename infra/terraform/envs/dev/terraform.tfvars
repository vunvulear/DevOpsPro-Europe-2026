project_name       = "sunsetapi"
environment        = "dev"
location           = "westeurope"
min_replicas       = 0
max_replicas       = 3
log_retention_days = 30
# image_tag is normally injected by CI: TF_VAR_image_tag=<git-sha>
# deployer_principal_ids is set by CI with the GitHub OIDC SP object id.
