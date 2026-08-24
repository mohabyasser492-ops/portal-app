# RFC-0001: Portal App Transformation


> Product: Portal App  
> Status: Implementation baseline  
> Version: 0.1  
> Last reviewed: 2026-08-24  
> Technical owner: Backend, Integration & Platform Engineer  
> Mobile reviewer: Mobile UI/UX & Product Experience Engineer  
> Security/Architecture approval: TBD


## Proposal

Replace the employee-facing SharePoint page experience with Portal App, a standalone Flutter application for Android and iOS, while retaining SharePoint and Microsoft 365 as initial enterprise integrations behind a protected ASP.NET Core API.

## Problem

The current page-oriented experience mixes critical workflows with content and external links, has inconsistent Arabic/English terminology, weak mobile navigation, inconsistent RTL behavior, and insufficient mobile-specific privacy controls.

## Decision

Adopt:

```text
Flutter -> Entra ID/MSAL -> ASP.NET Core API -> Microsoft Graph -> SharePoint
```

## Alternatives considered

1. Keep SharePoint mobile web: rejected because it retains page constraints.
2. WebView wrapper: rejected because it packages rather than redesigns the experience.
3. Flutter with direct Graph access: acceptable for prototypes, rejected as the production default because validation, audit, integrations, and schema abstraction belong server-side.
4. Flutter with protected API: recommended.

## Benefits

- Professional mobile UX.
- Stable mobile-oriented API.
- Central authorization and validation.
- SharePoint schema isolation.
- Privacy-safe audit and telemetry.
- Future integration flexibility.

## Costs

- Additional API operations and infrastructure.
- Entra registrations and security review.
- Graph permission governance.
- Native Android/iOS release management.
- Discovery work for enterprise mappings.

## Migration

Discovery -> UI prototype -> authentication -> read-only integrations -> transactions -> notifications/offline -> security/release.

## Risks

Unknown schemas, excessive Graph permissions, sensitive data exposure, duplicate commands, attachment threats, iOS tooling, external system dependencies, and operational ownership.

## Decision record

- Decision status: Proposed
- Decision authority: Architecture/Product/Security Board, TBD
- Target: Approval before production integration
- Follow-up: resolve all controlled TBD values and complete sign-off checklist
