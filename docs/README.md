# Portal App Engineering Documentation


> Product: Portal App  
> Status: Implementation baseline  
> Version: 0.1  
> Last reviewed: 2026-08-24  
> Technical owner: Backend, Integration & Platform Engineer  
> Mobile reviewer: Mobile UI/UX & Product Experience Engineer  
> Security/Architecture approval: TBD


This folder is the controlled engineering documentation set for Portal App, a standalone Arabic-first employee application for Android and iOS.

Microsoft SharePoint is retained only as an enterprise data and workflow integration behind Microsoft Graph and the protected ASP.NET Core API. SharePoint is not the product name or mobile user experience.

## Documentation areas

- `engineering`: Technical Specification, SDD, RFC, SRS, and postmortem template.
- `architecture`: System boundaries, data flow, deployment, failure handling, and ADRs.
- `api`: Mobile-safe API conventions and initial resource contract.
- `requirements`: Functional, non-functional, screen, acceptance, and traceability artifacts.
- `security`: Threat model, privacy, permissions, logging, device storage, and upload controls.
- `governance`: Decisions, risks, open decisions, reviewers, and sign-off gates.
- `operations`: Production runbooks, recovery, monitoring, escalation, and dependency handling.
- `testing`: Quality strategy across mobile, API, security, accessibility, and releases.
- `discovery`: Required enterprise mappings and questions.
- `diagrams`: Editable Mermaid sources for the 30 master diagrams.
- `branches`: Implementation order and contribution workflow.
- `ux`: Arabic terminology, research, and wireframe guidance.

## Controlled TBD policy

The following values must remain TBD until approved enterprise discovery is complete:

- Microsoft Entra tenant and application identifiers.
- Final Graph permissions and Conditional Access policies.
- SharePoint site, list, library, workflow, and internal field identifiers.
- Attachment limits, retention, data classification, and malware scanning provider.
- Payroll, attendance, HR, and SAP contracts.
- Production Azure topology, domains, signing credentials, and distribution model.
