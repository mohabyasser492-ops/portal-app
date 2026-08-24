# Portal App Risk Register


> Product: Portal App  
> Status: Implementation baseline  
> Version: 0.1  
> Last reviewed: 2026-08-24  
> Technical owner: Backend, Integration & Platform Engineer  
> Mobile reviewer: Mobile UI/UX & Product Experience Engineer  
> Security/Architecture approval: TBD


| Risk | Impact | Mitigation | Owner | Status |
|---|---|---|---|---|
| Unknown SharePoint schema | Rework/data errors | Discovery inventory and API abstraction | Backend | Open |
| Excessive Graph permissions | Unauthorized data exposure | Least-privilege review | Security | Open |
| Sensitive telemetry | Privacy incident | Redaction and tests | Backend/Security | Open |
| Duplicate submissions | Duplicate enterprise records | Idempotency | Backend | Planned |
| Unsafe attachments | Malware/data leakage | Validation/scanning | Backend/Security | Planned |
| Inconsistent RTL | Poor usability | Design system and RTL tests | Mobile | Planned |
| iOS tooling constraints | Release delay | Plan macOS/Xcode early | Release | Open |
| Dependency outage | Service disruption | Retry, safe failure, monitoring | Platform | Planned |
