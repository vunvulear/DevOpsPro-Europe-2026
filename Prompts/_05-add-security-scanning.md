Add basic security scanning to this repository.

Create:

`.github/workflows/security.yml`

The workflow should be public-repo friendly and demo-friendly.

Include practical checks such as:
- dependency audit for Node.js
- secret scanning with Gitleaks
- filesystem or dependency scanning with Trivy
- clear placeholders for future IaC scanning with Checkov, if Terraform is not available yet

Do not require:
- paid tools
- cloud credentials
- secrets
- private tokens

Also create:

`platform/docs/security-guardrails.md`

Explain:
- what checks run
- why they are part of the golden path
- what developers should do when a check fails
- what is intentionally simplified for the demo

If any check is likely to be noisy or fragile, configure it safely and document the trade-off.

After making changes, summarize:
- files added or changed
- checks included
- how to run/validate them
- any assumptions made