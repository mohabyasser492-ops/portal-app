# Portal App Acceptance Criteria


> Product: Portal App  
> Status: Implementation baseline  
> Version: 0.1  
> Last reviewed: 2026-08-24  
> Technical owner: Backend, Integration & Platform Engineer  
> Mobile reviewer: Mobile UI/UX & Product Experience Engineer  
> Security/Architecture approval: TBD


## Product

- Standalone Android/iOS application, not a WebView wrapper.
- Professional Arabic-first RTL experience.
- Five stable destinations.

## Security

- Company sign-in without exposing credentials to the app.
- No client secrets or hard-coded tokens.
- API authorization and least-privilege integration.
- Sensitive data absent from logs, push bodies, analytics, and crash reports.

## Workflows

- Core read and transaction workflows function end-to-end against approved enterprise data.
- Retryable writes are idempotent.
- Request statuses use text, icon, and color.

## Quality

- Functional requirements map to tests.
- Flutter and API CI pass.
- Accessibility, RTL, privacy, security, device, release, monitoring, and rollback gates pass.
