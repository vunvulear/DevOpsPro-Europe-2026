Add lightweight platform policies for the golden path.

Create:

`platform/policies/service-metadata.yaml`
`platform/policies/tagging-policy.yaml`
`platform/policies/deployment-policy.md`
`platform/policies/cost-policy.yaml`

The policies should express simple standards:
- every service has an owner
- every service has a project name
- every resource has environment, owner, and project tags
- production deployments do not run from feature branches
- App Service SKU should be intentionally selected
- cost should be visible before deployment
- smoke tests are required after deployment
- health endpoint is required

Keep policies readable and useful for a live demo.

Also create:

`platform/docs/policy-guardrails.md`

Explain:
- what a guardrail is
- why guardrails belong close to the developer workflow
- which policies are documented only
- which policies could be enforced in CI/CD later
- what is intentionally simplified

Do not create a complex enterprise governance framework.
Do not add fragile enforcement unless it is very simple.