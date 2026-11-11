# Changelog

Record of every change done on the project, one entry per feature/branch, newest first.
Every task that modifies the project must add an entry here (rule defined in `AGENTS.md`).
Earlier history (before this file existed) is summarized at the bottom from `git log`.

---

## 2026-11-10 — feature/20261110185837

(work moved here from feature/20261110181716, which was already merged into develop via PR
and should stay closed — new work always goes on a fresh feature branch)

### Dependency security upgrade + Dependabot grouping (closes all open Dependabot PRs)

**Why:** CI's `bundler-audit` step was failing with real advisories, and Dependabot had 15
open PRs (10 gems + 5 GitHub Actions). All updates were combined into this single commit so
the bot PRs get superseded instead of merged one by one.

**Gems updated (`Gemfile` + `Gemfile.lock`):**

| Gem | From | To | Reason |
|---|---|---|---|
| rails | 8.1.3.1 | 8.1.4.1 | Security (Active Storage RCE GHSA-f3w6-w445-fwh9, Action Pack IP spoofing/Strong Params bypass, XSS in Action View, DoS safe_constantize, and ~20 more; all fixed in 8.1.4.1) |
| graphql | 2.6.7 | 2.6.15 | Security (GHSA-4rw8-495r-pf6j, GHSA-q3cc-p5hm-55wj, GHSA-965v-9v76-5hg2 — authorization bypass / data disclosure) |
| rack | 3.2.6 | 3.2.8 | Security (High: multipart parser DoS GHSA-5v64-555j-wjxm, host header bypass GHSA-2j8w-xcrc-x985) |
| rails-html-sanitizer | 1.7.1 | 1.7.2 | Security (XSS via shared scrubber state GHSA-h7wh-q2qr-458c, ReDoS GHSA-cpgf-5mjf-73p7) |
| nokogiri | 1.19.4 | 1.19.7 | Security (use-after-free, Mutation XSS in HTML5 noscript) |
| loofah | 2.25.2 | 2.25.3 | Security (Mutation XSS, SVG local-reference bypass) |
| crass | 1.0.7 | 1.0.8 | Security (CSS sanitizer bypass) |
| addressable | 2.9.0 | 2.9.2 | Security (multiple ReDoS / misleading host advisories) |
| net-ssh | 7.3.3 | 7.3.10 | Security (SSH host-certificate auth bypass, pre-auth DoS; transitive dep of kamal) |
| pg | 1.6.3 | 1.7.0 | Dependabot version update |
| image_processing | 1.14.0 | 2.2.0 | Dependabot version update (major) |
| solid_queue | 1.5.0 | 1.7.0 | Dependabot version update |
| solid_cable | 4.0.2 | 4.1.0 | Dependabot version update |
| selenium-webdriver | 4.46.0 | 4.50.0 | Dependabot version update |
| bootsnap | 1.24.6 | 1.26.0 | Dependabot version update |
| brakeman | 8.0.6 | 8.1.0 | Dependabot version update |
| thruster | 0.1.23 | 0.1.26 | Dependabot version update |

**Breaking changes handled:**

- `image_processing` 2.x dropped `ruby-vips`/`mini_magick` as hard dependencies. Rails 8.1
  aborts boot with `LoadError` if `ruby-vips` is missing (activestorage's vips transformer
  requires it eagerly). Fix: added `gem "ruby-vips", "~> 2.3", require: false` to the
  Gemfile. Runtime requirements are unchanged (ruby-vips + libvips were already present).
- `solid_queue` 1.7 adds job batches → new tables. Fix: added `solid_queue_batches`,
  `solid_queue_batch_executions` and `batch_id` on `solid_queue_jobs` to `db/queue_schema.rb`
  (copied from the gem's `solid_queue:update` template; this app uses schema files for the
  queue DB, not migrations).
- `pg` 1.7.0 requires Ruby >= 3.1 (we're on 3.4.10 — fine) and PostgreSQL 10+ (fine).

**GitHub Actions updated (`.github/workflows/ci.yml`):**
`actions/checkout` v6→v7, `actions/setup-node` v4→v7, `actions/cache` v4→v6,
`actions/upload-artifact` v4→v6, `browser-actions/setup-chrome` v1→v2.
Checked breaking changes: checkout v7 only refuses fork-PR checkouts under
`pull_request_target` (not used here); setup-node v7 keeps the same inputs.

**Dependabot grouping (`.github/dependabot.yml`):**
Updates are now grouped into ONE PR per ecosystem per week (bundler, npm, github-actions)
instead of one PR per package. Also added the `npm` ecosystem (CI already runs `npm audit`).

**Verification (in `ruby:3.4.10-slim` Docker container with Postgres 16):**
- `bundle install` clean (lockfile consistent, `BUNDLED WITH 2.6.9` preserved)
- `bundler-audit` → **No vulnerabilities found**
- `brakeman` → 0 warnings; `rubocop` → 54 files, no offenses
- `npm ci && npm run build` OK
- `bin/rails db:test:prepare && bundle exec rspec` → 5 examples, 0 failures

**Superseded Dependabot branches:** bootsnap-1.26.0, brakeman-8.1.0, graphql-2.6.11,
image_processing-2.2.0, pg-1.7.0, rails-8.1.4, selenium-webdriver-4.50.0,
solid_cable-4.1.0, solid_queue-1.7.0, thruster-0.1.26 + the 5 github_actions branches.

### Added `bin/ci-local` — local replica of the CI pipeline
Runs the exact commands of `.github/workflows/ci.yml` (jobs `scan_ruby`, `scan_js`, `lint`,
`test`, `system-test`) in Docker, starting a throwaway `postgres:16` container. Ruby/Node
are not needed on the host. Usage: `bin/ci-local` (all jobs) or `bin/ci-local scan_ruby lint`
(specific jobs). Verified on this branch: all 5 jobs PASS — brakeman 0 warnings,
bundler-audit 0 vulnerabilities, `npm audit` 0 vulnerabilities, rubocop 0 offenses,
rspec 5/5, system spec 1/1.

### AGENTS.md created on this branch
First version of the agent instructions file (setup, tests, lint, app-specific conventions).

---

## Earlier history (pre-changelog, summarized from `git log`)

- **2026-08-16** — hotfix/20260816200508: basic postgres config on credentials.
- **2026-08-11..15** — hotfix/20260811225012: series of CI fixes (rspec alerts, brakeman
  update, Propshaft asset scan errors, DB CI alerts, stuck tests/npm, missing Propshaft
  alerts in tests).
- **2026-08-11** — feature: basic GraphQL configuration; basic User model + controller.
