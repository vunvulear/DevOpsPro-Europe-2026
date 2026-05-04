#!/usr/bin/env bash
# Render a Markdown reviewer-checklist comparing chosen sku_name against
# platform/policies/cost-policy.yaml defaults. No external services, no tokens.
# Task: T8.1.

set -euo pipefail

POLICY_FILE="platform/policies/cost-policy.yaml"
ENV_DIR="infra/terraform/environments"

if [[ ! -d "$ENV_DIR" ]]; then
  echo "_No environments found under $ENV_DIR; skipping cost comment._"
  exit 0
fi

# Extract default SKU per environment from cost-policy.yaml using awk.
# Tolerant: if the file is malformed, falls back to "<unknown>".
get_default_sku() {
  local env="$1"
  awk -v env="$env" '
    /^defaults:/      { in_defaults = 1; next }
    in_defaults && $0 ~ "^  "env":" { in_env = 1; next }
    in_env && /^  [a-zA-Z]/         { in_env = 0 }
    in_env && /^    sku_name:/      { gsub(/[ "'"'"']/,"",$2); print $2; exit }
  ' "$POLICY_FILE" 2>/dev/null || true
}

{
  echo "## Cost Review Checklist"
  echo
  echo "Per-environment SKU choices vs. \`$POLICY_FILE\` defaults:"
  echo
  echo "| Env | Chosen \`sku_name\` | Policy default | Match? |"
  echo "|---|---|---|---|"

  shopt -s nullglob
  for f in "$ENV_DIR"/*.tfvars; do
    env="$(basename "$f" .tfvars)"
    chosen="$(grep -E '^[[:space:]]*sku_name[[:space:]]*=' "$f" \
              | head -n1 | sed -E 's/.*=[[:space:]]*"?([^"#]+)"?.*/\1/' \
              | tr -d '[:space:]' || true)"
    chosen="${chosen:-<missing>}"
    default="$(get_default_sku "$env")"
    default="${default:-<unknown>}"
    if [[ "$chosen" == "$default" ]]; then
      match="OK"
    else
      match="REVIEW"
    fi
    echo "| \`$env\` | \`$chosen\` | \`$default\` | $match |"
  done

  echo
  echo "### Reviewer reminders"
  awk '
    /^review_reminders:/ { in_r=1; next }
    in_r && /^[a-zA-Z]/  { in_r=0 }
    in_r && /^[[:space:]]*-/ { sub(/^[[:space:]]*-[[:space:]]*/,""); print "- [ ] "$0 }
  ' "$POLICY_FILE" 2>/dev/null || echo "- [ ] Review SKU choices against policy."
}
