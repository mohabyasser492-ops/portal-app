# ADR-008: Msal Integration


> Product: Portal App  
> Status: Implementation baseline  
> Version: 0.1  
> Last reviewed: 2026-08-24  
> Technical owner: Backend, Integration & Platform Engineer  
> Mobile reviewer: Mobile UI/UX & Product Experience Engineer  
> Security/Architecture approval: TBD


## Status

Proposed for implementation baseline.

## Decision

Use MSAL with Authorization Code Flow and PKCE; no mobile secret.

## Consequences

The decision must be enforced through code review, tests, documentation, and release gates. Tenant-specific configuration remains controlled and external to source control.
