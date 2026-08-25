# Portal App API Contract


> Product: Portal App  
> Status: Implementation baseline  
> Version: 0.1  
> Last reviewed: 2026-08-24  
> Technical owner: Backend, Integration & Platform Engineer  
> Mobile reviewer: Mobile UI/UX & Product Experience Engineer  
> Security/Architecture approval: TBD


## Conventions

- Base path: `/api/v1`.
- HTTPS only.
- JSON requests and responses.
- Bearer authentication for protected resources.
- Problem Details for errors.
- Correlation ID returned as `traceId` and response header.
- UTC timestamps in ISO 8601.
- Stable Portal App IDs, never internal SharePoint IDs.
- Pagination uses opaque continuation tokens.
- State-changing retryable operations require `Idempotency-Key`.

## Initial endpoints

| Method | Route | Purpose |
|---|---|---|
| GET | `/me` | Current employee profile |
| GET | `/home` | Dashboard aggregation |
| GET | `/services` | Service catalog |
| GET | `/announcements` | Announcement feed |
| GET | `/requests` | Employee requests |
| GET | `/requests/{id}` | Request details and timeline |
| POST | `/requests/leave` | Submit leave request |
| POST | `/requests/permission` | Submit permission request |
| POST | `/requests/{id}/cancel` | Cancel eligible request |
| GET | `/approvals` | Approver inbox |
| POST | `/approvals/{id}/approve` | Approve eligible request |
| POST | `/approvals/{id}/reject` | Reject with reason |
| GET | `/leave-balances` | Authorized balances |
| GET | `/attendance` | Authorized attendance/shift summary |
| GET | `/payroll-documents` | Authorized payroll metadata |
| POST | `/incidents` | Submit incident or near miss |
| POST | `/files` | Protected attachment upload |
| POST | `/devices` | Register push token |

## Standard problem types

Validation, unauthorized, forbidden, not found, conflict, throttled, dependency unavailable, file rejected, and unexpected internal error.

## Security

The server performs resource authorization, server validation, ownership checks, masking, audit, and sensitive-data redaction. The mobile app must not infer authorization from UI state.
