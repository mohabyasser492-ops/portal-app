# Portal App Technical Specification


> Product: Portal App  
> Status: Implementation baseline  
> Version: 0.1  
> Last reviewed: 2026-08-24  
> Technical owner: Backend, Integration & Platform Engineer  
> Mobile reviewer: Mobile UI/UX & Product Experience Engineer  
> Security/Architecture approval: TBD


## 1. Objective

Portal App is a standalone employee mobile application for Android and iOS. It replaces the employee-facing SharePoint page experience with a professional Arabic-first application while retaining Microsoft 365 and SharePoint as enterprise systems behind a protected API.

## 2. Version 1 scope

- Microsoft work-account sign-in through Microsoft Entra ID and MSAL.
- Arabic-first RTL home, profile, balances, requests, approval timeline, announcements, services, payroll documents, attendance, incidents, and notifications.
- Native leave and permission forms with drafts, validation, attachments, idempotency, and status tracking.
- Approved local caching, connectivity feedback, and safe retries.
- Manager approval experience where business owners approve mobile decision actions.

## 3. Out of scope

Weather, YouTube, WhatsApp, nonessential external links, public web access, Windows desktop, and replacement of enterprise administration systems are deferred unless separately approved.

## 4. Target architecture

```text
Employee
  -> Flutter Portal App
  -> Microsoft Entra ID / MSAL / PKCE
  -> Protected ASP.NET Core API
  -> Microsoft Graph
  -> SharePoint sites, lists, items, libraries, and approved workflows
```

The mobile application is an untrusted public client. The API is the production authorization, validation, audit, integration, and contract boundary.

## 5. Technology stack

### Mobile

Flutter, Dart, Riverpod, GoRouter, Dio, Freezed, JSON Serializable, Flutter Secure Storage, Drift, Firebase Messaging, and Flutter localization.

### Backend

ASP.NET Core 8, C#, REST/JSON, Microsoft Identity platform, Microsoft Graph, OpenAPI, Problem Details, structured logging, Application Insights, and Azure infrastructure.

## 6. Backend project responsibilities

### PortalApp.Api

HTTP endpoints, authentication, authorization, versioning, Problem Details, rate limiting, correlation IDs, OpenAPI, and health endpoints.

### PortalApp.Application

Commands, queries, validation, use-case orchestration, interfaces, mobile-safe models, mappings, and idempotency contracts.

### PortalApp.Domain

Entities, value objects, lifecycle rules, approval rules, and domain invariants. This project must not depend on ASP.NET Core, Microsoft Graph, SharePoint, or infrastructure implementations.

### PortalApp.Infrastructure

Microsoft Graph, SharePoint, notifications, persistence, file scanning, external adapters, retries, observability, and sensitive-data redaction.

## 7. Authentication and authorization

- OAuth 2.0 Authorization Code Flow with PKCE.
- No mobile client secret, administrator credential, or service password.
- Tokens stored only in platform-protected storage.
- API validates every token and enforces resource-level authorization.
- Initial roles: Employee, Manager/Approver, Administrator, Security/IT Operator.
- UI hiding is not an authorization control.

## 8. Proposed API resources

```text
GET    /api/v1/me
GET    /api/v1/home
GET    /api/v1/services
GET    /api/v1/announcements
GET    /api/v1/requests
GET    /api/v1/requests/{requestId}
POST   /api/v1/requests/leave
POST   /api/v1/requests/permission
POST   /api/v1/requests/{requestId}/cancel
GET    /api/v1/approvals
POST   /api/v1/approvals/{approvalId}/approve
POST   /api/v1/approvals/{approvalId}/reject
GET    /api/v1/leave-balances
GET    /api/v1/attendance
GET    /api/v1/payroll-documents
POST   /api/v1/incidents
POST   /api/v1/files
POST   /api/v1/devices
GET    /health
```

Internal SharePoint identifiers must never be exposed to the mobile client.

## 9. Error contract

The API uses RFC-compatible Problem Details with a correlation `traceId`. Production responses must not contain stack traces, tokens, credentials, internal paths, SharePoint identifiers, or sensitive employee data.

## 10. Validation and idempotency

The app provides immediate field validation; the API performs authoritative validation. Retryable state-changing commands require idempotency keys to prevent duplicate records.

## 11. Offline policy

Authentication tokens are separate from cached business data. Only approved summaries may be cached. Offline operations must be clearly indicated, bounded, expiring, and safe to replay.

## 12. File security

The API validates name, extension, MIME type, size, authorization, business association, and malware scan result. Final limits, types, provider, retention, and deletion policy are TBD.

## 13. Notifications

Push payloads carry safe event references only. They must not contain salary data, employee numbers, request reasons, incident descriptions, tokens, contact details, or confidential approval information.

## 14. Observability

Correlation IDs, structured logs, metrics, traces, dependency telemetry, health checks, redacted audit events, and alerts are required. Sensitive employee or credential data is prohibited in telemetry.

## 15. Testing

Flutter unit/widget/RTL/accessibility tests; backend unit/integration/architecture/security/contract/performance tests; Graph fixtures; file-policy tests; offline/replay tests; Android and iOS device tests.

## 16. Environments

Development, staging, and production have separate configuration, secrets, telemetry, enterprise mappings, notification configuration, deployment approvals, and rollback controls.

## 17. Open decisions

Tenant registrations, Graph scopes, Conditional Access, SharePoint mappings, workflow ownership, manager actions, files, retention, payroll/attendance sources, Azure topology, notifications, and distribution remain controlled TBDs.

## 18. Acceptance criteria

The product is consistently named Portal App; SharePoint is an integration; mobile and backend responsibilities are explicit; API is the protected boundary; PKCE and least privilege are used; privacy rules are enforceable; offline behavior is restricted; and all TBD values are traceable.
