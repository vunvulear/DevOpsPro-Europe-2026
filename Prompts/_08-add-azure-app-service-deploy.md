Add a GitHub Actions workflow to deploy the existing Node.js app to Azure App Service.

Create:

`.github/workflows/deploy-azure-app-service.yml`

Target:
Azure App Service for Node.js.

Workflow requirements:
- use `workflow_dispatch` manual trigger
- use GitHub Actions OIDC for Azure login
- build/package the app from `App/`
- deploy using the official Azure Web Apps deploy action
- include a post-deployment smoke test against `/` and `/sunset` if an app URL is provided
- keep the workflow safe for a public repo

Use placeholders or GitHub variables/secrets for:
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_WEBAPP_NAME`
- `AZURE_RESOURCE_GROUP`
- `AZURE_WEBAPP_URL`

Do not:
- use hardcoded Azure credentials
- use publish profiles by default
- deploy on every push unless clearly documented as optional
- add unnecessary complexity

Also create:

`platform/docs/deployment-path.md`

Explain:
- how deployment works
- how OIDC auth is expected to be configured
- what variables/secrets are required
- how smoke testing works
- what is simplified for the demo

After making changes, summarize:
- files changed
- variables/secrets required
- how to trigger deployment
- how to validate deployment