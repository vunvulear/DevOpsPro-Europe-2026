Add basic operational readiness documentation for this Azure App Service golden path.

Create:

`platform/docs/operational-readiness.md`

Document:
- expected health endpoint
- expected smoke tests
- what to check after deployment
- where logs would be viewed in Azure App Service
- basic rollback considerations
- future improvement: structured logging
- future improvement: Application Insights
- future improvement: OpenTelemetry
- future improvement: alerts and SLOs

Do not add a full observability stack.
Do not require cloud services beyond Azure App Service.
Keep the document practical and short.

Also update README with a short “Operational readiness” section.

After making changes, summarize:
- docs added
- operational expectations
- what is intentionally simplified