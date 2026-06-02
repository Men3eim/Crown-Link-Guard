# Product Requirements Document

# Crown Link Guard

## Internal Phishing Link Protection System for Zoho Desk Agents

---

## 1. Product Summary

Crown Link Guard is an internal cybersecurity tool for Crown Business Solutions. It protects customer support agents from accidentally opening phishing links inside Zoho Desk tickets.

Agents receive guest and OTA-related emails through Zoho Desk. Some phishing emails look unprofessional and obvious, but others are very professional. A phishing sender may start with a normal message, such as asking about availability, then after the agent replies, the sender may send a fake payment link, login page, file, image, or verification URL.

The goal is to create a technical protection layer that checks every link before it opens, warns or blocks the agent when needed, logs suspicious activity, and gives the agent a clear way to ask a Team Leader, senior agent, or Ahmed Moniem for verification.

The backend must be built using Ruby on Rails.

---

## 2. Product Name

Crown Link Guard

---

## 3. Business Context

Crown Business Solutions manages hotel-related customer communication. Agents work inside Zoho Desk and receive tickets from different sources, including guests, OTAs, and hotel systems.

Phishing attempts may impersonate:

- Booking.com
- Expedia
- Hotels.com
- Eviivo
- Guests
- Payment departments
- Hotel partners
- Customer support teams

The company needs a solution that works with the current workflow instead of forcing agents to change how they work.

---

## 4. Core Problem

Agents may accidentally click phishing links inside Zoho Desk tickets.

This can lead to:

- Account credential theft
- Fake OTA login pages
- Guest data exposure
- Malware downloads
- Payment fraud
- Compromised Zoho or OTA accounts
- Security incidents that affect hotel guests and business reputation

The main issue is that phishing is not always obvious. Some attacks start professionally and only become dangerous later in the conversation.

Example:

1. A sender asks:  
“Hello, do you have availability for 2 adults from Friday to Sunday?”
2. Agent replies normally.
3. The sender later replies:  
“Thank you. Please confirm the reservation details using this secure link.”
4. The link opens a fake payment, booking, or login page.

Crown Link Guard must check every new link, even if the previous conversation looked normal.

---

## 5. Main Goal

Build an internal Rails-based system that:

1. Detects links inside Zoho Desk before they open.
2. Checks if the link is safe, suspicious, high-risk, or blocked.
3. Warns agents with clear, friendly messages.
4. Blocks dangerous links.
5. Logs all scanned links.
6. Allows agents to report suspicious links to Ahmed Moniem.
7. Allows agents to ask a Team Leader or senior agent before taking action.
8. Allows admins to manage allowlisted and blocked domains.
9. Provides an admin dashboard for review and reporting.
10. Helps reduce phishing risk without slowing down normal agent work.

---

## 6. Important Technical Rule

Do not install or host this application directly on the Active Directory Domain Controller.

The Active Directory server should only be used for:

- Users
- Groups
- Domain policies
- Laptop management
- Group Policy deployment

Crown Link Guard should be hosted on a separate internal server or VM that is joined to the domain if needed.

Recommended internal hostname:

```text
linkguard.crownbs.local

```

---

## 7. Target Users

### 7.1 Customer Support Agent

Agents use Zoho Desk daily.

They need:

- Automatic link checking
- Simple warnings
- Clear instructions
- Ability to report suspicious links
- Ability to ask a Team Leader or senior agent
- No complicated technical language

---

### 7.2 Team Leader / Senior Agent

Team Leaders and senior agents help junior or new agents decide if something is safe.

They need:

- Clear link details from the agent
- Risk reasons
- Ticket URL
- Suspicious domain
- A simple way to tell the agent whether to proceed or report

---

### 7.3 Admin / Security Reviewer

Ahmed Moniem or the internal software/security team.

They need:

- Admin dashboard
- Scanned links history
- Suspicious reports
- Ability to mark reports as safe or phishing
- Allowlist/blocklist management
- Exportable logs
- Future Zoho Desk integration

---

## 8. MVP Scope

### 8.1 Included in MVP

The MVP must include:

1. Ruby on Rails backend.
2. PostgreSQL database.
3. Admin dashboard using Rails views.
4. Chrome/Edge browser extension.
5. Link detection inside Zoho Desk.
6. Link click interception before navigation.
7. URL risk scoring engine.
8. Allowlist and blocklist.
9. Warning modal for medium/high-risk URLs.
10. Complete blocking for dangerous URLs.
11. Agent report flow.
12. “Ask Team Leader / Senior Agent” helper flow.
13. Scan logs.
14. Admin reports page.
15. CSV export.
16. Simple admin login.
17. API token protection for extension API requests.
18. Seed data for trusted domains.
19. Basic deployment guide.

