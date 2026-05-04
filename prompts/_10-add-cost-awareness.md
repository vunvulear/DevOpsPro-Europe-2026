Add basic cost awareness to the golden path.

Use the existing Terraform and policy structure if available.

Create or update:

`platform/policies/cost-policy.yaml`
`platform/docs/cost-awareness.md`

Optionally create:

`.github/workflows/cost-awareness.yml`

only if it can be kept simple and useful.

The cost awareness content should cover:
- App Service Plan SKU selection
- environment-specific sizing
- owner/project tags for cost allocation
- why cost should be visible before deployment
- what would be added later with tools like Infracost or Azure Cost Management

Constraints:
- do not require Infracost tokens
- do not require cloud credentials
- do not create fake cost numbers as if they are accurate
- use placeholders where appropriate
- keep this demo-friendly

After making changes, summarize:
- what was added
- what is real
- what is placeholder
- how this supports FinOps in a golden path