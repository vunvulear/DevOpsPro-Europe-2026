Add a Terraform structure for deploying this existing Node.js app to Azure App Service.

Create:

`infra/terraform/`

With files:
- `versions.tf`
- `providers.tf`
- `main.tf`
- `variables.tf`
- `outputs.tf`
- `environments/dev.tfvars`
- `README.md`

Target:
Azure App Service for Node.js on Linux.

Terraform should define:
- Resource Group
- Linux App Service Plan
- Linux Web App
- Node.js runtime configuration
- app settings
- tags
- output for the web app URL

Use variables for:
- `location`
- `resource_group_name`
- `app_service_plan_name`
- `app_service_name`
- `environment`
- `owner`
- `project`
- `node_version`
- `sku_name`

Constraints:
- do not add credentials
- do not hardcode subscription IDs, tenant IDs, or client IDs
- keep state local for demo simplicity
- document that real projects should use remote state
- keep the Terraform easy to read live

Also create:

`platform/docs/iac-standards.md`

Explain:
- why IaC is part of the golden path
- what is standardized
- what developers can customize
- what is simplified for the demo

After making changes, summarize:
- files added
- resources defined
- variables needed
- how to validate Terraform locally