---

### 8.2 Not Included in MVP

The MVP does not need:

1. AI email classification.
2. Full Zoho Desk API assignment automation.
3. Attachment sandboxing.
4. Antivirus scanning.
5. Microsoft Defender integration.
6. Full Active Directory LDAP login.
7. Full EDR system.
8. Browser isolation.
9. Automatic password reset.
10. Real-time Teams/Slack alerts.

These can be added in future phases.

---

## 9. Recommended Tech Stack

### Backend

- Ruby on Rails
- PostgreSQL
- Puma
- Rails sessions
- Rails credentials or environment variables
- Service objects for URL analysis

---

### Admin Dashboard

Use standard Rails full-stack app:

- ERB views
- Hotwire / Turbo
- Stimulus
- Tailwind CSS
- Simple responsive internal UI

Do not over-engineer the dashboard.

---

### Browser Extension

- Chrome Extension Manifest V3
- TypeScript
- Content script
- Background service worker
- Modal UI injected into Zoho Desk page
- Works on Chrome and Microsoft Edge

---

### Deployment

Recommended:

- Separate internal VM
- Ubuntu Server preferred
- PostgreSQL
- Nginx reverse proxy
- HTTPS
- Internal DNS

Do not deploy on the AD Domain Controller.

---

## 10. High-Level Architecture

```text
Zoho Desk in Browser
        |
        | Agent clicks link
        v
Chrome/Edge Extension
        |
        | POST /api/v1/scan_url
        v
Ruby on Rails Backend
        |
        | URL Normalizer
        | Domain Matcher
        | Risk Analyzer
        | Logger
        v
PostgreSQL Database
        |
        v
Admin Dashboard

```

---

## 11. Main User Flow

### 11.1 Safe Link Flow

1. Agent opens a Zoho Desk ticket.
2. Agent clicks a link.
3. Browser extension intercepts the click.
4. Extension sends URL to Rails API.
5. Rails checks the URL.
6. Rails returns `safe`.
7. Extension opens the link normally.
8. Scan is logged.

---

### 11.2 Medium-Risk Link Flow

1. Agent clicks a link.
2. Extension sends the URL to Rails.
3. Rails detects suspicious indicators.
4. Extension shows a friendly warning.
5. Agent can:
  - Cancel
  - Ask Team Leader
  - Ask Senior Agent
  - Report to Ahmed
  - Continue if policy allows

---

### 11.3 High-Risk Link Flow

1. Agent clicks a suspicious link.
2. Rails returns `high_risk`.
3. Extension shows a strong warning.
4. Continue button should be hidden by default.
5. Agent should report to Ahmed or ask Team Leader.
6. Action is logged.

---

### 11.4 Blocked Link Flow

1. Agent clicks a blocked/phishing link.
2. Rails returns `blocked`.
3. Extension prevents navigation completely.
4. Agent sees a blocked message.
5. Agent can report to Ahmed or copy details.
6. Attempt is logged.

---

### 11.5 Professional Phishing Scenario Flow

Important scenario:

1. Sender asks normal question:  
“Hello, do you have availability for 2 adults from Friday to Sunday?”
2. Agent replies.
3. Sender replies later with:  
“Please confirm through this secure link.”
4. Extension still scans the new link.

Warning message should explain:

“Even if the previous email looked normal, this new message contains a link. Phishers often start with a normal conversation and send the malicious link later. Please verify before opening.”

---

## 12. Functional Requirements

---

## 12.1 Browser Extension Requirements

The extension must run only on Zoho Desk pages used by Crown Business Solutions.

It should:

1. Detect clickable links inside tickets.
2. Detect links behind:
  - Text
  - Buttons
  - Images
  - Anchor tags
3. Detect visible URLs inside message text when possible.
4. Intercept link clicks before the browser opens the URL.
5. Send the clicked URL to the Rails backend.
6. Wait for the scan result.
7. Open safe links normally.
8. Show warning for medium/high-risk links.
9. Block dangerous links.
10. Allow agent to report suspicious links.
11. Allow agent to copy warning details.
12. Cache recently scanned safe links for 10 minutes.
13. Avoid sending full email body to backend.
14. Send only security-relevant metadata.

---

### 12.1.1 Extension Data Sent to Backend

The extension may send:

