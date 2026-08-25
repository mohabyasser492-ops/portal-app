# Portal App Data Flow


> Product: Portal App  
> Status: Implementation baseline  
> Version: 0.1  
> Last reviewed: 2026-08-24  
> Technical owner: Backend, Integration & Platform Engineer  
> Mobile reviewer: Mobile UI/UX & Product Experience Engineer  
> Security/Architecture approval: TBD


## Read flow

```text
Employee -> Portal App -> API -> Graph -> SharePoint
Employee <- Portal App <- DTO <- API <- normalized enterprise data
```

## Write flow

```text
Native form -> local validation -> API authorization/validation
-> idempotency -> Graph/SharePoint write -> workflow -> safe result
```

## Data handling

Tokens use secure storage. Approved summaries use Drift. Sensitive payloads are excluded from logs, push bodies, and analytics. Attachments pass protected upload and scanning controls.
