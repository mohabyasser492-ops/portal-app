# Portal App Software Requirements Specification


> Product: Portal App  
> Status: Implementation baseline  
> Version: 0.1  
> Last reviewed: 2026-08-24  
> Technical owner: Backend, Integration & Platform Engineer  
> Mobile reviewer: Mobile UI/UX & Product Experience Engineer  
> Security/Architecture approval: TBD


## 1. Purpose

Define Version 1 behavioral, quality, interface, screen, and acceptance requirements for Portal App.

## 2. User classes

- Employee: views authorized information, submits requests, tracks progress, and reads content.
- Manager/Approver: reviews and acts on eligible requests.
- Administrator: maintains approved enterprise sources and operational configuration.
- Security/IT Operator: governs identity, permissions, audit, devices, and releases.

## 3. Functional requirements

- FR-001: Support Microsoft work-account sign-in through Entra ID/MSAL.
- FR-002: Provide Arabic-first RTL home with configurable quick actions.
- FR-003: Display authorized employee profile with masking.
- FR-004: Display leave and permission balances.
- FR-005: Submit leave and permission requests.
- FR-006: Support drafts, attachments, and validation.
- FR-007: Display request history, details, and approval progress.
- FR-008: Display announcements with metadata, read state, and attachments.
- FR-009: Provide searchable categorized services.
- FR-010: Support incident and near-miss reporting.
- FR-011: Send approved privacy-safe notifications.
- FR-012: Expose only data authorized for the signed-in employee.
- FR-013: Permit eligible request cancellation.
- FR-014: Permit authorized manager decisions where approved.
- FR-015: List authorized payroll documents.
- FR-016: Display authorized attendance and shift summaries.

## 4. Non-functional requirements

- NFR-001: Shared Flutter codebase for Android and iOS.
- NFR-002: Consistent Arabic RTL navigation, typography, directions, dates, and numbers.
- NFR-003: PKCE, no mobile secrets, least privilege, and server-side authorization.
- NFR-004: Sensitive data excluded from logs, analytics, notifications, and crash reports.
- NFR-005: Status never relies on color alone.
- NFR-006: Safe caching, network handling, retry, and duplicate prevention.
- NFR-007: API hides internal enterprise implementation details.
- NFR-008: Correlation, monitoring, audit, and safe failure messages.
- NFR-009: Maintain testable clean architecture boundaries.
- NFR-010: Environment-specific configuration and controlled releases.

## 5. Screen requirements

Login, Home, My Requests, Request Form, Request Details, Services, News, Profile, Manager Approvals, Incident Reporting, Notification Center, and Settings must each support loading, empty, error, offline, and accessibility states as applicable.

## 6. External interfaces

- Microsoft Entra ID: authentication and token issuance.
- Portal App API: protected production interface.
- Microsoft Graph: SharePoint sites, lists, items, and libraries.
- Push providers: approved event delivery.
- Enterprise systems: payroll, attendance, HR, or SAP only after approved discovery.

## 7. Acceptance and traceability

Every requirement maps to an owner, branch, implementation path, security control, and test artifact in `requirements/TRACEABILITY_MATRIX.csv`.