- URL
- Current Zoho Desk page URL
- Ticket ID if detected
- Agent email if configured
- Agent name if configured
- Browser user agent
- Source: `zoho-desk-extension`

The extension must not send full email content in MVP.

---

### 12.1.2 Extension Popup

The extension popup should show:

- Crown Link Guard status
- Backend connection status
- Agent email
- Last scanned URL
- Extension version
- “Report current ticket” button

---

## 12.2 Rails Backend Requirements

The Rails backend must:

1. Receive scan requests.
2. Normalize URLs.
3. Extract domains.
4. Check allowlist.
5. Check blocklist.
6. Apply risk scoring rules.
7. Return risk result.
8. Log the scan.
9. Save agent reports.
10. Provide dashboard data.
11. Support admin CRUD for allowlist/blocklist.
12. Export reports and scans as CSV.
13. Protect APIs with token authentication.
14. Protect dashboard with admin login.

---

## 12.3 Admin Dashboard Requirements

The dashboard must have the following pages:

1. Login
2. Dashboard Home
3. URL Scans
4. Agent Reports
5. Allowlisted Domains
6. Blocked Domains
7. Settings
8. Audit Logs

---

### 12.3.1 Dashboard Home

Show cards:

- Total scanned links today
- Blocked links today
- High-risk links today
- Medium-risk links today
- Pending reports
- Confirmed phishing reports
- Top suspicious domains

---

### 12.3.2 URL Scans Page

Table columns:

- Date/time
- Agent email
- URL
- Domain
- Risk score
- Risk level
- Action taken
- Ticket URL
- Reasons

Filters:

- Date range
- Agent email
- Domain
- Risk level
- Action taken

Actions:

- View details
- Add domain to allowlist
- Add domain to blocklist
- Export CSV

---

### 12.3.3 Agent Reports Page

Table columns:

- Date/time
- Agent
- URL
- Domain
- Ticket URL
- Risk level
- Status
- Reviewer
- Notes

Report statuses:

- Pending
- Safe
- Phishing
- Needs more info

Actions:

- Mark as safe
- Mark as phishing
- Mark as needs more info
- Add to allowlist
- Add to blocklist
- Add reviewer note

---

### 12.3.4 Allowlisted Domains Page

Admin can:

- Add domain
- Remove domain
- Enable/disable domain
- Allow subdomains
- Add notes

Initial allowlist:

```text
zoho.com
zohodesk.com
crownbs.com
booking.com
admin.booking.com
eviivo.com
expediapartnercentral.com
hotels.com
expedia.com

```

Important rule:

Do not treat a domain as safe just because it contains the word `booking`.

Safe:

```text
booking.com
admin.booking.com

```

Not safe:

```text
booking.com.fake-domain.net
booking-secure-payment.com
booking.verify-partner.net

```

---

### 12.3.5 Blocked Domains Page

Admin can:

- Add blocked domain
- Remove blocked domain
- Enable/disable domain
- Add severity
- Add reason

Severity levels:

- Low
- Medium
- High
- Critical

---

### 12.3.6 Settings Page

Admin can configure:

- Medium-risk threshold
- High-risk threshold
- Blocked threshold
- Allow continue on medium risk
- Allow continue on high risk
- Ahmed contact email
- Team Leader instructions
- API token
- Internal system name
- Extension allowed version

Default settings:

```text
medium_risk_threshold = 31
high_risk_threshold = 61
blocked_threshold = 81
allow_continue_on_medium = true
allow_continue_on_high = false
ahmed_contact_email = ahmed.moniem@crownbs.com

```

---

## 13. URL Risk Scoring

The risk score should be from 0 to 100.

Risk levels:

```text
0–30    safe
31–60   medium_risk
61–80   high_risk
81–100  blocked

```

---

## 13.1 Safe Indicators

Reduce score if:

- Domain is exactly allowlisted.
- Domain is an approved subdomain of an allowlisted domain.
- URL uses HTTPS.
- Domain belongs to trusted company or OTA vendor.
- URL does not contain suspicious keywords.

---

## 13.2 Suspicious Indicators

Increase score if:

- Domain is not allowlisted.
- Domain is blocklisted.
- URL uses a shortener:
  - bit.ly
  - tinyurl.com
  - cutt.ly
  - t.co
  - shorturl.at
- Domain contains suspicious keywords:
  - payment
  - verify
  - secure
  - login
  - update
  - account
  - reservation
  - billing
  - partner
  - support
  - confirmation
  - invoice
