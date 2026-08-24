# Portal App Software Design Document


> Product: Portal App  
> Status: Implementation baseline  
> Version: 0.1  
> Last reviewed: 2026-08-24  
> Technical owner: Backend, Integration & Platform Engineer  
> Mobile reviewer: Mobile UI/UX & Product Experience Engineer  
> Security/Architecture approval: TBD


## 1. System context

Portal App is the employee-facing client. Microsoft Entra ID provides organizational identity. The protected ASP.NET Core API provides stable mobile contracts and enforcement. Microsoft Graph is the approved Microsoft 365 integration surface. SharePoint remains the initial enterprise content and workflow store.

## 2. Logical components

```text
Mobile Presentation -> Mobile State/Domain -> Mobile Repositories -> HTTPS API
API Controllers -> Application Commands/Queries -> Domain Rules -> Infrastructure Adapters
Infrastructure -> Microsoft Graph -> SharePoint / approved enterprise systems
```

## 3. Mobile design

- `app`: bootstrap, configuration, localization, theme, deep links, and routing.
- `core`: auth, network, secure storage, cache, privacy, telemetry, files, errors, and shared widgets.
- `features`: independent data/domain/presentation slices.
- Riverpod coordinates state; GoRouter coordinates five-destination navigation; Dio calls the API.
- Arabic-first RTL is applied at application level and verified per screen.

## 4. Backend design

- `PortalApp.Api`: transport and enforcement edge.
- `PortalApp.Application`: use cases and mobile-safe contracts.
- `PortalApp.Domain`: business rules independent from external systems.
- `PortalApp.Infrastructure`: Graph, SharePoint, files, notifications, persistence, and telemetry.

Dependency direction:

```text
Api -> Application
Api -> Infrastructure
Infrastructure -> Application
Application -> Domain
Infrastructure -> Domain
Domain -> no outer project
```

## 5. Primary data flow

1. Employee initiates sign-in.
2. MSAL performs authorization code flow with PKCE.
3. Portal App receives delegated token and calls the protected API.
4. API validates identity, scope/role, resource ownership, and input.
5. Application layer executes command or query.
6. Infrastructure calls Graph and approved enterprise services.
7. API returns a mobile-safe DTO.
8. Portal App renders and caches only approved fields.

## 6. Request submission design

- Mobile form validates usability constraints.
- API validates authoritative business rules.
- Client sends an idempotency key.
- Backend persists through Graph/SharePoint and starts the approved workflow.
- The result contains a stable Portal App request identifier and status.
- Retry returns the original idempotent result or a safe conflict.

## 7. Security design

- Mobile is an untrusted public client.
- No client secrets in Flutter.
- TLS for all network communication.
- Secure platform token storage.
- Backend resource authorization.
- Least-privilege Graph permissions.
- Privacy-safe logs and push payloads.
- File validation and malware-scanning boundary.
- Internal enterprise identifiers remain server-side.

## 8. Failure design

- Expired token: silent renewal, then interactive sign-in.
- Offline: approved cache and queued safe operations only.
- Graph throttling: bounded retry with provider guidance.
- Dependency failure: safe Problem Details and correlation ID.
- Unauthorized resource: no existence disclosure.
- Duplicate command: idempotent response.

## 9. Persistence and caching

Drift stores approved mobile cache and drafts. Credentials use secure storage. Backend persistence is optional and introduced only for idempotency, distributed cache, audit, operational state, or integration needs.

## 10. Notifications

Backend or approved automation emits safe event notifications. The app opens an authenticated deep link and refreshes protected data from the API.

## 11. Deployment

Mobile binaries are distributed through approved Android/iOS channels. API is hosted in approved Azure infrastructure using managed identity, Key Vault, Application Insights, and environment separation. Exact topology remains TBD.

## 12. Design constraints

- iOS builds require macOS and Xcode.
- SharePoint schema and workflows require discovery.
- Mobile contracts must remain stable despite enterprise schema changes.
- Accessibility and RTL are release gates.
