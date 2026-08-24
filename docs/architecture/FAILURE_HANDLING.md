# Portal App Failure Handling


> Product: Portal App  
> Status: Implementation baseline  
> Version: 0.1  
> Last reviewed: 2026-08-24  
> Technical owner: Backend, Integration & Platform Engineer  
> Mobile reviewer: Mobile UI/UX & Product Experience Engineer  
> Security/Architecture approval: TBD


| Failure | Required behavior |
|---|---|
| Expired token | Silent renewal, then interactive sign-in |
| Offline | Approved cache and safe queued operations only |
| Validation | Field-level Problem Details |
| Unauthorized | No restricted-resource existence disclosure |
| Graph throttling | Bounded retry using provider guidance |
| SharePoint failure | Safe dependency error and correlation ID |
| Duplicate command | Original idempotent result or safe conflict |
| Notification failure | Preserve business transaction; retry event delivery |
| File threat | Reject/quarantine and write privacy-safe audit event |
| Telemetry outage | Business operation continues where safe; local secrets never logged |