- Domain looks similar to official OTA domains.
- URL contains the word `booking` but is not actually `booking.com`.
- URL uses suspicious TLD:
  - .xyz
  - .top
  - .tk
  - .info
  - .click
  - .site
  - .online
- URL contains an IP address instead of a normal domain.
- URL has too many subdomains.
- URL contains encoded or unusual characters.
- URL is HTTP instead of HTTPS.
- Link is hidden behind an image or button.
- URL path contains login/payment words.
- URL is newly added to blocklist.
- Domain resembles Crown BS or hotel partner names.

---

## 13.3 Example Risk Scoring Logic

Example 1:

```text
https://admin.booking.com

```

Expected:

```text
risk_score: 5
risk_level: safe
reason: Official allowlisted domain

```

---

Example 2:

```text
https://booking-secure-payment.com/login

```

Expected:

```text
risk_score: 90
risk_level: blocked
reasons:
- Domain is not allowlisted
- Domain looks similar to Booking.com but is not official
- URL contains payment/login keywords

```

---

Example 3:

```text
http://bit.ly/payment-confirmation

```

Expected:

```text
risk_score: 85
risk_level: blocked
reasons:
- URL shortener detected
- Payment-related keyword detected
- Cannot verify final destination

```

---

Example 4:

```text
https://booking.com.fake-domain.net/login

```

Expected:

```text
risk_score: 95
risk_level: blocked
reasons:
- Fake Booking.com subdomain trick
- Domain is actually fake-domain.net, not booking.com
- Login keyword detected

```

---

## 14. Rails Application Structure

Use a standard Rails app, not API-only, because we need both:

1. JSON API for the browser extension.
2. Admin dashboard using Rails views.

Recommended structure:

```text
app/
  controllers/
    application_controller.rb

    api/
      v1/
        base_controller.rb
        url_scans_controller.rb
        reports_controller.rb
        health_controller.rb

    admin/
      base_controller.rb
      sessions_controller.rb
      dashboard_controller.rb
      url_scans_controller.rb
      reports_controller.rb
      allowlisted_domains_controller.rb
      blocked_domains_controller.rb
      settings_controller.rb
      audit_logs_controller.rb

  models/
    user.rb
    url_scan.rb
    agent_report.rb
    allowlisted_domain.rb
    blocked_domain.rb
    security_setting.rb
    audit_log.rb

  services/
    url_normalizer.rb
    domain_matcher.rb
    url_risk_analyzer.rb
    scan_logger.rb
    audit_logger.rb

  views/
    admin/
      dashboard/
      url_scans/
      reports/
      allowlisted_domains/
      blocked_domains/
      settings/
      audit_logs/
      sessions/

  javascript/
    controllers/
      admin_filter_controller.js

browser_extension/
  manifest.json
  src/
    content.ts
    background.ts
    popup.ts
    modal.ts
    api.ts
    utils.ts
  public/
    popup.html

```

---

## 15. Database Models

Use PostgreSQL.

---

### 15.1 User

Purpose:

Admin dashboard users.

Fields:

```text
id
name
email
role
ad_username
password_digest
active
last_login_at
created_at
updated_at

```

Roles:

```text
agent
team_leader
admin

```

MVP:

Use normal Rails password authentication.

Future:

Add Active Directory / LDAP login.

---

### 15.2 UrlScan

Purpose:

Log every scanned link.

Fields:

```text
id
original_url
normalized_url
domain
risk_score
risk_level
action_taken
reasons
agent_email
agent_name
ticket_url
ticket_id
user_agent
device_name
source
created_at
updated_at

```

Enums:

```text
risk_level:
- safe
- medium_risk
- high_risk
- blocked

action_taken:
- allowed
- warned
- blocked
- reported
- cancelled

```

`reasons` should be JSONB.

---

### 15.3 AgentReport

Purpose:

Store links manually reported by agents.

Fields:

```text
id
original_url
normalized_url
domain
ticket_url
ticket_id
agent_email
agent_name
agent_note
risk_score
risk_level
reasons
status
reviewer_email
reviewer_note
reviewed_at
created_at
updated_at

```

Statuses:

```text
pending
safe
phishing
needs_more_info

```

`reasons` should be JSONB.

---

### 15.4 AllowlistedDomain

Purpose:

Trusted domains.

Fields:

```text
id
domain
allow_subdomains
notes
created_by
active
created_at
updated_at

```

Rules:

- Exact match should be supported.
- Optional subdomain matching should be supported.
- Fake suffix matching must not be allowed.

Example:

If `booking.com` is allowlisted with subdomains enabled:

Safe:

```text
admin.booking.com
partner.booking.com

```

