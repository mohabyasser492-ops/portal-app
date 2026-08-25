# Threat Model

## Assets
Identity tokens, employee profile, requests, approvals, payroll metadata/documents, attendance, incidents, attachments, audit data, and enterprise configuration.

## Threats and controls

- Token theft: secure storage, PKCE, Conditional Access, short-lived tokens.
- Broken access control: server resource authorization and negative tests.
- Over-privileged Graph access: least privilege and permission review.
- Sensitive logging: redaction, allowlists, and security tests.
- Notification leakage: safe references only.
- Malicious files: type/size/MIME validation and malware scanning.
- Offline exposure: approved cache, expiry, logout clearing, device policies.
- Duplicate/replay: idempotency and bounded retry.
- Schema manipulation: API mapping validation and monitored changes.


> Product: Portal App  
> Status: Implementation baseline  
> Version: 0.1  
> Last reviewed: 2026-08-24  
> Technical owner: Backend, Integration & Platform Engineer  
> Mobile reviewer: Mobile UI/UX & Product Experience Engineer  
> Security/Architecture approval: TBD
