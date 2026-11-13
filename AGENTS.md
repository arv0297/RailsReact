# AGENTS.md

## Project
- Rails 8.1.4.1 + Ruby 3.4.10 (`.ruby-version`) app with ERB views, React islands, GraphQL, and PostgreSQL. CI uses Node 20.
- Application module is `App`; GraphQL schema is `AppSchema` (`app/graphql/app_schema.rb`).

## Agent workflow & environment (read this first)
- Before running any command or changing code: re-read the user's request and the relevant business context (model/controller/GraphQL/route/spec) instead of guessing. Then check the command lists below before rediscovering the toolchain — the needed commands are already recorded here to save time and tokens.
- Security review per change: after any code/config change, identify the parts that could introduce a vulnerability (input handling, auth, CSRF, XSS, SQL, secrets, GraphQL, config) and record them in `SECURITY.md` (per-change log) with what must be tested before the feature ends. Run `bin/brakeman --no-pager`, `bin/bundler-audit`, `npm audit` and `bin/ci-local` and mark the entry `Verified` or `N/A with reason`.
- Host: Linux + zsh. **Docker is installed.** Ruby, Node/npm and the GitHub CLI (`gh`) are **NOT installed on the host** — do not rely on them directly.
- Git auth: HTTPS remote with `credential.helper=store` (`~/.git-credentials`), so `git push` and `git push origin --delete <branch>` work without prompting (deleting a Dependabot branch auto-closes its PR).
- Scratch space: `/tmp/opencode` (pre-approved for work outside the repo).
- Known-good commands (copy, don't rethink):
  - Full CI replica (gems, JS, lint, security, RSpec, system): `bin/ci-local` (or `bin/ci-local scan_ruby lint`).
  - npm audit without host Node: `docker run --rm -v "$PWD:/app" -w /app node:20 sh -c "npm audit --json"`.
  - bundler-audit without host Ruby (binary is not on PATH inside the image): `docker run --rm -v "$PWD:/app" -w /app ruby:3.4 bash -lc "gem install bundler-audit --no-document >/dev/null 2>&1; /usr/local/bundle/bin/bundler-audit check --update"`.
- **Never commit autonomously.** Do NOT run `git commit`, `git commit --amend`, `git push`, `git tag`, or create/merge PRs unless the user explicitly asks. Before any commit, propose the short Conventional Commit subject (≤50 chars; body only if needed) and show `git status` and `git diff --staged` so the user can review; wait for explicit approval, then use exactly the approved message. Stage only the intended files; never commit secrets, `.env`, `config/database.yml`, or build artifacts.

## Setup and run
- `bin/setup` installs gems, runs `db:prepare`, clears logs, then starts `bin/dev`; use `bin/setup --skip-server` in automation.
- `bin/dev` (foreman + `Procfile.dev`) runs Puma on `0.0.0.0:3000` and `npm run build:watch`.
- `config/database.yml` is intentionally gitignored and absent. Provide it locally or set `DATABASE_URL`; CI uses `DATABASE_URL=postgres://postgres:postgres@localhost:5432/rails_test`.
- `.env` is local-only. `docker-compose.yml` reads `POSTGRES_*` for the `db` service but does not set `DATABASE_URL` for `web`, so the web container still needs `config/database.yml`.

## JavaScript / assets
- esbuild (jsbundling) bundles only top-level `app/javascript/*.*` into gitignored `app/assets/builds`. The layout includes only `application`; import components from subdirectories.
- `.js` uses the JSX loader, so JSX in `.js` is valid.
- Run `npm run build` before booting/testing without `bin/dev`; Propshaft serves assets (`config/initializers/assets.rb`). Do not reintroduce importmap/Sprockets.
- React mounts on `DOMContentLoaded` into `#root` and `#chart` (`app/javascript/application.js`).

## Tests
- RSpec is the suite CI actually runs: `bin/rails db:test:prepare && bundle exec rspec`.
- `bin/ci-local` replicates the full GitHub Actions pipeline locally in Docker with the same commands: jobs `scan_ruby`, `scan_js`, `lint`, `test`, `system-test`. Run all (`bin/ci-local`) or specific ones (`bin/ci-local scan_ruby lint`). Needs only Docker; starts a throwaway `postgres:16`.
- Single spec: `bundle exec rspec spec/models/user_spec.rb` (append `:LINE` for one example).
- Every spec needs `require "rails_helper"` and an explicit `type:` (e.g. `:model`, `:request`, `:system`); spec-type inference is disabled.
- System specs use rack_test by default; tag `js: true` for Selenium headless Chrome. Build JS first and have Chrome available.
- `test/` and `bin/ci` (`config/ci.rb`) are leftover Minitest/seeds flows, not RSpec. Do not use `bin/ci` to verify RSpec changes.

## Lint / security
- `bin/rubocop` (rubocop-rails-omakase), `bin/brakeman --no-pager`, `bin/bundler-audit`, `npm audit`.
- `bin/ci-local` runs all of these exactly as CI does; use it to verify changes before pushing.
- Security hardening applied (2026-11-12): production TLS/hosts, CSP, GraphQL depth/complexity
  limits and prod introspection disable, plus `.env.example`. Scans are clean; see CHANGELOG.

## App-specific
- GraphQL endpoint: `POST /graphql` -> `GraphqlController#execute`; GraphiQL is development-only at `/graphiql`.
- Root is `home_pages#home`; `users` routes cover index/show/new/create/edit/update only (no destroy).
- `app/models/user.rb` validation messages are Spanish; keep new messages consistent.
- `db/seeds.rb` is gitignored; do not rely on seeds existing.
- `config/deploy.yml` / `.kamal` are placeholders (fake IP and localhost registry); do not deploy from them without real config.
- `image_processing` is 2.x, which no longer pulls `ruby-vips`/`mini_magick` itself. `ruby-vips` is a separate Gemfile entry and Rails 8.1 aborts boot without it (Active Storage's vips transformer). `libvips` must be installed on the system (Docker/CI already have it).
- The queue DB uses schema files, not migrations: `db/queue_schema.rb`, `db/cache_schema.rb`, `db/cable_schema.rb` (`config.solid_queue.connects_to` in `production.rb`). When upgrading `solid_queue`, copy any new tables/columns from the gem's install template or `solid_queue:update` generator into `db/queue_schema.rb`.

## Dependencies / upgrades
- `.github/dependabot.yml` groups updates: ONE PR per ecosystem per week (bundler, npm, github-actions). Do not split grouped PRs.
- When upgrading gems for CI to pass, run the full security suite: `bin/bundler-audit` must report no vulnerabilities (it checks transitive deps like `rails-html-sanitizer`, `nokogiri`, `rack` that Dependabot PRs don't cover).
- Ruby is not installed on this machine. Validate gem changes with `bin/ci-local` (runs the whole CI pipeline in Docker; needs only Docker).
- Keep `Gemfile.lock`'s `BUNDLED WITH 2.6.9` when regenerating it.

## Documentation rules
- ALWAYS update `CHANGELOG.md` (record of every change per feature/branch) and this file (`AGENTS.md`) after finishing a task. They grow alongside the project.
- ALWAYS update `SECURITY.md` after finishing a task: append a per-change log entry listing the code areas that could have a vulnerability and what must be tested, then mark it `Verified`/`N/A with reason`.
- ALWAYS explain every change in the console (what changed and why) and offer the option to revert/erase it before committing; do not assume prior knowledge.
- ONLY skip updating these files if the user explicitly says they just want the task run without documentation updates.

## Git Flow & commit conventions
- Use standard Git Flow: `master` (production) + `develop` (integration); change branches are separated by type-prefix folders: `feature/<short-slug>`, `release/<version>`, `hotfix/<version>` (legacy timestamp form `feature|hotfix/YYYYMMDDHHMMSS` is still valid). One change type per branch folder — do not mix features, releases and hotfixes.
- Keep branch names and commit subjects SHORT and specific to ONE change. Never name a branch/commit after an entire batch or "the whole fix"; put the full explanation in the commit body / PR description.
- Commit subject: `<type>(<scope>): <short imperative summary>` (Conventional Commits), ≤50 chars, lowercase after the colon, no trailing period.
- Types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`, `chore`, `revert`.
- One logical change per commit/PR; split refactors, formatting, dependency bumps and behavior changes into separate commits.
- Keep commit messages SHORT: subject only in most cases. Put the full what/why description in the PR body (PR title = the short Conventional Commit subject). Add a commit body/footer only when needed: `Refs:`/`Closes:` for tickets, `BREAKING CHANGE:` for breaking changes.

## Merge strategy & rollback
- Enforce the flow on GitHub: default branch = `develop`; protect `develop` and `master` (require PR + CI status + branch up to date; block direct pushes, force-push, deletion); enable auto-delete of head branches. Optional: `git flow` extension so `feature start` always branches from `develop`.
- Merges: `feature/*` -> `develop` with **squash merge** (PR title = the short Conventional Commit subject, PR body = full description); `release/*` and `hotfix/*` -> `master` with **merge commit `--no-ff`**, then merge `master` back into `develop`. Tag every release (`vX.Y.Z`). Never rebase or force-push `develop`/`master`.
- Clean history views: `git log --first-parent --oneline develop` (one line per feature = rollback points); `git log --first-parent --oneline master` (releases/hotfixes); `git log --graph --oneline --decorate --all` for the full picture.
- Rollback: revert a squash commit (`git revert <sha>`) or a merge (`git revert -m 1 <merge-sha>`); prefer deploying the previous tag for releases. Find regressions with `git bisect` / `git log -S`.

## Git / CI
- CI runs on `master`, `develop`, `feature/**`, `release/**`, `hotfix/**`; PRs target `master`/`develop`. Historical hotfix branches are named `hotfix/YYYYMMDDHHMMSS`.
- Branch flow (ALWAYS follow): new work branches off `develop` as `feature/<short-slug>` -> PR into `develop` -> `develop` is merged into `master` only after the feature set is validated. Never keep committing on a feature branch after its PR was merged; start a fresh branch.
- `master` is the production source. Planned environments: a QA environment (closest to production, running the entire project, not just local) to validate before merging to `master`, then a production environment for deploys.
