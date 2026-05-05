project_name       = "sunsetapi"
environment        = "prod"
location           = "westeurope"
min_replicas       = 1
max_replicas       = 10
log_retention_days = 90
# image_tag is required and injected by CI as TF_VAR_image_tag=<git-tag>
