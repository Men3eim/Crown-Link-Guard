# Crown Link Guard

Internal phishing link protection for Crown Business Solutions Zoho Desk agents.

## What This MVP Includes

- Ruby on Rails full-stack backend with PostgreSQL.
- Token-protected extension API:
  - `GET /api/v1/health`
  - `POST /api/v1/scan_url`
  - `POST /api/v1/reports`
  - `POST /api/v1/actions`
- URL normalization, domain matching, risk scoring, scan logging, and audit logging services.
- Admin dashboard for scans, reports, allowlisted domains, blocked domains, settings, audit logs, and CSV export.
- Manifest V3 Chrome/Edge extension that intercepts external web links across normal browser pages before navigation.
- Seed data for the initial admin, trusted domains, risk thresholds, and extension API token.

## Local Setup

```sh
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

Default seeded credentials for development:

- Admin email: `admin@crownbs.com`
- Admin password: `ChangeMe123!`
- Extension token: `dev-extension-token-change-me`

Set these environment variables before seeding to avoid defaults:

```sh
export CROWN_LINK_GUARD_ADMIN_EMAIL="admin@crownbs.com"
export CROWN_LINK_GUARD_ADMIN_PASSWORD="replace-this-password"
export CROWN_LINK_GUARD_API_TOKEN="replace-this-token"
```

## Extension Setup

1. Open Chrome or Edge extension management.
2. Enable developer mode.
3. Load the `browser_extension` folder as an unpacked extension.
4. Open the extension popup and configure:
   - Backend URL: `http://localhost:3000` for local testing.
   - API token: the seeded or environment token.
   - Agent email/name for scan and report metadata.

The extension runs on normal `http://` and `https://` pages. It ignores same-site navigation, same-page anchors, browser UI links, `mailto:`, `tel:`, and `javascript:` controls so normal page buttons keep working. It scans outbound web links before the browser opens them.

Chrome does not allow extensions to run on protected browser pages such as `chrome://`, the Chrome Web Store, or some extension/admin pages.

Production deployment should use managed browser policy or GPO and a managed token configuration.

## Important Deployment Rule

Do not install or host Crown Link Guard on the Active Directory Domain Controller.

Use a separate internal VM or server, for example:

```text
linkguard.crownbs.local
```

Active Directory may be used for users, groups, GPO deployment, laptop management, and browser extension policy. The Rails app should live on its own internal server or VM.