Not safe:

```text
booking.com.fake-domain.net

```

---

### 15.5 BlockedDomain

Purpose:

Known dangerous domains.

Fields:

```text
id
domain
severity
reason
created_by
active
created_at
updated_at

```

Severities:

```text
low
medium
high
critical

```

---

### 15.6 SecuritySetting

Purpose:

Store configurable system settings.

Fields:

```text
id
key
value
updated_by
created_at
updated_at

```

Example keys:

```text
medium_risk_threshold
high_risk_threshold
blocked_threshold
allow_continue_on_medium
allow_continue_on_high
ahmed_contact_email

```

---

### 15.7 AuditLog

Purpose:

Track admin actions.

Fields:

```text
id
user_email
action
record_type
record_id
metadata
created_at

```

`metadata` should be JSONB.

---

## 16. Rails Services

---

### 16.1 UrlNormalizer

Responsible for:

- Trim spaces.
- Validate URL.
- Add scheme if missing where possible.
- Lowercase hostname.
- Extract hostname.
- Extract root domain.
- Detect invalid URLs.
- Detect IP address URLs.
- Detect punycode domains.
- Remove fragments where safe.
- Preserve original URL for logging.

Input:

```ruby
"https://Booking-Secure-Payment.com/Login"

```

Output:

```ruby
{
  original_url: "...",
  normalized_url: "https://booking-secure-payment.com/Login",
  domain: "booking-secure-payment.com",
  valid: true
}

```

---

### 16.2 DomainMatcher

Responsible for:

- Exact allowlist matching.
- Safe subdomain matching.
- Blocklist matching.
- Detecting fake domain tricks.

Important:

This service must identify the real registered/root domain.

Example:

```text
booking.com.fake-domain.net

```

The real domain is:

```text
fake-domain.net

```

It must not be treated as Booking.com.

---

### 16.3 UrlRiskAnalyzer

Responsible for:

- Running all risk rules.
- Generating risk score.
- Generating risk level.
- Returning reasons.

Output example:

```ruby
{
  risk_score: 85,
  risk_level: "blocked",
  action: "block",
  domain: "booking-secure-payment.com",
  reasons: [
    "Domain is not allowlisted",
    "Domain looks similar to Booking.com but is not official",
    "URL contains payment/login-related keywords"
  ]
}

```

---

### 16.4 ScanLogger

Responsible for:

- Creating UrlScan record.
- Saving request metadata.
- Saving action taken.
- Saving reasons.

---

### 16.5 AuditLogger

Responsible for:

- Logging admin dashboard actions.
- Logging domain allowlist/blocklist changes.
- Logging report status changes.

---

## 17. Rails API Endpoints

All extension APIs should be under:

```text
/api/v1

```

---

### 17.1 GET /api/v1/health

Purpose:

Extension checks if backend is online.

Response:

```json
{
  "status": "ok",
  "app": "Crown Link Guard",
  "version": "1.0.0"
}

```

---

### 17.2 POST /api/v1/scan_url

Purpose:

Scan URL before opening.

Request:

```json
{
  "url": "https://booking-secure-payment.com/login",
  "ticket_url": "https://desk.zoho.com/agent/tickets/123",
  "ticket_id": "123",
  "agent_email": "agent@crownbs.com",
  "agent_name": "Agent Name",
  "source": "zoho-desk-extension"
}

```

Response:

```json
{
  "risk_score": 90,
  "risk_level": "blocked",
  "action": "block",
  "domain": "booking-secure-payment.com",
  "reasons": [
    "Domain is not allowlisted",
    "Domain looks similar to Booking.com but is not official",
    "URL contains payment/login-related keywords"
  ],
  "message": "This link has been blocked because it matches phishing indicators."
}

```

---

### 17.3 POST /api/v1/reports

Purpose:

Agent reports suspicious URL to Ahmed.

Request:

```json
{
  "url": "https://booking-secure-payment.com/login",
  "ticket_url": "https://desk.zoho.com/agent/tickets/123",
  "ticket_id": "123",
  "agent_email": "agent@crownbs.com",
  "agent_name": "Agent Name",
  "agent_note": "This link came after a normal availability question."
}

```

Response:

```json
{
  "success": true,
  "message": "Reported successfully. Please do not open the link until it is reviewed."
}

```

---

### 17.4 POST /api/v1/actions

Purpose:

Log what the agent selected in the warning modal.

Request:

```json
{
  "scan_id": 123,
  "action_taken": "cancelled",
  "agent_email": "agent@crownbs.com"
}

```

