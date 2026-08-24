# Portal App Deployment Model


> Product: Portal App  
> Status: Implementation baseline  
> Version: 0.1  
> Last reviewed: 2026-08-24  
> Technical owner: Backend, Integration & Platform Engineer  
> Mobile reviewer: Mobile UI/UX & Product Experience Engineer  
> Security/Architecture approval: TBD


## Environments

Development, staging, and production are isolated by configuration, secrets, telemetry, enterprise mappings, and approvals.

## Components

- Android and iOS mobile binaries.
- Azure-hosted PortalApp.Api.
- Managed identity and Key Vault.
- Application Insights and Log Analytics.
- Microsoft Graph and SharePoint Online.
- Optional approved persistence/storage.

## Release boundary

Android/iOS releases require signed artifacts, security/privacy/accessibility gates, monitoring, rollback plan, and approved environment configuration. Final Azure topology is TBD.
