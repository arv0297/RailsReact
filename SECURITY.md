# Security considerations log

This file tracks, for every change made to the project, which parts of the code could
introduce or be affected by a security vulnerability and must be tested/reviewed before
the feature is considered done.

It is a **manual** checklist/log. There is no CI gate or git hook enforcing it; the
responsibility is on the author (and on agents, per `AGENTS.md`).

## How to use

1. Before starting a change, re-read the relevant business context (model, controller,
   GraphQL, route, view, config) instead of guessing.
2. While implementing, note any area that touches untrusted input, auth, sessions,
   CSRF, XSS, SQL, file uploads, external calls, secrets, or config.
3. **Before ending the feature**, append a row to the log below listing the code areas
   that could have a vulnerability and what must be tested/verified. Do not close the
   feature until every row is marked `Verified` or `N/A with reason`.
4. Run the security toolchain (`bin/brakeman --no-pager`, `bin/bundler-audit`,
   `npm audit`) and `bin/ci-local` before proposing a commit.

## Reusable security checklist

### General
- [ ] No secrets, tokens, passwords, or private keys committed (`.env`, `config/*.key`,
      `config/credentials/*.key`, `config/database.yml` stay gitignored).
- [ ] User input is validated/sanitized before use; no raw SQL/`eval`/`send` on input.
- [ ] Errors do not leak stack traces or internal details in production.
- [ ] Dependencies audited (`bundler-audit`, `npm audit`, `brakeman` clean).

### Rails / controllers / views
- [ ] Strong parameters (`params.require(...).permit(...)`) on every create/update.
- [ ] CSRF protection left enabled (`protect_from_forgery`) unless intentionally disabled
      with a documented reason.
- [ ] Mass assignment not possible on sensitive attributes (`active`, `role`, etc.).
- [ ] ERB output is escaped; `raw`/`html_safe` only on trusted content.
- [ ] `redirect_to` targets are not derived from untrusted input (open redirect).
- [ ] File uploads validated for type/size; Active Storage services configured.
- [ ] Production hardening enabled (`force_ssl`, `assume_ssl`, `hosts`,
      `host_authorization`, CSP).

### GraphQL
- [ ] Introspection disabled in production.
- [ ] `max_depth` and `max_complexity` set.
- [ ] No N+1 / unbounded lists; pagination present.
- [ ] Auth/authorization enforced in resolvers/mutations (no anonymous access to
      sensitive data).
- [ ] Variables validated by GraphQL types; no `to_unsafe_hash` misuse.

### JavaScript / React
- [ ] No `dangerouslySetInnerHTML` with untrusted data.
- [ ] No secrets in client bundles.
- [ ] CSP compatible (no inline scripts/styles without nonces).

### Config / infra
- [ ] `.env.example` updated when new env vars are added.
- [ ] Docker images not running as root where avoidable.
- [ ] CI security jobs (`scan_ruby`, `scan_js`) still pass.

## Per-change log

| Date | Branch / feature | Changed areas | Potential vulnerability to test before closing | Status |
|------|------------------|---------------|-----------------------------------------------|--------|
| 2026-11-12 | feature/agent-git-conventions (security hardening) | `config/environments/production.rb`, `config/initializers/content_security_policy.rb`, `app/graphql/app_schema.rb`, `.env.example` | TLS/hosts redirect loops, CSP breaking assets/scripts, GraphQL query limits rejecting valid queries, missing env vars | Verified (scans clean; syntax OK) |
| 2026-11-12 | feature/agent-git-conventions (security log) | `SECURITY.md`, `AGENTS.md` | Documentation only; no runtime impact | Verified |

### Entry template (copy for new features)

```
| YYYY-MM-DD | branch/feature | path/to/file.rb, ... | What could be vulnerable and how to test it | Pending/Verified |
```