Possible actions:

```text
allowed
warned
blocked
reported
cancelled
asked_team_leader
asked_senior_agent
copied_details

```

---

## 18. Admin Routes

Use Rails admin namespace.

```text
/admin/login
/admin/logout
/admin
/admin/url_scans
/admin/reports
/admin/allowlisted_domains
/admin/blocked_domains
/admin/settings
/admin/audit_logs

```

---

## 19. API Authentication

The browser extension must send an internal API token.

Header:

```http
Authorization: Bearer INTERNAL_EXTENSION_TOKEN

```

Rails must reject requests without a valid token.

For MVP:

- Store token in Rails credentials or environment variable.
- Store extension token inside managed extension config.

Do not hardcode production secrets in public code.

---

## 20. Admin Authentication

MVP:

Use Rails authentication with:

- Email
- Password
- Password digest using bcrypt
- Rails session cookies

Only admin users can access dashboard pages.

Future:

Add Active Directory / LDAP authentication.

---

## 21. CORS Requirements

Rails must allow browser extension requests.

Development:

Allow:

```text
localhost
chrome-extension://*

```

Production:

Allow only:

- Approved Chrome extension ID
- Approved Edge extension ID
- Internal admin hostname

---

## 22. Browser Extension UX

---

### 22.1 Medium-Risk Warning

Title:

```text
Careful — this link may be unsafe

```

Body:

```text
This link is not from a trusted or official domain. Phishing emails can look professional and may appear after a normal conversation.

```

Show:

- Domain
- Risk level
- Reasons
- Recommended action

Buttons:

```text
Cancel
Ask Team Leader
Ask Senior Agent
Report to Ahmed
Continue

```

Continue only appears if `allow_continue_on_medium = true`.

---

### 22.2 High-Risk Warning

Title:

```text
This link looks suspicious

```

Body:

```text
This link may be part of a phishing attempt. Do not open it unless it is verified by a Team Leader, senior agent, or Ahmed Moniem.

```

Buttons:

```text
Cancel
Ask Team Leader
Ask Senior Agent
Report to Ahmed
Copy Details

```

Continue should be hidden by default.

---

### 22.3 Blocked Link Message

Title:

```text
Link blocked for your safety

```

Body:

```text
This link has been blocked because it matches phishing indicators or the company blocklist.

```

Buttons:

```text
Report to Ahmed
Copy Details
Close

```

---

### 22.4 Professional Phishing Warning Copy

When suspicious link appears in a ticket:

```text
Even if the previous message looked normal, this new message contains a link. Phishers often start with a normal conversation, then send the malicious link later. Please verify before opening.

```

---

### 22.5 Ask Team Leader Flow

When agent clicks “Ask Team Leader”:

Show:

```text
Please ask your Team Leader before opening this link. Keep the ticket open and do not click the link until verified.

```

Also copy to clipboard:

```text
Please review this suspicious link:

Ticket:
{ticket_url}

URL:
{suspicious_url}

Risk Level:
{risk_level}

Reasons:
{reasons}

```

---

### 22.6 Ask Senior Agent Flow

When agent clicks “Ask Senior Agent”:

Show:

```text
Please ask a senior agent to review this ticket before opening the link.

```

Copy same details to clipboard.

---

### 22.7 Report to Ahmed Flow

When agent clicks “Report to Ahmed”:

1. Extension calls `/api/v1/reports`.
2. Rails saves report.
3. UI shows success message.

Success message:

```text
Reported successfully. Please do not open the link until it is reviewed.

```

Also copy message to clipboard:

```text
Hi Ahmed, I found a suspicious link in this Zoho Desk ticket. Please review it.

Ticket:
{ticket_url}

URL:
{suspicious_url}

```

---

## 23. Zoho Desk Integration

### MVP

No full Zoho API integration is required.

The extension should:

- Detect the current Zoho ticket URL.
- Try to extract ticket ID from the page URL.
- Include the ticket URL in reports.

### Future Enhancement

If Zoho API credentials are provided, add:

- Automatic ticket assignment to Ahmed Moniem.
- Add internal note to ticket.
- Change ticket status.
- Tag ticket as suspicious/phishing.
- Notify admin.

Future service:

```text
ZohoDeskService

```

Possible methods:

```ruby
assign_ticket(ticket_id, assignee_email)
add_internal_note(ticket_id, note)
add_tag(ticket_id, tag)

```

---

## 24. Security Requirements

