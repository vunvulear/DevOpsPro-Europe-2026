Add a GitHub Actions workflow for Terraform validation and planning.

Create:

`.github/workflows/terraform-plan.yml`

The workflow should:
- run on pull requests and pushes to `main`
- target `infra/terraform/`
- run `terraform fmt -check`
- run `terraform init`
- run `terraform validate`
- run `terraform plan` if credentials are available

Important:
- Terraform validation should be safe for a public repo.
- Do not commit Azure credentials.
- Use Azure OIDC-ready placeholders where needed.
- If a real plan requires Azure authentication, document exactly which GitHub variables/secrets are required.
- Keep the workflow readable for a conference audience.

Also update:

`infra/terraform/README.md`

Add:
- how to run fmt/init/validate/plan locally
- what GitHub variables/secrets are needed for real Azure plan
- what is intentionally simplified

After making changes, summarize:
- workflow behavior
- what runs without secrets
- what requires Azure auth
- assumptions made