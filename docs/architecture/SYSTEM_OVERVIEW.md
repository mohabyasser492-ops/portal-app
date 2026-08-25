# Portal App System Overview


> Product: Portal App  
> Status: Implementation baseline  
> Version: 0.1  
> Last reviewed: 2026-08-24  
> Technical owner: Backend, Integration & Platform Engineer  
> Mobile reviewer: Mobile UI/UX & Product Experience Engineer  
> Security/Architecture approval: TBD


## Context

Portal App is the mobile employee experience. Entra ID authenticates users. The ASP.NET Core API enforces authorization and stable business contracts. Microsoft Graph accesses SharePoint and approved Microsoft 365 data.

## Boundary rules

- Mobile is untrusted and contains no secrets.
- API validates identity, resource access, inputs, and business rules.
- Graph/SharePoint identifiers stay behind the API.
- Only approved fields are cached locally.
- Enterprise adapters are replaceable infrastructure components.

## Main actors

Employee, Manager/Approver, Administrator, Security/IT Operator, and Operations/Support.