1. Do not store plain text passwords.
2. Use HTTPS in production.
3. Use API token for extension endpoints.
4. Use admin authentication for dashboard.
5. Use role-based access for admin functions.
6. Do not collect full email content in MVP.
7. Do not store unnecessary guest personal data.
8. Store only security-relevant metadata.
9. Log admin actions.
10. Validate all URLs on backend.
11. Sanitize all displayed URLs in dashboard.
12. Use secure headers.
13. Use rate limiting for API endpoints.
14. Keep backend internal or VPN-only.
15. Do not install on Domain Controller.

---

## 25. Privacy Requirements

The system should collect minimum required information only.

Allowed:

- URL
- Domain
- Ticket URL
- Ticket ID
- Agent email/name
- Risk result
- Action taken
- Timestamp

Not allowed in MVP:

- Full guest message body
- Guest payment information
- Guest ID documents
- Full email thread content
- Passwords or credentials

---

## 26. Non-Functional Requirements

### Performance

- URL scan response should be under 500ms for normal rule-based checks.
- Dashboard pages should load under 2 seconds for normal datasets.
- Extension should not noticeably slow down Zoho Desk.

### Availability

- Backend should run during business hours.
- If backend is offline, extension should fail safely.

Fail-safe behavior:

- Unknown links should show warning.
- Allowlisted domains may open.
- Non-allowlisted links should ask user to verify manually.

### Compatibility

Must support:

- Windows laptops
- Google Chrome
- Microsoft Edge
- Zoho Desk web interface

### Maintainability

- Clear Rails services.
- Tests for risk analyzer.
- Tests for domain matching.
- Seed file for initial settings/domains.
- Simple admin UI.

---

## 27. Deployment Requirements

### Rails App

Deploy to separate internal VM.

Recommended production setup:

```text
Ubuntu Server
Ruby
Rails
PostgreSQL
Nginx
Puma
HTTPS
Internal DNS

```

Do not deploy on Active Directory Domain Controller.

---

### Browser Extension Deployment

MVP:

- Manual install for test users.

Production:

- Deploy through Group Policy or managed browser policy.
- Force install extension on agent laptops.
- Configure API URL and token through managed policy if possible.

---

## 28. Active Directory / GPO Notes

Active Directory can be used for:

- Deploying the extension.
- Managing Chrome/Edge policies.
- Preventing users from disabling the extension.
- Enforcing browser security settings.
- Removing local admin rights.
- Applying Windows Defender policies.

The app itself should not run on the Domain Controller.

---

## 29. MVP Development Plan

---

### Phase 1: Rails Backend Foundation

1. Create Rails app with PostgreSQL.
2. Add gems:
  - pg
  - bcrypt
  - rack-attack
  - pagy or kaminari
  - csv support
3. Create database models:
  - User
  - UrlScan
  - AgentReport
  - AllowlistedDomain
  - BlockedDomain
  - SecuritySetting
  - AuditLog
4. Add seeds for:
  - Admin user
  - Initial allowlisted domains
  - Default settings

---

### Phase 2: URL Analysis Engine

Create services:

1. UrlNormalizer
2. DomainMatcher
3. UrlRiskAnalyzer
4. ScanLogger
5. AuditLogger

Add unit tests for:

- Safe official domains
- Fake Booking.com domains
- URL shorteners
- Suspicious TLDs
- Blocklisted domains
- Subdomain tricks

---

### Phase 3: API

Implement:

1. GET `/api/v1/health`
2. POST `/api/v1/scan_url`
3. POST `/api/v1/reports`
4. POST `/api/v1/actions`

Add:

- API token authentication
- Rate limiting
- Error handling
- JSON responses

---

### Phase 4: Admin Dashboard

Implement:

1. Admin login/logout
2. Dashboard home
3. URL scans page
4. Reports page
5. Allowlisted domains CRUD
6. Blocked domains CRUD
7. Settings page
8. Audit logs page
9. CSV export

---

### Phase 5: Browser Extension

Build extension:

1. Manifest V3
2. Content script for Zoho Desk
3. Link detection
4. Click interception
5. Rails API integration
6. Warning modal
7. Block modal
8. Report to Ahmed flow
9. Ask Team Leader flow
10. Ask Senior Agent flow
11. Copy details feature
12. Extension popup

---

### Phase 6: Testing

Test scenarios:

1. Safe Booking.com URL opens normally.
2. Safe Eviivo URL opens normally.
3. Fake Booking.com domain is blocked.
4. URL shortener is blocked or warned.
5. Suspicious payment link is blocked.
6. Link behind image is scanned.
7. Link behind button is scanned.
8. Professional phishing scenario triggers warning.
9. Report to Ahmed creates report.
10. Admin can mark report as phishing.
11. Admin can add domain to blocklist.
12. Admin can add domain to allowlist.
13. Extension fails safely if backend is offline.

