# Crown Link Guard Deployment Guide

## Recommended Production Shape

- Ubuntu Server VM joined to the domain if needed.
- Ruby, Rails, PostgreSQL, Puma.
- Nginx reverse proxy.
- HTTPS certificate trusted by Crown laptops.
- Internal DNS hostname: `linkguard.crownbs.local`.
- Firewall/VPN rules so only internal users and managed browsers can reach the service.

## Environment Variables

```sh
CROWN_LINK_GUARD_ADMIN_EMAIL=admin@crownbs.com
CROWN_LINK_GUARD_ADMIN_PASSWORD=replace-with-strong-password
CROWN_LINK_GUARD_API_TOKEN=replace-with-managed-extension-token
RAILS_MASTER_KEY=...
DATABASE_URL=postgres://user:password@localhost/crown_link_guard_production
```

## First Boot

```sh
bundle install --deployment
RAILS_ENV=production bin/rails db:migrate
RAILS_ENV=production bin/rails db:seed
RAILS_ENV=production bin/rails assets:precompile
```

## Nginx Notes

Terminate HTTPS at Nginx and proxy to Puma on localhost. Only allow approved internal hosts and extension origins in production policy.

## Browser Extension Rollout

For pilot users, load `browser_extension` manually. For production, deploy through Group Policy or managed Chrome/Edge policy and prevent removal by standard support agents.

## Domain Controller Safety

The Active Directory Domain Controller must not host Rails, PostgreSQL, Nginx, or Puma. Keep it limited to identity, policy, and endpoint management functions.
