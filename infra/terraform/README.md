# Terraform — Brasov Sunset API

Azure infrastructure for the Brasov Sunset API.

## Layout

```
infra/terraform/
├── bootstrap/      # One-time: remote state backend + GitHub OIDC identity
├── modules/        # Reusable building blocks
│   ├── observability/   # Log Analytics + Application Insights
│   ├── registry/        # Azure Container Registry (ACR)
│   ├── identity/        # User-assigned managed identity (runtime)
│   ├── keyvault/        # Azure Key Vault
│   └── container_app/   # Container Apps Environment + Container App
└── envs/
    ├── dev/        # Dev environment root module
    └── prod/       # Prod environment root module
```

## Cloud architecture

```
GitHub Actions ──(OIDC, no secrets)──> Azure AD App / Federated Credential
        │
        ├── docker build & push ──> Azure Container Registry (ACR)
        └── terraform apply ──> Azure Container Apps  ──> ingress (HTTPS)
                                       │
                                       ├── User-assigned MI ──> ACR pull, Key Vault read
                                       ├── App Insights / Log Analytics  (logs, metrics, traces)
                                       └── Key Vault (secrets, ref'd via secretRef)
```

## First-time bootstrap

1. Log in: `az login` and select the right subscription.
2. `cd bootstrap && terraform init && terraform apply`.
3. Save the outputs (storage account name, federated client id, tenant/subscription ids) into:
   - GitHub repository **secrets** (`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`).
   - Each `envs/<env>/backend.hcl` (storage account / container / state key per env).

## Per-env apply

```
cd envs/dev
terraform init -backend-config=backend.hcl
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

CI runs the same commands with `-input=false -no-color`.