---

## 30. Acceptance Criteria

The MVP is accepted when:

1. Rails backend is running successfully.
2. PostgreSQL database is connected.
3. Admin can log in.
4. Admin can manage allowlisted domains.
5. Admin can manage blocked domains.
6. Admin can view URL scans.
7. Admin can view agent reports.
8. Browser extension runs on Zoho Desk.
9. Extension scans every clicked link before opening.
10. Safe links open normally.
11. Suspicious links show warning.
12. Blocklisted links are blocked.
13. URL shorteners are detected.
14. Fake Booking.com domains are detected.
15. Agent can report suspicious link to Ahmed.
16. Agent can copy details for Team Leader/senior agent.
17. All scans are logged.
18. All reports are saved.
19. CSV export works.
20. App is not installed on Domain Controller.

---

## 31. Example Test URLs

Safe:

```text
https://www.booking.com
https://admin.booking.com
https://www.eviivo.com
https://www.expediapartnercentral.com
https://desk.zoho.com
https://www.zoho.com

```

Suspicious:

```text
https://booking-secure-payment.com/login
https://booking.verify-partner.net
https://booking.com.payment-review.example.net
https://reservation-payment-update.xyz
https://secure-booking-login.site
https://payment-booking-confirmation.top

```

URL shorteners:

```text
http://bit.ly/fake-payment
https://tinyurl.com/fake-login
https://cutt.ly/payment-update

```

Fake subdomain trick:

```text
https://booking.com.fake-domain.net/login
https://admin.booking.com.secure-login.site

```

---

## 32. Cursor Implementation Instructions

Build this as a Ruby on Rails application with PostgreSQL.

Use a standard Rails app, not API-only.

First create:

1. Rails backend
2. Database models
3. URL risk analyzer services
4. API endpoints
5. Admin dashboard
6. Browser extension folder

The first working demo should prove:

1. Admin can add allowlisted and blocked domains.
2. Extension can call Rails API.
3. Safe link opens.
4. Suspicious link warns.
5. Blocked link does not open.
6. Agent can report the URL.
7. Report appears in admin dashboard.

Start with backend first, then browser extension.

---

## 33. Suggested First Cursor Prompt

Use this prompt to start implementation:

```text
Build the Crown Link Guard MVP as described in this PRD.

Use Ruby on Rails with PostgreSQL.

Create a standard Rails app, not API-only, because we need both JSON API endpoints and an admin dashboard.

Start by implementing:
1. Models and migrations:
   - User
   - UrlScan
   - AgentReport
   - AllowlistedDomain
   - BlockedDomain
   - SecuritySetting
   - AuditLog

2. Services:
   - UrlNormalizer
   - DomainMatcher
   - UrlRiskAnalyzer
   - ScanLogger
   - AuditLogger

3. API endpoints:
   - GET /api/v1/health
   - POST /api/v1/scan_url
   - POST /api/v1/reports
   - POST /api/v1/actions

4. Admin dashboard:
   - Login/logout
   - Dashboard home
   - URL scans page
   - Reports page
   - Allowlist CRUD
   - Blocklist CRUD
   - Settings page
   - Audit logs page

5. Seed data:
   - Admin user
   - Initial allowlisted domains
   - Default risk thresholds

6. Add a browser_extension folder with Manifest V3 TypeScript structure, but implement the Rails backend first.

Make the code clean, simple, secure, and easy to deploy internally.

```

---

## 34. Future Enhancements

After MVP, add:

1. Zoho Desk API integration.
2. Automatic ticket assignment to Ahmed Moniem.
3. Add internal notes to Zoho tickets.
4. Active Directory / LDAP login.
5. Microsoft Defender integration.
6. VirusTotal or Google Safe Browsing API integration.
7. AI email thread analysis.
8. Attachment scanning.
9. Real-time Teams notifications.
10. Browser isolation for unknown links.
11. Weekly security reports.
12. Central GPO deployment guide.
13. Device-level agent for deeper Windows protection.

---

## 35. Final Product Principle

The product should be calm, helpful, and supportive.

Do not blame agents.

Good message:

```text
Careful — this link may be unsafe. Please verify it before opening.

```

Bad message:

```text
You clicked a dangerous phishing link.

```

The goal is to help agents stop, think, ask, and report before taking risky action.